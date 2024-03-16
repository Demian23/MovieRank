import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthViewModel
    var body: some View {
        Group{
            if authModel.currentUserSession != nil && authModel.currentUser != nil {
                TabView{
                    MovieList(userId: authModel.uid!)
                        .tabItem{Label("Movies", systemImage: "list.and.film")}
                    if authModel.currentUser!.role == Role.Admin.rawValue {
                        NewMovie()
                            .tabItem{Label("New Movie", systemImage: "plus")}
                    }
                    ProfileView()
                        .tabItem{Label("Profile", systemImage: "gear.circle.fill")}
                }
            } else {
               LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
