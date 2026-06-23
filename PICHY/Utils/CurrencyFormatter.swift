//
//  CurrencyFormatter.swift
//  PICHY
//

import Foundation

enum CurrencyFormatter {
    private static let groupedFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f
    }()

    static func baht(_ amount: Int) -> String {
        "฿" + (groupedFormatter.string(from: NSNumber(value: amount)) ?? "0")
    }

    static func signed(_ amount: Int) -> String {
        let absStr = groupedFormatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        return (amount >= 0 ? "+" : "−") + absStr
    }
}
