//
//  ViewController.swift
//  biometrics
//
//  Created by Muhammad Hilmy Fauzi on 19/05/20.
//  Copyright © 2020 Muhammad Hilmy Fauzi. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet weak var imgAuth: UIImageView!
    @IBOutlet weak var lblAuth: UILabel!
    @IBOutlet weak var btnAuth: UIButton!
    
    var currentStatus: Status = .Denied
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI(status: currentStatus)
    }
    
    @IBAction func btnAuthPressed(_ sender: Any) {
        if currentStatus == .Denied {
            authenticate()
        } else {
            setupUI(status: .Denied)
        }
    }
    
    func authenticate() {
        let myContext = LAContext()
        var authError: NSError?

        if #available(iOS 8.0, macOS 10.10, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: K.localizedReason) { (success, evaluateError) in
                    DispatchQueue.main.async {
                        if success {
                            self.setupUI(status: .Accepted)
                        } else {
                            self.showAlert(withMessage: K.errorNotMatching)
                        }
                    }
                }
            } else {
                showAlert(withMessage: K.errorNotEnrolled)
            }
        } else {
            showAlert(withMessage: K.errorNotSupported)
        }
    }
    
    func showAlert(withMessage message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.setupUI(status: .Denied)
        }
        alertVC.addAction(action)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func setupUI(status: Status) {
        if status == .Accepted {
            imgAuth.image = UIImage(systemName: "checkmark.shield")
            imgAuth.tintColor = .systemGreen
            lblAuth.text = "Accepted"
            btnAuth.setTitle("Sign Out", for: .normal)
            
            currentStatus = .Accepted
        } else {
            imgAuth.image = UIImage(systemName: "xmark.shield")
            imgAuth.tintColor = .red
            lblAuth.text = "Denied"
            btnAuth.setTitle("Authenticate", for: .normal)
            
            currentStatus = .Denied
        }
    }
}

enum Status {
    case Accepted
    case Denied
}

struct K {
    static let localizedReason = "This app uses Touch ID/Face ID to change your status."
    
    static let errorNotMatching = "Your biometric did not match"
    static let errorNotEnrolled = "Biometrics is not enrolled yet in this device"
    static let errorNotSupported = "Your Device is Not Supported Touch ID/Face ID"
}
