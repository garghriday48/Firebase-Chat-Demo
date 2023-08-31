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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllChannels()
        FirebaseManager.shared.getUsers { [weak self] (status, users) in
            if status {
                guard let users = users else { return }
                self?.usersArray = users
            }
        }
                 
                 
       let rightBarButtonItem = UIBarButtonItem(title:  "Log Out", style: .plain, target: self, action: #selector(logOut))
       let rightButton2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannel))
         
       navigationItem.rightBarButtonItems = [rightBarButtonItem,rightButton2]
        navigationItem.setHidesBackButton(true, animated: true)
        
        rightBarButtonItem.tintColor = .red
    }
    override func viewWillAppear(_ animated: Bool) {
        if let user = UserDefaults.standard.object(forKey: "userInfo") as? Data,
           let userInfo = try? JSONDecoder().decode(Users.self, from: user) {
            self.userId = userInfo.id
        }
    }
    
    func getAllChannels() {
        
        FirebaseManager.shared.loadChannels { (status) in
            if status {
                self.channelsTableView.reloadData()
            } else {
                print("No Channels found")
            }
        }
    }
                                                              
    @objc func logOut() {
        do{
            try Auth.auth().signOut()
            FirebaseManager.shared.channels = []
            UserDefaults.standard.set(false, forKey: "isUserSignedUp")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "AuthVC") as! AuthViewController)
            
        } catch {
            print("not able to logout")
        }
        
        
    }

    @objc func addChannel() { 
        let alertController = UIAlertController(title: "Add Chat", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Company"
        }
        

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            
            var receiverId = ""
            
            if self.usersArray.contains(where: { user in
                receiverId = user.id
                return firstTextField.text == user.name
            }) {
                if let user = UserDefaults.standard.object(forKey: "userInfo") as? Data,
                   let userInfo = try? JSONDecoder().decode(Users.self, from: user) {
                    
                    //guard let userInfo = UserDefaults.standard.object(forKey: "userInfo") as? Users else { return }
                    FirebaseManager.shared.createNewChannel(channelData: Channel(id: UUID().uuidString, senderId: userInfo.id, receiverId: receiverId, senderName: userInfo.name, receiverName: firstTextField.text ?? "", senderCompany: userInfo.company, receiverCompany: secondTextField.text ?? "", createdAt: Timestamp(date: Date())), completion: { (status) in
                        if status {  self.getAllChannels() }
                    })
                    
                }
            } else {
                self.showAlert(alertTitle: "User Not Found", alertMsg: "Both users need to sign in before chatting.", btnTitle: "Okay")
            }
                
        
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil )

    
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
        return FirebaseManager.shared.channels.count
    }

    //to display name and company based on condition
    //which user is signed in currently
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channelCell = self.channelsTableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelTableViewCell
        channelCell.nameLabel.text = (self.userId == FirebaseManager.shared.channels[indexPath.row].senderId ? FirebaseManager.shared.channels[indexPath.row].receiverName : FirebaseManager.shared.channels[indexPath.row].senderName)
        channelCell.companyLabel.text = self.userId == FirebaseManager.shared.channels[indexPath.row].senderId ? FirebaseManager.shared.channels[indexPath.row].receiverCompany : FirebaseManager.shared.channels[indexPath.row].senderCompany
        
        return channelCell
    }
    
    //to navigate to chat room when tapped on any cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        chatVC.channelData = FirebaseManager.shared.channels[indexPath.row]
        chatVC.docReference = FirebaseManager.shared.docRefArray[indexPath.row].1
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }

}
