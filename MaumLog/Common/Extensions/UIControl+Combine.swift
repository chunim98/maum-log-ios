//
//  UIControl+Combine.swift
//  MaumLog
//
//  Created by 신정욱 on 4/14/25.
//

import UIKit
import Combine

extension UIControl {
    
    func publisher(for event: UIControl.Event) -> UIControlPublisher {
        UIControlPublisher(control: self, event: event)
    }
    
    // MARK: - UIControlSubscription
    
    final class UIControlSubscription<S: Subscriber>: Subscription
    where S.Input == UIControl, S.Failure == Never {
        
        // MARK: Properties
        
        private var subscriber: S?
        private let event: UIControl.Event
        private let control: UIControl
        
        // MARK: Initalizer
        
        init(subscriber: S, event: UIControl.Event, control: UIControl) {
            self.subscriber = subscriber
            self.event = event
            self.control = control
            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        // MARK: Methods
        
        @objc private func handleEvent() { _ = subscriber?.receive(control) }
        
        // 사용 안 함 (handleEvent에 이벤트 전달 로직을 위임)
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            subscriber = nil
            control.removeTarget(self, action: #selector(handleEvent), for: event)
        }
    }
    
    // MARK: - UIControlPublisher
    
    struct UIControlPublisher: Publisher {
        
        // MARK: Typealias
        
        typealias Output = UIControl
        typealias Failure = Never
        
        // MARK: Properties
        
        private let control: UIControl
        private let event: UIControl.Event
        
        // MARK: Initializer
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        // MARK: Methods
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Never == S.Failure, UIControl == S.Input {
            let subscription = UIControlSubscription(
                subscriber: subscriber,
                event: event,
                control: control
            )
            subscriber.receive(subscription: subscription)
        }
    }
}
