//
//  PropertyWrapper.swift
//  MaumLog
//
//  Created by 신정욱 on 8/8/24.
//

import Foundation

@propertyWrapper
struct BoolStorage{
    let key: String
    let defaultValue: Bool
    
    var wrappedValue: Bool{
        get{
            UserDefaults.standard.register(defaults: [key : defaultValue])
            return UserDefaults.standard.bool(forKey: key)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    init(_ key: String, _ defaultValue: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
