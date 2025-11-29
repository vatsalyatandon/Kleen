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
        print("Requesting permission...")
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                print("Permission status: \(status.rawValue)")
                DispatchQueue.main.async {
                    self.permissionGranted = (status == .authorized || status == .limited)
                    if self.permissionGranted {
                        self.fetchPhotos()
                    } else {
                        print("Permission denied or restricted.")
                    }
                }
            }
        } else {
            // Fallback for older iOS versions
            PHPhotoLibrary.requestAuthorization { status in
                print("Permission status (old API): \(status.rawValue)")
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
        print("Fetching photos...")
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        print("Found \(fetchResult.count) photos.")
        
        var fetchedPhotos: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            fetchedPhotos.append(asset)
        }
        
        DispatchQueue.main.async {
            self.photos = fetchedPhotos
            print("Photos updated in view model. Count: \(self.photos.count)")
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
