import FirebaseStorage
import Foundation

@MainActor
final class ImagesUploadProgressObserver: ObservableObject {
    @Published var uploadTasks: [StorageUploadTask] = []
    @Published var uploadProgess: [Double] = []

    func removeUploadProgress(at index: Int) {
        uploadProgess.remove(at: index)
        uploadTasks.remove(at: index)
    }

    func detachUploadTask(at index: Int) {
        uploadTasks[index].removeAllObservers()
    }

    func updateUploadProgress(_ progress: Double, at index: Int) {
        print("progress \(progress) for index \(index)")
        let clampedProgress = min(max(progress, 0.0), 1.0)
        uploadProgess[index] = clampedProgress
    }
    
}
