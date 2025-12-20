import Foundation
import RevenueCat
import SwiftUI
import Combine
class SubscriptionManager: NSObject, ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isPremium: Bool = false
    @Published var currentOffering: Offering?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Configuration
    private let apiKey = "appl_xATMJBxBOdLICOLLndpMiQFUSGN"
    private let entitlementID = "Pocket Wealth Pro"
    
    private override init() {
        super.init()
    }
    
    func configure() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        
        // Listen for subscription changes
        Purchases.shared.delegate = self
        
        // Check initial status
        checkSubscriptionStatus()
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let customerInfo = customerInfo {
                self.updatePremiumStatus(from: customerInfo)
            }
        }
    }
    
    func fetchOfferings() {
        isLoading = true
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Error fetching offerings: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let current = offerings?.current {
                self.currentOffering = current
            }
        }
    }
    
    func purchase(package: Package, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Purchases.shared.purchase(package: package) { [weak self] (transaction, customerInfo, error, userCancelled) in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                if !userCancelled {
                    self.errorMessage = error.localizedDescription
                }
                completion(false)
                return
            }
            
            if let customerInfo = customerInfo {
                self.updatePremiumStatus(from: customerInfo)
                if self.isPremium {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        isLoading = true
        Purchases.shared.restorePurchases { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            if let customerInfo = customerInfo {
                self.updatePremiumStatus(from: customerInfo)
                completion(self.isPremium)
            } else {
                completion(false)
            }
        }
    }
    
    private func updatePremiumStatus(from customerInfo: CustomerInfo) {
        DispatchQueue.main.async {
            self.isPremium = customerInfo.entitlements[self.entitlementID]?.isActive == true
        }
    }
}

// MARK: - PurchasesDelegate
extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        updatePremiumStatus(from: customerInfo)
    }
}
