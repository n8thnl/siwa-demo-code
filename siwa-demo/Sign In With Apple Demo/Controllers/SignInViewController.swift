//
//  SignInViewController.swift
//  Sign In With Apple Demo
//
//  Created by n8thnl on 12/26/23.
//

import UIKit
import AuthenticationServices

class SignInViewController: UIViewController {
    
    let largeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let smallLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.cornerRadius = 10.0
        button.alpha = 0.0
        button.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var errorMessage: UILabel = {
        let label = UILabel()
        label.alpha = 0.0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    lazy var loadingOverlay: UIView = {
        let v = UIView()
        v.addSubview(self.loadingSpinner)
        v.backgroundColor = .systemBackground
        v.alpha = 0.0
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        view.addSubview(largeLabel)
        view.addSubview(smallLabel)
        view.addSubview(signInButton)
        view.addSubview(errorMessage)
        view.addSubview(loadingOverlay)
        
    }
    
    override func viewDidLayoutSubviews() {
        view.addConstraints([
            largeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            largeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            
            smallLabel.topAnchor.constraint(equalTo: largeLabel.bottomAnchor, constant: 10),
            smallLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            signInButton.heightAnchor.constraint(equalToConstant: 50),

            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            errorMessage.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -20),
            errorMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        loadingOverlay.addConstraints([
            loadingSpinner.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        largeLabel.setTyping(text: "Sign in with Apple")
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.smallLabel.setTyping(text: "Demo by n8thnl")
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.signInButton.alpha = 1.0
                    }
                }
            }
        }
    }
    
    @objc func didTapSignInButton() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage.text = message
            self.loadingOverlay.alpha = 0.0
            self.loadingSpinner.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                self.errorMessage.alpha = 1.0
            }
        }
    }
    
}
    
extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error occurred retrieving apple id authorization")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            
            let firstName: String = appleIdCredential.fullName?.givenName ?? ""
            let lastName: String = appleIdCredential.fullName?.familyName ?? ""
            
            DispatchQueue.main.async {
                self.loadingOverlay.alpha = 0.7
                self.loadingSpinner.startAnimating()
            }
            
            print("if the following variables are empty-strings, you may need to Erase all Content on the simulator")
            print("and remove this test app from using SIWA under Settings -> Apple ID (top section) -> Password and Security -> Sign In With Apple")
            print("firstName: \(firstName)")
            print("lastName: \(lastName)")
            
            guard let authCode = appleIdCredential.authorizationCode else { return }
            
            // make call to /token
            Api.getJwt { data, _, error in
                
                var jwtJson: NSDictionary?
                do {
                    jwtJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                } catch {
                    // unable to parse string into json object
                    print("unable to parse data")
                    return
                }
                
                guard let client_secret = jwtJson!["token"] as? String else {
                    DispatchQueue.main.async {
                        self.showError(message: "An error occurred in the call to /jwt")
                    }
                    return
                }
                
                Api.getToken(client_id: "com.n8thnl.Sign-In-With-Apple-Demo", client_secret: client_secret, code: String(decoding: authCode, as: UTF8.self)) { (data, _, error) in
                    
                    var appleToken: NSDictionary?
                    do {
                        appleToken = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    } catch {
                        print("unable to parse appleToken data")
                        return
                    }
                    
                    guard let idToken = appleToken!["id_token"] as? String else {
                        DispatchQueue.main.async {
                            self.showError(message: "An error occurred in the Post call to /token")
                        }
                        return
                    }
                    
                    Api.postUser(idToken: idToken, firstName: firstName, lastName: lastName) { (data, _, error) in
                        
                        DispatchQueue.main.async {
                            var userData: NSDictionary?
                            do {
                                userData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                            } catch {
                                print("unable to parse user data")
                                return
                            }
                            
                            guard let userAttrs = userData!["userAttrs"] as? [String : String] else {
                                DispatchQueue.main.async {
                                    self.showError(message: "An error occurred in the Post call to /user")
                                }
                                return
                            }
                        
                            let welcomeViewController = WelcomeViewController(userAttrs: userAttrs)
                            welcomeViewController.modalPresentationStyle = .fullScreen
                            self.present(welcomeViewController, animated: true, completion: nil)
                        }
                        
                    }
                }
            }
            
        default:
            // credential is different than expected
            break
        }
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
