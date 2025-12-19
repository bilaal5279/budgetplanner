import SwiftUI
import Foundation

@Observable
class CurrencyManager {
    static let shared = CurrencyManager()
    
    var currencyCode: String {
        didSet {
            UserDefaults.standard.set(currencyCode, forKey: "appCurrency")
        }
    }
    
    init() {
        self.currencyCode = UserDefaults.standard.string(forKey: "appCurrency") ?? Locale.current.currency?.identifier ?? "USD"
    }
    
    func format(_ amount: Double) -> String {
        return amount.formatted(.currency(code: currencyCode))
    }
    
    // List of common currencies for selection
    static let commonCurrencies = Locale.commonISOCurrencyCodes.sorted()
    
    /// Returns the symbol for a given currency code (e.g., "USD" -> "$", "GBP" -> "£")
    /// Returns the symbol for a given currency code (e.g., "USD" -> "$", "GBP" -> "£")
    func getSymbol(for code: String) -> String {
        // Primary Source: Hardcoded Dictionary for Speed and Accuracy
        let symbols: [String: String] = [
            "USD": "$", "EUR": "€", "GBP": "£", "JPY": "¥", "CNY": "¥", "KRW": "₩",
            "INR": "₹", "RUB": "₽", "BRL": "R$", "AUD": "A$", "CAD": "C$", "NZD": "NZ$",
            "MXN": "$", "HKD": "HK$", "SGD": "S$", "CHF": "CHF", "ZAR": "R", "TRY": "₺",
            "SEK": "kr", "NOK": "kr", "DKK": "kr", "PLN": "zł", "THB": "฿", "IDR": "Rp",
            "HUF": "Ft", "CZK": "Kč", "ILS": "₪", "PHP": "₱", "AED": "dhs", "COP": "$",
            "SAR": "﷼", "MYR": "RM", "RON": "lei", "VND": "₫", "ARS": "$", "IQD": "IQD",
            "CLP": "$", "TWD": "NT$", "EGP": "E£", "PKR": "Rs", "NGN": "₦", "BDT": "৳",
            "UAH": "₴", "QAR": "QR", "KWD": "KD", "MAD": "MAD", "OMR": "OMR", "KES": "KSh",
            "DOP": "RD$", "CRC": "₡", "UYU": "$U", "PEN": "S/", "KZT": "₸", "BGN": "лв",
            "HRK": "kn", "LKR": "Rs", "DZD": "DA", "TND": "DT", "JOD": "JD", "BHD": "BD",
            "LBP": "L£", "JMD": "J$", "XOF": "CFA", "XAF": "CFA", "XPF": "₣", "ISK": "kr",
            "RSD": "дин.", "GHS": "GH₵", "BAM": "KM", "MZN": "MT", "TZS": "TSh"
        ]
        
        if let symbol = symbols[code] {
            return symbol
        }
        
        // Secondary Source: Locale attempt
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: code]))
        if let symbol = locale.currencySymbol, symbol != code {
            return symbol
        }
        
        return code // Fallback to code if symbol not found
    }
}
