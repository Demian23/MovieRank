import Foundation
import PhotosUI
import _PhotosUI_SwiftUI

class PhotoSelectorViewModel: ObservableObject {
    @Published var images = [UIImage]()
    @Published var selectedPhotos = [PhotosPickerItem]()

    @MainActor
    func convertDataToImage() {
        images.removeAll()
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            images.append(image)
                        }
                    }
                }
            }
        }
        selectedPhotos.removeAll()
    }
}
