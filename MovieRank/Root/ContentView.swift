import AlertToast
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthViewModel
    @StateObject var moviesModel = MovieListViewModel()
    @StateObject var favouritesModel = FavouritesViewModel()
    @StateObject var alert = AlertViewModel()
    var body: some View {
        Group {
            if authModel.currentUserSession != nil && authModel.currentUser != nil {
                TabView {
                    MovieList(userId: authModel.uid!)
                        .tabItem { Label("Movies", systemImage: "list.and.film") }
                    Favourites(userId: authModel.uid!).tabItem {
                        Label("Favourites", systemImage: "star.fill")
                    }
                    if authModel.currentUser!.role == Role.Admin.rawValue {
                        NewMovie(userId: authModel.uid!)
                            .tabItem { Label("New Movie", systemImage: "plus") }
                    }
                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "gear.circle.fill") }
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(moviesModel)
        .environmentObject(favouritesModel)
        .environmentObject(alert)
        .toast(isPresenting: $alert.show) {
            alert.alertToast
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
