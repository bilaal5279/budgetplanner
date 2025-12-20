import LocalAuthentication
import SwiftUI
import Combine

class BiometricManager: NSObject, ObservableObject {
    static let shared = BiometricManager()
    
    @Published var isLocked = false
    
    // We access UserDefaults directly to avoid ObservableObject/AppStorage conflicts
    var useFaceID: Bool {
        get { UserDefaults.standard.bool(forKey: "useFaceID") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "useFaceID")
        }
    }
    
    // Timeout Options
    enum LockTimeout: Int, CaseIterable, Identifiable {
        case immediate = 0
        case oneMinute = 60
        case fifteenMinutes = 900
        case oneHour = 3600
        case fourHours = 14400
        
        var id: Int { rawValue }
        
        var title: String {
            switch self {
            case .immediate: return "Immediately"
            case .oneMinute: return "After 1 minute"
            case .fifteenMinutes: return "After 15 minutes"
            case .oneHour: return "After 1 hour"
            case .fourHours: return "After 4 hours"
            }
        }
    }
    
    var lockTimeout: LockTimeout {
        get { 
            let val = UserDefaults.standard.integer(forKey: "lockTimeout")
            return LockTimeout(rawValue: val) ?? .immediate
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "lockTimeout")
        }
    }
    
    private var lastBackgroundDate: Date?
    
    private override init() {
        super.init()
        // Secure by default: If enabled, start locked.
        if useFaceID {
             isLocked = true
        }
    }
    
    func authenticate() {
        // Only authenticate if feature is enabled
        guard useFaceID else {
            isLocked = false
            return 
        }
        
        // If already unlocked, do nothing
        // guard isLocked else { return } // Wait, actually we call this to UNLOCK
        
        let context = LAContext()
        var error: NSError?
        
        // Use .deviceOwnerAuthentication to allow Passcode fallback if Biometrics fail or are unavailable
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock with Face ID or Passcode"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isLocked = false
                        self.lastBackgroundDate = nil // Reset
                    } else {
                        // Failed (Cancel or wrong passcode), keep locked.
                    }
                }
            }
        } else {
            // No Passcode or Biometrics set on device at all?
            // In this rare case, we can't lock securely.
             DispatchQueue.main.async {
                self.isLocked = false
            }
        }
    }
    
    func applicationDidEnterBackground() {
        guard useFaceID else { return }
        lastBackgroundDate = Date()
        
        if lockTimeout == .immediate {
            isLocked = true
        }
    }
    
    func checkLockRequirement() {
        guard useFaceID, !isLocked, let lastDate = lastBackgroundDate else { return }
        
        // If timeout is immediate, we already locked in background.
        // If not, Check time elapsed
        if lockTimeout != .immediate {
            let elapsed = Date().timeIntervalSince(lastDate)
            if elapsed >= Double(lockTimeout.rawValue) {
                isLocked = true
            }
        }
    }
    
    func forceLock() {
        if useFaceID {
            isLocked = true
        }
    }
}
