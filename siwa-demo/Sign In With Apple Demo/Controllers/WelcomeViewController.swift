//
//  WelcomeViewController.swift
//  Sign In With Apple Demo
//
//  Created by n8thnl on 12/26/23.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(userAttrs: [String:String]) {
        self.email = userAttrs["email"]!
        self.firstName = userAttrs["firstName"]!
        self.lastName = userAttrs["lastName"]!
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        view.addSubview(nameLabel)
        view.addSubview(messageLabel)
    }
    
    override func viewDidLayoutSubviews() {
        view.addConstraints([
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 100),
            messageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            messageLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameLabel.setTyping(text: "Hello, \(firstName == "" ? "Anonymous user" : firstName)")
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            let message = self.firstName == "" ? "You did, however, provide your email as\n\(self.email)" : "The email you provided was \n\(self.email)"
            self.messageLabel.setTyping(text: message)
        }
    }

}
