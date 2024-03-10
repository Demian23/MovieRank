import SwiftUI

struct InfoLine: View {
    let imageName: String
    let title: String
    let valueText: String
    let tintColor: Color
    let valueColor: Color
    var body: some View {
        HStack{
            SettingsRowView(imageName: imageName, title: title, tintColor: tintColor)
            Spacer()
            Text(valueText).font(.subheadline).foregroundColor(valueColor)
        }
    }
}

#Preview {
    InfoLine(imageName: "globe", title: "Country", valueText: "Belarus", tintColor: Color(.systemBlue), valueColor: Color(.systemMint))
}
