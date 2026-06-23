//
//  LeaveQuota.swift
//  PICHY
//
//  Yearly leave allowance per quota kind. Set by the user; tracked per Thai
//  fiscal year (1 Oct – 30 Sep).
//

import Foundation

struct LeaveQuota: Codable, Equatable {
    let sick: Int
    let personal: Int
    let vacation: Int

    static let `default` = LeaveQuota(sick: 30, personal: 10, vacation: 10)

    func days(for type: LeaveType) -> Int {
        switch type {
        case .sick:     return sick
        case .personal: return personal
        case .vacation: return vacation
        case .dayOff, .publicHoliday: return 0
        }
    }

    func updating(sick: Int? = nil, personal: Int? = nil, vacation: Int? = nil) -> LeaveQuota {
        LeaveQuota(
            sick: sick ?? self.sick,
            personal: personal ?? self.personal,
            vacation: vacation ?? self.vacation
        )
    }
}
