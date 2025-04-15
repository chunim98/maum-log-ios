//
//  UITextField+.swift
//  MaumLog
//
//  Created by 신정욱 on 4/15/25.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap{ $0.object as? UITextField }
        .map{ $0.text ?? "" }
        .eraseToAnyPublisher()
    }
}
