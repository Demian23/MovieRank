import FirebaseStorage
import Foundation

@MainActor
final class ImagesUploadProgressObserver: ObservableObject {
    @Published var uploadTasks: [Int:StorageUploadTask] = [:]
    @Published var uploadProgess: [Int:Double] = [:]

    func removeUploadTask(at index: Int) {
        if uploadTasks[index] != nil{
            uploadTasks[index]!.removeAllObservers()
            uploadTasks.removeValue(forKey: index)
            uploadProgess.removeValue(forKey: index)
        }
    }

    func updateUploadProgress(_ progress: Double, at index: Int) {
        if uploadProgess[index] != nil{
            uploadProgess[index] = progress
        }
    }
    
}
