import SwiftUI
import Firebase

@main
struct MovieRankApp: App {
    @StateObject var authModel = AuthViewModel()
    @StateObject var moviesModel = MovieListViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(moviesModel).environmentObject(authModel).withErrorHandling()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
