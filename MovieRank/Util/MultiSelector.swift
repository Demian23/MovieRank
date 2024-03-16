import SwiftUI

struct MultiSelector<LabelView: View, Selectable: Identifiable & Hashable>: View {
    let label: LabelView
    let options: [Selectable]
    let optionToString: (Selectable) -> String
    var selected: Binding<Set<Selectable>>

    private var formattedSelectedListString: String {
        ListFormatter.localizedString(byJoining: selected.wrappedValue.map { optionToString($0) })
    }

    var body: some View {
        NavigationLink(destination: multiSelectionView()) {
            HStack {
                label
                Spacer()
                Text(formattedSelectedListString)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func multiSelectionView() -> some View {
        MultiSelectionView(
                    options: options,
                    optionToString: optionToString,
                    selected: selected
                )
    }
}
struct MultiSelector_Previews: PreviewProvider {
  
    @State
    static var selected: Set<Genres> = Set()
    
    static var previews: some View {
        NavigationView {
            Form {
                MultiSelector<Text, Genres>(
                    label: Text("Multiselect"),
                    options: Genres.allCases,
                    optionToString: { $0.rawValue},
                    selected: $selected
                )
            }.navigationTitle("Title")
        }
    }
}
