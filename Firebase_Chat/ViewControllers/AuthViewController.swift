//
//  AuthViewController.swift
//  Firebase_Chat
//
//  Created by Pragath on 28/08/23.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {

    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    @IBOutlet weak var changeBtn: UIButton!
    
    var authType = AuthType.signUp
    var onScreenType = AuthType.signUp
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authType = .signUp
        onScreenType = .signUp
        changeBtn.setTitle("Sign In", for: .normal)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        var message: String = ""
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            
            switch onScreenType {
                
            case .signUp:
                Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
                    
                    if let user = authResult?.user {
                       
                        let userData = Users(id: user.uid, name: self.nameTextfield.text ?? "", company: self.companyTextField.text ?? "", email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
                        
                        
                        UserDefaults.standard.set(true, forKey: "isUserSignedUp")
                        
                        if let contentData = try? JSONEncoder().encode(userData) {
                            UserDefaults.standard.set(contentData, forKey: "userInfo")
                        }
                        
                        
                        FirebaseManager.shared.addUsers(data: userData) { (status) in
                            let isUserSignedIn = UserDefaults.standard.bool(forKey: "isUserSignedUp")
                            
                            if status && isUserSignedIn {
                                let ChannelVC = self.storyboard?.instantiateViewController(withIdentifier: "ChannelsVC") as! ChannelsViewController
                                self.navigationController?.pushViewController(ChannelVC, animated: true)
                            }
                        }
                    } else {
                        message = "User already created\nSign in to continue."
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                }
            case .signIn:
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    
                    if error != nil {
                       message = "There was an error."
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        guard let user = result?.user else { return }
                        let userData = Users(id: user.uid, name: self.nameTextfield.text ?? "", company: self.companyTextField.text ?? "", email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
                        
                        
                        UserDefaults.standard.set(true, forKey: "isUserSignedUp")
                        
                        if let contentData = try? JSONEncoder().encode(userData) {
                            UserDefaults.standard.set(contentData, forKey: "userInfo")
                        }
                        let ChannelVC = self.storyboard?.instantiateViewController(withIdentifier: "ChannelsVC") as! ChannelsViewController
                        self.navigationController?.pushViewController(ChannelVC, animated: true)
                    }
                }
            }
        }
    }
    
    
    @IBAction func changeBtnAction(_ sender: Any) {
        //setUp()
        switch authType {
        case .signUp:
            nameLabel.isHidden = false
            nameTextfield.isHidden = false
            
            companyLabel.isHidden = false
            companyTextField.isHidden = false
            
            headingLabel.text = "Sign Up"
            changeBtn.setTitle("Sign In", for: .normal)
            onScreenType = .signUp
            authType = .signIn
            
        case .signIn:
            nameLabel.isHidden = true
            nameTextfield.isHidden = true
            
            companyLabel.isHidden = true
            companyTextField.isHidden = true
            
            headingLabel.text = "Sign In"
            changeBtn.setTitle("Sign Up", for: .normal)
            onScreenType = .signIn
            authType = .signUp
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
