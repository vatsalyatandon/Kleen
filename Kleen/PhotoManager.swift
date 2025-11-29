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
    
    private var fetchResult: PHFetchResult<PHAsset>?
    private var lastLoadedIndex = 0
    private let batchSize = 50
    private let trashKey = "gallery_cleaner_trash_ids"
    
    override init() {
        super.init()
        
        // Check current status synchronously to avoid UI flash
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        self.permissionGranted = (currentStatus == .authorized || currentStatus == .limited)
        self.isLimited = (currentStatus == .limited)
        
        PHPhotoLibrary.shared().register(self)
        loadTrash()
        
        // Only request if not already authorized
        if !permissionGranted {
            requestPermission()
        } else {
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
            self.fetchPhotos()
        } else {
            self.isLoading = false
        }
    }
    
    func fetchPhotos() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        errorMessage = nil
        lastLoadedIndex = 0
        photos.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeAllBurstAssets = false // Handle Bursts
        
        self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        loadMorePhotos()
    }
    
    func loadMorePhotos() {
        guard let fetchResult = fetchResult, lastLoadedIndex < fetchResult.count else {
            isLoading = false
            return
        }
        
        let endIndex = min(lastLoadedIndex + batchSize, fetchResult.count)
        var newPhotos: [PHAsset] = []
        
        // Fetch batch
        fetchResult.enumerateObjects(at: IndexSet(integersIn: lastLoadedIndex..<endIndex)) { asset, _, _ in
            // Filter out photos already in trash
            if !self.photosToDelete.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                newPhotos.append(asset)
            }
        }
        
        DispatchQueue.main.async {
            self.photos.append(contentsOf: newPhotos)
            self.lastLoadedIndex = endIndex
            self.isLoading = false
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
        if let ids = UserDefaults.standard.array(forKey: trashKey) as? [String] {
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
            if let fetchResult = self.fetchResult, let changes = changeInstance.changeDetails(for: fetchResult) {
                self.fetchResult = changes.fetchResultAfterChanges
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
