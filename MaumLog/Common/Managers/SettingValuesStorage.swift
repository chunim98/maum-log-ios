//
//  SettingValuesStorage.swift
//  MaumLog
//
//  Created by 신정욱 on 8/11/24.
//

import UIKit

final class SettingValuesStorage {
    static let shared = SettingValuesStorage()
    private init() {}
    
    @BoolStorage("showLogVCAtStart", false) var showLogVCAtStart: Bool // 시작 시 로그뷰를 보여줄것인가
    @BoolStorage("isAscendingOrder", false) var isAscendingOrder: Bool // 로그가 오름차순 정렬인가

}
