//
//  ChannelsViewController.swift
//  Firebase_Chat
//
//  Created by Pragath on 28/08/23.
//

import UIKit
import FirebaseAuth
import Firebase

class ChannelsViewController: UIViewController {
    
    @IBOutlet weak var channelsTableView: UITableView!
    
    var usersArray: [Users] = []
    var userId = ""
    
    var channelData = Channel.initialize
    var allChannels: [Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllChannels()
        FirebaseManager.shared.getUsers { [weak self] (status, users) in
            if status {
                guard let users = users else { return }
                for user in users {
                    guard let userData = Users(dictionary: user) else { continue }
                    self?.usersArray.append(userData)
                }
            }
        }
                 
                 
        let rightBarButtonItem = UIBarButtonItem(title:  Constants.Heading.logOut, style: .plain, target: self, action: #selector(logOut))
       let rightButton2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannel))
         
       navigationItem.rightBarButtonItems = [rightBarButtonItem,rightButton2]
        navigationItem.setHidesBackButton(true, animated: true)
        
        rightBarButtonItem.tintColor = .red
    }
    override func viewWillAppear(_ animated: Bool) {
        if let user = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.userInfo) as? Data,
           let userInfo = try? JSONDecoder().decode(Users.self, from: user) {
            self.userId = userInfo.id
        }
    }
    
    func getAllChannels() {
        
        FirebaseManager.shared.loadChannels { (status, channelArray)  in
            if status {
                if let chlArray = channelArray{
                    for channel in chlArray {
                        guard let channel = Channel(dictionary: channel) else { continue }
                        self.allChannels.append(channel)
                    }
                    self.channelsTableView.reloadData()
                }
            } else {
                print("No Channels found")
            }
        }
    }
                                                              
    @objc func logOut() {
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKeys.isUserSignedUp)
            
            let storyboard = UIStoryboard(name: Constants.Identifier.mainStoryboard, bundle: nil)
            UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: Constants.Identifier.authVc) as? AuthViewController ?? UIViewController())
            
        } catch {
            print("not able to logout")
        }
        
        
    }

    @objc func addChannel() { 
        let alertController = UIAlertController(title: Constants.Heading.addChat, message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = Constants.Placeholder.enterName
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = Constants.Placeholder.enterCompany
        }
        

        let saveAction = UIAlertAction(title: Constants.Buttons.save, style: .default, handler: { _ -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            
            var receiverId = ""
            
            if self.usersArray.contains(where: { user in
                receiverId = user.id
                return firstTextField.text == user.name
            }) {
                if let user = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.userInfo) as? Data,
                   let userInfo = try? JSONDecoder().decode(Users.self, from: user) {
                    
                    self.channelData = Channel(id: UUID().uuidString, senderId: userInfo.id, receiverId: receiverId, senderName: userInfo.name, receiverName: firstTextField.text ?? "", senderCompany: userInfo.company, receiverCompany: secondTextField.text ?? "", createdAt: Timestamp(date: Date()))
                    
                    FirebaseManager.shared.createNewChannel(channelId: self.channelData.id, channelData: self.channelData.dictionary, completion: { (status) in
                        if status {  self.getAllChannels() }
                    })
                    
                }
            } else {
                self.showAlert(alertTitle: Constants.Heading.userNotFound , alertMsg: Constants.Alerts.needToSignInSignUp, btnTitle: Constants.Buttons.ok)
            }
                
        
        })

        let cancelAction = UIAlertAction(title: Constants.Buttons.cancel, style: .default, handler: nil )

    
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    
    /// To show alert with just a single button
    /// - Parameters:
    ///   - alertTitle: to set alert's main title
    ///   - alertMsg: to set alert's secondary title
    ///   - btnTitle: to set alert's button title
    func showAlert(alertTitle: String, alertMsg: String, btnTitle: String) {
            let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
              
            alert.addAction(UIAlertAction(title: btnTitle,
                                          style: UIAlertAction.Style.default,
                                          handler: nil))
             
            DispatchQueue.main.async {
                self.present(alert, animated: false, completion: nil)
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

extension ChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChannels.count
    }

    //to display name and company based on condition
    //which user is signed in currently
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channelCell = self.channelsTableView.dequeueReusableCell(withIdentifier: Constants.Identifier.channelCell, for: indexPath) as? ChannelTableViewCell
        guard let channelCell = channelCell else {return UITableViewCell()}
        channelCell.nameLabel.text = (self.userId == allChannels[indexPath.row].senderId ? allChannels[indexPath.row].receiverName : allChannels[indexPath.row].senderName)
        channelCell.companyLabel.text = self.userId == allChannels[indexPath.row].senderId ? allChannels[indexPath.row].receiverCompany : allChannels[indexPath.row].senderCompany
        
        return channelCell
    }
    
    //to navigate to chat room when tapped on any cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Identifier.chatVc) as? ChatViewController
        guard let chatVC = chatVC else {return}
        chatVC.channelData = allChannels[indexPath.row]
        chatVC.viewTitle = (self.userId == allChannels[indexPath.row].senderId ? allChannels[indexPath.row].receiverName : allChannels[indexPath.row].senderName)
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }

}
