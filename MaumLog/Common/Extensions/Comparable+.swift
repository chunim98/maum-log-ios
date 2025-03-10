//
//  Comparable+.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

extension Comparable {
    func clamped(_ range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
