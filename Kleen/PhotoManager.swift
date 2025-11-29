import Foundation
import Photos
import UIKit

class PhotoManager: ObservableObject {
    @Published var photos: [PHAsset] = []
    @Published var permissionGranted: Bool = false
    
    init() {
        requestPermission()
    }
    

    
    func requestPermission() {
        isLoading = true
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    self.permissionGranted = (status == .authorized || status == .limited)
                    if self.permissionGranted {
                        self.fetchPhotos()
                    } else {
                        self.isLoading = false
                    }
                }
            }
        } else {
            // Fallback for older iOS versions
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.permissionGranted = (status == .authorized)
                    if self.permissionGranted {
                        self.fetchPhotos()
                    } else {
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // ... requestPermission remains same ...
    
    func fetchPhotos() {
        isLoading = true
        errorMessage = nil
        // Reset deletion queue on new fetch (Undo All)
        photosToDelete.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var fetchedPhotos: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            fetchedPhotos.append(asset)
        }
        
        DispatchQueue.main.async {
            self.photos = fetchedPhotos
            self.isLoading = false
        }
    }
    
    @Published var photosToDelete: [PHAsset] = []
    
    func deletePhoto(asset: PHAsset) {
        DispatchQueue.main.async {
            // Prevent duplicates
            if !self.photosToDelete.contains(asset) {
                self.photosToDelete.append(asset)
            }
            if let index = self.photos.firstIndex(of: asset) {
                self.photos.remove(at: index)
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
                } else {
                    // Handle user cancellation or error
                    let nsError = error as NSError?
                    if nsError?.code == 3072 {
                        self.errorMessage = "Deletion cancelled. You can try again when ready."
                    } else {
                        let errorMsg = error?.localizedDescription ?? "Unknown error"
                        print("Error deleting photos: \(errorMsg)")
                        self.errorMessage = "Deletion failed: \(errorMsg)"
                    }
                }
            }
        }
    }
}
