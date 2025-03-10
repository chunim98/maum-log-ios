//
//  MockData.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

struct MockData {
    static let symptomDataArr: [SymptomData] = [
        .init(name: "증상1", hex: 0xd4b8a6, isNegative: true),
        .init(name: "증상2", hex: 0x8e7d7b, isNegative: true),
        .init(name: "증상3", hex: 0x7b6d71, isNegative: true),
        .init(name: "증상4", hex: 0xa28d8d, isNegative: true),
        .init(name: "기타 증상1", hex: 0x7f6f7b, isNegative: false),
        .init(name: "기타 증상2", hex: 0x6b5a6b, isNegative: false),
        .init(name: "기타 증상3", hex: 0x9d7a73, isNegative: false),
    ]
}
