//
//  HapticManager.swift
//  MaumLog
//
//  Created by 신정욱 on 8/22/24.
//

import UIKit

final class HapticManager{
    static let shared = HapticManager()
    
    private let ligthFeedback = UIImpactFeedbackGenerator(style: .light)
    private let rigidFeedback = UIImpactFeedbackGenerator(style: .rigid)
    private let successFeedback = UINotificationFeedbackGenerator()
    private let selectFeedback = UISelectionFeedbackGenerator()
    
    
    private init() {}
    
    func occurLight(){
        ligthFeedback.impactOccurred()
    }
    
    func occurRigid(){
        rigidFeedback.impactOccurred(intensity: 0.75)
    }
    
    func occurSuccess(){
        successFeedback.notificationOccurred(.success)
    }
    
    func occurSelect(){
        selectFeedback.selectionChanged()
    }
}
