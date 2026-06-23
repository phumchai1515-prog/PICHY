//
//  Transaction.swift
//  PICHY
//

import SwiftUI

enum TransactionKind: String, Codable { case income, expense }

enum TransactionSource: String, Codable { case shift, manual }

enum ExpenseCategory: String, Codable, CaseIterable {
    case food, transport, shopping, bills, other

    var label: String {
        switch self {
        case .food:      return "อาหาร"
        case .transport: return "เดินทาง"
        case .shopping:  return "ช้อปปิ้ง"
        case .bills:     return "บิล"
        case .other:     return "อื่นๆ"
        }
    }

    var iconName: String {
        switch self {
        case .food:      return "bag.fill"
        case .transport: return "car.fill"
        case .shopping:  return "cart.fill"
        case .bills:     return "doc.text.fill"
        case .other:     return "ellipsis"
        }
    }
}

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let amount: Int           // positive for income, negative for expense
    let title: String
    let category: String      // expense category label or shift label
    let kind: TransactionKind
    let source: TransactionSource
    let shiftType: ShiftType? // populated when source == .shift
    let note: String?

    init(id: UUID = UUID(),
         date: Date,
         amount: Int,
         title: String,
         category: String,
         kind: TransactionKind,
         source: TransactionSource,
         shiftType: ShiftType? = nil,
         note: String? = nil) {
        self.id = id
        self.date = date
        self.amount = amount
        self.title = title
        self.category = category
        self.kind = kind
        self.source = source
        self.shiftType = shiftType
        self.note = note
    }
}
