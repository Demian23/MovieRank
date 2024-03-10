import SwiftUI

struct ButtonWithResultNotificationAndErrorHandling<LabelType: View>: View {
    
    let buttonLabel: () -> LabelType
    let closure: () throws -> Void
    let errorHandler: (Error) -> Void
    let notificationTitle: String
    let notificationMessage: String
    @State var isAlertShown = false
    
    var body: some View {
        Button{
            do{
                try closure()
                if !notificationTitle.isEmpty && !notificationMessage.isEmpty{
                    isAlertShown = true
                }
            } catch {
                errorHandler(error)
            }
        } label: {
           buttonLabel()
        }.alert(isPresented: $isAlertShown){
           Alert(title: Text(notificationTitle), message: Text( notificationMessage))
        }
    }
}

struct AsyncButtonWithResultNotificationAndErrorHandling<LabelType: View>: View {
    
    let closure: () async throws -> Void
    let errorHandler: (Error) -> Void
    let buttonLabel: () -> LabelType
    
    let notificationTitle: String
    let notificationMessage: String
    
    @State var isAlertShown = false
    
    var body: some View {
        Button{
            Task{
                do{
                    try await closure()
                    isAlertShown = true
                } catch {
                    errorHandler(error)
                }
            }
        } label: {
           buttonLabel()
        }.alert(isPresented: $isAlertShown){
           Alert(title: Text(notificationTitle), message: Text( notificationMessage))
        }
    }
}


#Preview {
    AsyncButtonWithResultNotificationAndErrorHandling(closure:{print("Closure")}, errorHandler: {error in print(error)}, buttonLabel: {Text("Test")}, notificationTitle: "Info", notificationMessage: "String printed")
}
