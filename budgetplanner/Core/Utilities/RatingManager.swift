import SwiftUI
import StoreKit

class RatingManager {
    static let shared = RatingManager()
    
    // App Store ID provided by user
    private let appStoreId = "6756803830"
    
    private let kHasRatedApp = "hasRatedApp"
    private let kTransactionCount = "transactionCountForRating"
    
    var hasRated: Bool {
        get { UserDefaults.standard.bool(forKey: kHasRatedApp) }
        set { UserDefaults.standard.set(newValue, forKey: kHasRatedApp) }
    }
    
    /// Request native SKStoreReviewController review
    func requestNativeReview() {
        // iOS 18+ uses AppStore.requestReview(in:)
        // Older versions use SKStoreReviewController
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    /// Open the App Store page for writing a review
    func openAppStoreReview() {
        // Mark as rated so we don't bug them again with custom prompts
        hasRated = true
        
        let urlString = "https://apps.apple.com/app/id\(appStoreId)?action=write-review"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Record a transaction and check if we should prompt custom alert
    /// Returns true if we should show the "Great vs Better" alert
    func shouldShowFirstTransactionPrompt() -> Bool {
        if hasRated { return false }
        
        // Increment count
        let count = UserDefaults.standard.integer(forKey: kTransactionCount) + 1
        UserDefaults.standard.set(count, forKey: kTransactionCount)
        
        // Show only on the EXACT first transaction
        return count == 1
    }
}
