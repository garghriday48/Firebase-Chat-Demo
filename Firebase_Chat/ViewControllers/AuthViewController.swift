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
    
    var usersArray: [Users] = []
    var signInName = ""
    var signInCompany = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authType = .signUp
        onScreenType = .signUp
        changeBtn.setTitle(Constants.Heading.signIn, for: .normal)
        FirebaseManager.shared.getUsers { [weak self] (status, users) in
            if status {
                guard let users = users else { return }
                for user in users {
                    guard let userData = Users(dictionary: user) else { continue }
                    self?.usersArray.append(userData)
                }
                
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        var message: String = ""
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            
            switch onScreenType {
                
            case .signUp:
                Auth.auth().createUser(withEmail: email, password: password) {(authResult, _) in
                    
                    if let user = authResult?.user {
                       
                        let userData = Users(id: user.uid, name: self.nameTextfield.text ?? "", company: self.companyTextField.text ?? "", email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
                        
                        
                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isUserSignedUp)
                        
                        if let contentData = try? JSONEncoder().encode(userData) {
                            UserDefaults.standard.set(contentData, forKey: Constants.UserDefaultsKeys.userInfo)
                        }
                        
                        
                        FirebaseManager.shared.addUsers(userId: userData.id, data: userData.dictionary) { (status) in
                            let isUserSignedIn = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isUserSignedUp)
                            
                            if status && isUserSignedIn {
                                let ChannelVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Identifier.channelVc) as? ChannelsViewController
                                self.navigationController?.pushViewController(ChannelVC!, animated: true)
                            }
                        }
                    } else {
                        message = "User already created\nSign in to continue."
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: Constants.Buttons.ok, style: .cancel, handler: nil))
                    
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                }
            case .signIn:
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    
                    if error != nil {
                        message = "There was an error."
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: Constants.Buttons.ok, style: .cancel, handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        guard let user = result?.user else { return }
                        if self.usersArray.contains(where: { user in
                            self.signInName = user.name
                            self.signInCompany = user.company
                            return user.email == self.emailTextField.text
                        }){
                            let userData = Users(id: user.uid, name: self.signInName, company: self.signInCompany, email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
                            
                            
                            UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isUserSignedUp)
                            
                            if let contentData = try? JSONEncoder().encode(userData) {  UserDefaults.standard.set(contentData, forKey: Constants.UserDefaultsKeys.userInfo) }
                            let ChannelVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Identifier.channelVc) as? ChannelsViewController
                            self.navigationController?.pushViewController(ChannelVC!, animated: true)
                        }
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
            
            headingLabel.text = Constants.Heading.signUp
            changeBtn.setTitle(Constants.Heading.signIn, for: .normal)
            onScreenType = .signUp
            authType = .signIn
            
        case .signIn:
            nameLabel.isHidden = true
            nameTextfield.isHidden = true
            
            companyLabel.isHidden = true
            companyTextField.isHidden = true
            
            headingLabel.text = Constants.Heading.signIn
            changeBtn.setTitle(Constants.Heading.signUp, for: .normal)
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
