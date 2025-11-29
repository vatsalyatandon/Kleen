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
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    self.permissionGranted = (status == .authorized || status == .limited)
                    if self.permissionGranted {
                        self.fetchPhotos()
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
                    }
                }
            }
        }
    }
    
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var fetchedPhotos: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            fetchedPhotos.append(asset)
        }
        
        DispatchQueue.main.async {
            self.photos = fetchedPhotos
        }
    }
    
    func deletePhoto(asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        } completionHandler: { success, error in
            if success {
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(of: asset) {
                        self.photos.remove(at: index)
                    }
                }
            } else {
                print("Error deleting photo: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
