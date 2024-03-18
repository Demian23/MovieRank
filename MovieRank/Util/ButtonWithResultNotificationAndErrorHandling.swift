import AlertToast
import SwiftUI

struct ButtonWithResultNotificationAndErrorHandling<LabelType: View>: View {

    let closure: () throws -> Void
    let errorHandler: (Error) -> Void
    let buttonLabel: () -> LabelType
    let newAlert: (() -> AlertToast)?
    @EnvironmentObject var alert: AlertViewModel

    var body: some View {
        VStack {
            Button {
                do {
                    try closure()
                    if newAlert != nil {
                        alert.alertToast = newAlert!()
                    }

                } catch {
                    errorHandler(error)
                }
            } label: {
                buttonLabel()
            }
        }
    }
}
struct AsyncButtonWithResultNotificationAndErrorHandling<LabelType: View>: View {

    let closure: () async throws -> Void
    let errorHandler: (Error) -> Void
    let buttonLabel: () -> LabelType
    let newAlert: (() -> AlertToast)?
    @EnvironmentObject var alert: AlertViewModel

    var body: some View {
        VStack {
            Button {
                Task {
                    do {
                        try await closure()
                        if newAlert != nil {
                            alert.alertToast = newAlert!()
                        }

                    } catch {
                        errorHandler(error)
                    }
                }
            } label: {
                buttonLabel()
            }
        }
    }
}

struct AsyncButtonWithResultNotificationAndErrorHandling_Preview: PreviewProvider {
    static var previews: some View {
        AsyncButtonWithResultNotificationAndErrorHandling(
            closure: { print("Closure") }, errorHandler: { error in print(error) },
            buttonLabel: { Text("Test") },
            newAlert: { AlertToast(type: .regular, title: "Let's check") }
        ).environmentObject(AlertViewModel())
    }
}
