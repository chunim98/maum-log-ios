//
//  UIControl+Combine.swift
//  MaumLog
//
//  Created by 신정욱 on 12/9/24.
//

import UIKit
import Combine

extension UIControl {
    final class InteractionSubscription<S: Subscriber>: Subscription where S.Input == Void {
        
        /// Subscription은 클래스로만 정의되어야 함.
        /// Subscription은 Publisher와 Subscriber의 중간 다리 역할을 함.
        /// 보통은 request(_:)에 값을 방출시키는 로직을 작성해두고,
        /// Subscriber에서 request(_:)를 호출하면 건네받은 demand값에 따라 적절히 값을 방출시킨다.
        /// 하지만 여기서는 그 역할을 handleEvent(_:)가 맡고 있음.

        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event
        
        init(subscriber: S, control: UIControl, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            
            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        @objc func handleEvent(_ sender: UIControl) {
            _ = subscriber?.receive(())
            
            // subscriber?.receive(completion: .finished)
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {}
    }
    
    struct InteractionPublisher: Publisher {
        
        typealias Output = Void
        typealias Failure = Never
        
        private let control: UIControl
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Void == S.Input {

            let subscription = InteractionSubscription(
                subscriber: subscriber,
                control: control,
                event: event
            )
            
            subscriber.receive(subscription: subscription)
        }
    }
    
    func publisher(for event: UIControl.Event) -> UIControl.InteractionPublisher {
         InteractionPublisher(control: self, event: event)
    }
}
