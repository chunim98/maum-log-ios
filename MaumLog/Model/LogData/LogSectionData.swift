//
//  LogSectionData.swift
//  MaumLog
//
//  Created by 신정욱 on 8/14/24.
//

import Foundation
import RxDataSources

struct LogSectionData: Comparable {
    let header: String
    var items: [LogData]
    var dateForSorting: String
    
    
    init(items: [LogData], dateForSorting: String) {
        // 소트를 위해 미리 확장해놓은 포메터
        let date = DateFormatter.forSort.date(from: dateForSorting) ?? Date()

        self.header = DateFormatter.forHeader.string(from: date)
        self.items = items
        self.dateForSorting = dateForSorting
    }
    
    // sort() 메서드 쓰고 싶어서 구현한 연산자 메서드
    static func < (lhs: LogSectionData, rhs: LogSectionData) -> Bool {
        lhs.dateForSorting < rhs.dateForSorting
    }
    
    // fale일 경우 reload 에니메이션 처리될 것으로 예상중, 아직 섹션은 테스트 못해봄
    static func == (lhs: LogSectionData, rhs: LogSectionData) -> Bool {
        lhs.dateForSorting == rhs.dateForSorting
    }
}

extension LogSectionData: AnimatableSectionModelType {
    // AnimatableSectionModelType사용시 identity 설정 잘 해둘것
    // identity 값이 바뀌면 insert에니메이션 처리됨
    var identity: String {
        self.header
    }
    
    init(original: LogSectionData, items: [LogData]) {
        self = original
        self.items = items
    }
    
}
