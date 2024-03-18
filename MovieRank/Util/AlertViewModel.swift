import AlertToast
import Foundation

final class AlertViewModel: ObservableObject {
    @Published var show = false
    @Published var alertToast = AlertToast(type: .regular, title: "Temp") {
        didSet {
            show.toggle()
        }
    }
}
