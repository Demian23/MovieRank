import SwiftUI

struct UIImageScroller: View {
    @State private var selectedImage = 0
    @Binding var images: [UIImage]
    var body: some View {
        ZStack {
            Color.secondary
                .ignoresSafeArea()

            TabView(selection: $selectedImage) {
                ForEach(images.indices, id: \.self) { index in
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: images[index])
                            .resizable()
                            .frame(width: 350, height: 200)
                    }
                    .shadow(radius: 20)
                }
            }
            .frame(height: 300)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()

            HStack {
                ForEach(0..<images.count, id: \.self) { index in
                    Capsule()
                        .fill(Color.white.opacity(selectedImage == index ? 1 : 0.33))
                        .frame(width: 35, height: 8)
                        .onTapGesture {
                            selectedImage = index
                        }
                }
                .offset(y: 130)
            }
        }
    }
}

struct ImageScroller_Previews: PreviewProvider {
    static var previews: some View {
        UIImageScroller(images: .constant([UIImage(), UIImage()]))
    }
}
