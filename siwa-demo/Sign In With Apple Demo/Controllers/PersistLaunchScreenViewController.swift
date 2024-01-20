//
//  PersistLaunchScreenViewController.swift
//  Sign In With Apple Demo
//
//  Created by n8thnl on 12/26/23.
//

import UIKit

class PersistLaunchScreenViewController: UIViewController {
    
    let typewriterTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(typewriterTextLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addConstraints([
            typewriterTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typewriterTextLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        typewriterTextLabel.setTyping(text: "Thank you for coming")
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
            self.typewriterTextLabel.unsetTyping(reverse: true)
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                let signInViewController = SignInViewController()
                signInViewController.modalPresentationStyle = .fullScreen
                self.present(signInViewController, animated: true, completion: nil)
            }

        }
        
    }


}
