import Foundation
import Photos
import PhotosUI
import UIKit

class PhotoManager: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var photos: [PHAsset] = []
    @Published var photosToDelete: [PHAsset] = []
    @Published var permissionGranted: Bool = false
    @Published var isLimited: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var allAssets: PHFetchResult<PHAsset>?
    private let trashKey = "gallery_cleaner_trash_ids"
    private let keptKey = "photosKept"
    
    override init() {
        super.init()
        
        // IMPORTANT: Don't check authorization status on first launch
        // because it triggers the permission prompt on iOS 14+
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            // Only check status if user has already seen onboarding
            let currentStatus: PHAuthorizationStatus
            if #available(iOS 14, *) {
                currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            } else {
                currentStatus = PHPhotoLibrary.authorizationStatus()
            }
            
            self.permissionGranted = (currentStatus == .authorized || currentStatus == .limited)
            self.isLimited = (currentStatus == .limited)
            
            // Register observer only after onboarding
            PHPhotoLibrary.shared().register(self)
        } else {
            // First launch - don't check status, let onboarding complete first
            self.permissionGranted = false
            self.isLimited = false
        }
        
        loadTrash()
        
        // Only fetch photos if already authorized
        if permissionGranted {
            fetchPhotos()
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func requestPermission() {
        isLoading = true
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    self.handlePermissionStatus(status)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.handlePermissionStatus(status)
                }
            }
        }
    }
    
    private func handlePermissionStatus(_ status: PHAuthorizationStatus) {
        self.permissionGranted = (status == .authorized || status == .limited)
        self.isLimited = (status == .limited)
        
        if self.permissionGranted {
            // Register observer now that we have permission
            PHPhotoLibrary.shared().register(self)
            
            // Reset isLoading because requestPermission set it to true,
            // and fetchPhotos has a guard check for it.
            self.isLoading = false
            self.fetchPhotos()
        } else {
            self.isLoading = false
        }
    }
    
    func fetchPhotos() {
        guard !isLoading else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeAllBurstAssets = false
        
        let allAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        self.allAssets = allAssets
        
        // Load kept IDs
        let keptIds = Set(UserDefaults.standard.stringArray(forKey: keptKey) ?? [])
        // Load trash IDs (already in photosToDelete, but good to have the set for filtering)
        let trashIds = Set(photosToDelete.map { $0.localIdentifier })
        
        var newPhotos: [PHAsset] = []
        var count = 0
        let batchSize = 50
        
        // Iterate and filter
        allAssets.enumerateObjects { asset, index, stop in
            // Skip if already kept or already in trash
            if !keptIds.contains(asset.localIdentifier) && !trashIds.contains(asset.localIdentifier) {
                newPhotos.append(asset)
                count += 1
            }
            
            if count >= batchSize {
                stop.pointee = true
            }
        }
        
        DispatchQueue.main.async {
            self.photos = newPhotos
            self.isLoading = false
        }
    }
    
    func loadMorePhotos() {
        guard let lastPhoto = photos.last, let allAssets = allAssets else { return }
        
        let keptIds = Set(UserDefaults.standard.stringArray(forKey: keptKey) ?? [])
        let trashIds = Set(photosToDelete.map { $0.localIdentifier })
        
        var newPhotos: [PHAsset] = []
        var count = 0
        let batchSize = 50
        var shouldStartAdding = false
        
        allAssets.enumerateObjects { asset, index, stop in
            if asset.localIdentifier == lastPhoto.localIdentifier {
                shouldStartAdding = true
                return // Continue to next iteration
            }
            
            if shouldStartAdding {
                // Filter out kept/trash
                if !keptIds.contains(asset.localIdentifier) && !trashIds.contains(asset.localIdentifier) {
                    newPhotos.append(asset)
                    count += 1
                }
                
                if count >= batchSize {
                    stop.pointee = true
                }
            }
        }
        
        DispatchQueue.main.async {
            self.photos.append(contentsOf: newPhotos)
        }
    }
    
    func keepPhoto(asset: PHAsset) {
        // Add to kept list and persist
        var keptIds = UserDefaults.standard.stringArray(forKey: keptKey) ?? []
        keptIds.append(asset.localIdentifier)
        UserDefaults.standard.set(keptIds, forKey: keptKey)
    }
    
    func restorePhoto(asset: PHAsset) {
        // Remove from trash queue
        if let index = photosToDelete.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            photosToDelete.remove(at: index)
            saveTrash()
            
            // Add back to main photos deck if it's not already there
            if !photos.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                // We insert it at the beginning or end?
                // Ideally, we just want it available again.
                // Inserting at 0 makes it the "next" card, which is a good "Undo" behavior.
                photos.insert(asset, at: 0)
            }
        }
    }
    
    // MARK: - Deletion Logic
    
    func deletePhoto(asset: PHAsset) {
        DispatchQueue.main.async {
            if !self.photosToDelete.contains(asset) {
                self.photosToDelete.append(asset)
                self.saveTrash()
            }
            if let index = self.photos.firstIndex(of: asset) {
                self.photos.remove(at: index)
            }
            
            // Trigger pagination if running low
            if self.photos.count < 5 {
                self.loadMorePhotos()
            }
        }
    }
    
    func commitDeletion() {
        guard !photosToDelete.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(self.photosToDelete as NSArray)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    print("Successfully deleted \(self.photosToDelete.count) photos.")
                    self.photosToDelete.removeAll()
                    self.saveTrash()
                    // Refresh to ensure sync
                    self.fetchPhotos()
                } else {
                    let nsError = error as NSError?
                    if nsError?.code == 3072 {
                        self.errorMessage = "Deletion cancelled. You can try again when ready."
                    } else {
                        let errorMsg = error?.localizedDescription ?? "Unknown error"
                        self.errorMessage = "Deletion failed: \(errorMsg)"
                    }
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveTrash() {
        let ids = photosToDelete.map { $0.localIdentifier }
        UserDefaults.standard.set(ids, forKey: trashKey)
    }
    
    private func loadTrash() {
        // Don't access PhotoKit on first launch - it triggers permission prompt
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        guard hasSeenOnboarding else { return }
        
        if let ids = UserDefaults.standard.array(forKey: trashKey) as? [String], !ids.isEmpty {
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: fetchOptions)
            var loadedAssets: [PHAsset] = []
            assets.enumerateObjects { asset, _, _ in
                loadedAssets.append(asset)
            }
            self.photosToDelete = loadedAssets
        }
    }
    
    // MARK: - Limited Access & Observer
    
    func presentLimitedLibraryPicker() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: UIApplication.shared.windows.first!.rootViewController!)
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Handle external changes
        DispatchQueue.main.async {
            // 1. Check if photos in our deck were deleted externally
            if let allAssets = self.allAssets, let changes = changeInstance.changeDetails(for: allAssets) {
                self.allAssets = changes.fetchResultAfterChanges
                // If objects were removed, we might need to remove them from our 'photos' array
                if changes.hasIncrementalChanges {
                    let removed = changes.removedObjects
                    if !removed.isEmpty {
                        // Remove from main deck
                        self.photos.removeAll { asset in
                            removed.contains(asset)
                        }
                        
                        // Remove from trash queue (if user deleted it externally, we can't delete it again)
                        let initialCount = self.photosToDelete.count
                        self.photosToDelete.removeAll { asset in
                            removed.contains(asset)
                        }
                        if self.photosToDelete.count != initialCount {
                            self.saveTrash()
                            print("Removed \(initialCount - self.photosToDelete.count) photos from trash because they were deleted externally.")
                        }
                    }
                }
            }
            
            // 2. Check if photos in our Trash were deleted externally
            // (This is harder because we don't hold a FetchResult for trash, just an array)
            // But we can validate them before commit.
        }
    }
}
