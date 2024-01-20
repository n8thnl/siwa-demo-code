//
//  Extensions.swift
//  Sign In With Apple Demo
//
//  Created by n8thnl on 12/26/23.
//

import UIKit

extension UIViewController {
    
    func safeAreaBottom() -> CGFloat? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        
        return window?.safeAreaInsets.bottom
    }
    
    func safeAreaTop() -> CGFloat? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        
        return window?.safeAreaInsets.top
    }
    
}

/*
 https://stackoverflow.com/questions/27736360/typewriter-effect-text-animation
 */
extension UILabel {
    
    func setTyping(text: String, characterDelay: TimeInterval = 5.0) {
        self.text = ""
        
        let writingTask = DispatchWorkItem { [weak self] in
            text.forEach { char in
                DispatchQueue.main.async {
                    self?.text?.append(char)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        
        let queue: DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
        queue.asyncAfter(deadline: .now() + 0.05, execute: writingTask)
    }
    
    func unsetTyping(reverse: Bool = false, characterDelay: TimeInterval = 5.0) {
        guard let count = self.text?.count else { return }
        let writingTask = DispatchWorkItem { [weak self] in
            for _ in 0...count-1 {
                DispatchQueue.main.async {
                    if (reverse) {
                        self?.text?.removeLast()
                    } else {
                        self?.text?.removeFirst()
                    }
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        
        let queue: DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
        queue.asyncAfter(deadline: .now() + 0.05, execute: writingTask)
    }
    
}
