import Foundation
import PhotosUI

final class NewMovieViewModel : ObservableObject{
    
    @Published var name = ""
    @Published var country = ""
    @Published var genres: Set<Genres> = Set()
    @Published var director = ""
    @Published var description = ""
    @Published var mark = ""
    @Published var releaseDate: Date = Date()
    
    public init(){}
    
    func addNewMovie(by uid: String, images: [UIImage], progressObserver: ImagesUploadProgressObserver) async throws {
        let movie = Movie(id: NSUUID().uuidString, name: name, releaseDate: releaseDate, marksAmount: (mark.isEmpty ? 0 : 1), marksWholeScore: UInt64(mark) ?? 0, country: country.components(separatedBy: ", "), genre: genres.map{$0.rawValue}, director: director.components(separatedBy: ", "), description: description)
        try await MovieConnector.addNewMovie(newMovie: movie, currentUserId: uid);
        try await UserConnector.changeUserScore(userId: uid, on: 1)
        if !images.isEmpty{
            await MovieStorageConnector.uploadImages(for: movie.id, images: images, progressObserver: progressObserver)
        }
    }
    
    func isInputValid()->Bool{
        return !name.isEmpty && !country.isEmpty && !genres.isEmpty && !director.isEmpty && !description.isEmpty && !mark.isEmpty
        && isMarkValid
    }
    private var isMarkValid: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        var result = CharacterSet(charactersIn: mark).isSubset(of: digitsCharacters)
        if result {
            guard let markNumber = Int(mark) else {return false}
            result = 0...100 ~= markNumber
        }
        return result
    }
    
}
