import Foundation
import SwiftData
import SwiftUI

struct CSVManager {
    static func generateCSV(from transactions: [Transaction]) -> URL? {
        var csvString = "Date,Type,Amount,Category,Account,Note\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        for transaction in transactions {
            let date = dateFormatter.string(from: transaction.date)
            let type = transaction.type.rawValue
            let amount = String(format: "%.2f", transaction.amount)
            let category = transaction.category?.name ?? ""
            let account = transaction.account?.name ?? ""
            let note = transaction.note.replacingOccurrences(of: ",", with: " ") // Simple escape
            
            let row = "\(date),\(type),\(amount),\(category),\(account),\(note)\n"
            csvString.append(row)
        }
        
        let fileName = "PocketWealth_Export.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to create CSV: \(error)")
            return nil
        }
    }
}
