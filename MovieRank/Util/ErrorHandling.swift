import SwiftUI

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}

class ErrorHandling: ObservableObject {
    @Published var currentAllert: ErrorAlert?

    func handle(error: Error) {
        currentAllert = ErrorAlert(message: error.localizedDescription)
    }
}

struct HandleErrorsByShowingAlertViewModifier: ViewModifier {
    @StateObject var errorHandling = ErrorHandling()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAllert) { currentAlert in
                        Alert(
                            title: Text("Error"),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text("Ok")) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}
