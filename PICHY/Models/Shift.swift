//
//  Shift.swift
//  PICHY
//

import Foundation

struct Shift: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let type: ShiftType
    let otHours: Int
    let note: String?
    /// Only meaningful when `type == .off`: which kind of leave/day-off.
    let leaveType: LeaveType?

    init(id: UUID = UUID(),
         date: Date,
         type: ShiftType,
         otHours: Int = 0,
         note: String? = nil,
         leaveType: LeaveType? = nil) {
        self.id = id
        self.date = date
        self.type = type
        self.otHours = otHours
        self.note = note
        self.leaveType = leaveType
    }

    func updating(type: ShiftType? = nil,
                  otHours: Int? = nil,
                  note: String? = nil,
                  leaveType: LeaveType?? = nil) -> Shift {
        Shift(id: id,
              date: date,
              type: type ?? self.type,
              otHours: otHours ?? self.otHours,
              note: note ?? self.note,
              leaveType: leaveType ?? self.leaveType)
    }

    /// Resolved leave kind for an off day (defaults to a plain day-off).
    var resolvedLeave: LeaveType? {
        guard type == .off else { return nil }
        return leaveType ?? .dayOff
    }

    func income(using rates: PayRates) -> Int {
        let base: Int = {
            switch type {
            case .morning:      return rates.morningShift
            case .afternoon:    return rates.afternoonShift
            case .night:        return rates.nightShift
            case .ot:           return rates.morningShift
            case .off, .custom: return 0
            }
        }()
        return base + otHours * rates.otPerHour
    }
}
