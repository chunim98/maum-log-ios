//
//  Coordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/16/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var parent: Coordinator? { get set } // 이미 부모가 배열에 넣어 강하게 참조하기 때문에 ,자식은 부모를 약하게 참조해야함
    var childrens: [Coordinator] { get set } // 자식을 배열에 넣어 강한 참조를 유지
    var navigationController : UINavigationController { get }
    
    func start()
}

extension Coordinator {
    /// 자식 코디네이터를 제거합니다. 이 호출은 메모리 누수를 예방하기 때문에 중요합니다.
    /// - Parameter coordinator: Coordinator that finished.
    func childDidFinish(_ coordinator : Coordinator) {
        // Call this if a coordinator is done.
        for (index, child) in childrens.enumerated() {
            if child === coordinator {
                childrens.remove(at: index)
                break
            }
        }
    }
}
