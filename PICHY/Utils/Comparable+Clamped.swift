//
//  Comparable+Clamped.swift
//  PICHY
//

import Foundation

extension Comparable {
    /// Constrains the value to the given closed range.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
