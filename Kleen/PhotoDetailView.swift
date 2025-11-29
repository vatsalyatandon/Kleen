//
//  PhotoDetailView.swift
//  Kleen
//
//  Created by Vatsalya Tandon on 29/11/25.
//


import SwiftUI
import Photos
import MapKit

struct PhotoDetailView: View {
    let asset: PHAsset
    @Environment(\.presentationMode) var presentationMode
    @State private var fileSize: String = "Calculating..."
    @State private var locationName: String = "Unknown Location"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Basic Info")) {
                    DetailRow(icon: "calendar", title: "Date", value: asset.creationDate?.formatted(date: .long, time: .standard) ?? "Unknown")
                    DetailRow(icon: "camera.metering.center.weighted", title: "Resolution", value: "\(asset.pixelWidth) x \(asset.pixelHeight)")
                    DetailRow(icon: "internaldrive", title: "File Size", value: fileSize)
                }
                
                if let location = asset.location {
                    Section(header: Text("Location")) {
                        DetailRow(icon: "mappin.and.ellipse", title: "Coordinates", value: String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude))
                        DetailRow(icon: "map", title: "Place", value: locationName)
                        
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: [])
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                }
                
                Section(header: Text("Technical Details")) {
                    DetailRow(icon: "heart", title: "Favorite", value: asset.isFavorite ? "Yes" : "No")
                    DetailRow(icon: "photo", title: "Type", value: mediaTypeString)
                    if asset.mediaSubtypes.contains(.photoScreenshot) {
                        DetailRow(icon: "camera.viewfinder", title: "Subtype", value: "Screenshot")
                    }
                }
            }
            .navigationTitle("Photo Details")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                calculateFileSize()
                resolveLocation()
            }
        }
    }
    
    var mediaTypeString: String {
        switch asset.mediaType {
        case .image: return "Image"
        case .video: return "Video"
        case .audio: return "Audio"
        default: return "Unknown"
        }
    }
    
    private func calculateFileSize() {
        let resources = PHAssetResource.assetResources(for: asset)
        if let resource = resources.first {
            if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                let sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64))
                fileSize = ByteCountFormatter.string(fromByteCount: sizeOnDisk, countStyle: .file)
            } else {
                fileSize = "Unknown"
            }
        }
    }
    
    private func resolveLocation() {
        guard let location = asset.location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                self.locationName = [place.locality, place.administrativeArea, place.country].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
