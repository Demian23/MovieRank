import FirebaseStorage
import Foundation
import PhotosUI

final class MovieStorageConnector {
    static private let st = Storage.storage()
    static private let root = "movies"
    private init() {}

    @MainActor
    static func downloadImages(for movieId: String, completion: @escaping (UIImage) -> Void) {
        let movieRef = st.reference().child(root + "/" + movieId)
        movieRef.listAll { result, error in
            if let error = error {
                print("List all error: \(error.localizedDescription)")
                return
            }
            for imageFile in result!.items {
                imageFile.getData(maxSize: 512 * 1024) { data, error in
                    if let error = error {
                        print("Image download error: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data else {
                        print("Nothing to fetch")
                        return
                    }
                    guard let image = UIImage(data: data) else {
                        print("Can't construct image")
                        return
                    }
                    completion(image)
                }
            }
        }
    }

    @MainActor
    static func uploadImages(
        for movieId: String, images: [UIImage], progressObserver: ImagesUploadProgressObserver
    ) {
        let movieRef = st.reference().child(root + "/" + movieId)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        progressObserver.uploadProgess = Array(repeating: 0.0, count: images.count)
        for i in 0..<images.count {
            let compressed = images[i].jpegData(compressionQuality: 0.2)
            guard let data = compressed else { return }
            let imageRef = movieRef.child(String(i))
            let uploadTask = imageRef.putData(data, metadata: metadata) {
                metadata, error in
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    return
                }
                print("Uploaded with: \(metadata!)")
                progressObserver.detachUploadTask(at: i)
            }
            progressObserver.uploadTasks.append(uploadTask)
            uploadTask.observe(.progress) { snapshot in
                guard let progress = snapshot.progress else { return }
                let progressComplete =
                    Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                progressObserver.updateUploadProgress(progressComplete, at: i)
            }
        }
    }
}
