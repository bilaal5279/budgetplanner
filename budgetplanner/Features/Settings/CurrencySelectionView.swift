import SwiftUI

struct CurrencySelectionView: View {
    @Bindable var manager = CurrencyManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredCurrencies: [String] {
        if searchText.isEmpty {
            return CurrencyManager.commonCurrencies
        } else {
            return CurrencyManager.commonCurrencies.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredCurrencies, id: \.self) { code in
                HStack {
                    Text(validSymbol(for: code))
                        .font(.headline)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading) {
                        Text(code)
                            .font(.body)
                        Text(Locale.current.localizedString(forCurrencyCode: code) ?? code)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if code == manager.currencyCode {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Theme.Colors.mint)
                    }
                }
                .contentShape(Rectangle()) // Make full row tapable
                .onTapGesture {
                    manager.currencyCode = code
                    dismiss()
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Select Currency")
    }
    
    func validSymbol(for code: String) -> String {
        manager.getSymbol(for: code)
    }
}
