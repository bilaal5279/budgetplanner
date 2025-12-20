import SwiftUI
import SwiftData

struct ThemeSyncManager: View {
    @Query private var preferences: [AppPreferences]
    @Environment(\.modelContext) private var modelContext
    
    // Local storages to sync TO
    @AppStorage("appTheme") private var currentTheme: Theme.AppAppearance = .system
    @AppStorage("appAccent") private var currentAccent: Theme.AppAccent = .mint
    
    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                // Initial Check: If no preference exists in Cloud/DB, create one from local defaults
                if preferences.isEmpty {
                    let newBuf = AppPreferences(
                        themeRawValue: currentTheme.rawValue,
                        accentRawValue: currentAccent.rawValue
                    )
                    modelContext.insert(newBuf)
                } else {
                    // If exists, sync FROM Cloud TO Local
                    if let first = preferences.first {
                        syncLocal(from: first)
                    }
                }
            }
            .onChange(of: preferences) { oldValue, newValue in
                // When Cloud updates, sync TO Local
                if let first = newValue.first {
                    syncLocal(from: first)
                }
            }
            .onChange(of: currentTheme) { oldValue, newValue in
                // This direction (Local -> Cloud) is mostly handled by SettingsView directly writing to Model,
                // but if defaults change externally, we could sync back?
                // Actually, SettingsView will modify the Model directly, so we just need Model -> Local here.
                // However, to be safe, if Local changes and Model doesn't match, update Model?
                // Avoiding loops is key. Let's rely on View writing to Model mostly.
            }
    }
    
    private func syncLocal(from preference: AppPreferences) {
        // Sync Theme
        if let theme = Theme.AppAppearance(rawValue: preference.themeRawValue), theme != currentTheme {
            currentTheme = theme
        }
        
        // Sync Accent
        if let accent = Theme.AppAccent(rawValue: preference.accentRawValue), accent != currentAccent {
            currentAccent = accent
        }
    }
}
