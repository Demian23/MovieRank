import PhotosUI
import SwiftUI

struct PhotoSelector: View {
    @EnvironmentObject var vm: PhotoSelectorViewModel
    let maxPhotosToSelect = 10
    var size = 300

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(CGFloat(size)))]) {
                    ForEach(0..<vm.images.count, id: \.self) { index in
                        Image(uiImage: vm.images[index])
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            PhotosPicker(
                selection: $vm.selectedPhotos,
                maxSelectionCount: maxPhotosToSelect,
                selectionBehavior: .ordered,
                matching: .images
            ) {
                Label(
                    "Select up to ^[\(maxPhotosToSelect) photo](inflect: true)",
                    systemImage: "photo")
            }
        }
        .padding()
        .onChange(of: vm.selectedPhotos) { _ in
            vm.convertDataToImage()
        }
    }
}

struct PhotoSelector_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSelector().environmentObject(PhotoSelectorViewModel())
    }
}
