//
//  ChatViewController.swift
//  Firebase_Chat
//
//  Created by Pragath on 25/08/23.
//

import UIKit
import InputBarAccessoryView
import FirebaseFirestore
import MessageKit

class ChatViewController: MessagesViewController,InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var docReference: DocumentReference?
    var messages: [Message] = []
    
    
    var channelData = Channel.initialize
    
    var senderId = ""
    var senderName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
       
        
        getAllMessages()
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        //to decode data that is saved in user defaults
        //for key named ' userInfo ' which returns object as Data.
        if let user = UserDefaults.standard.object(forKey: "userInfo") as? Data,
           let userInfo = try? JSONDecoder().decode(Users.self, from: user) {
            
            //to set senderId and senderName based on which user is signed in
            if userInfo.id == self.channelData.senderId {
                self.senderId = userInfo.id
                self.senderName = userInfo.name
            } else {
                self.senderId = self.channelData.receiverId
                self.senderName = self.channelData.receiverName
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.messagesCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    
    /// To get all messages inside a particular chat room.
    func getAllMessages() {
        guard let docRef = self.docReference else { return }
        FirebaseManager.shared.loadChat(docReference: docRef) { [weak self] (status, messageArray) in
            if status {
                if let msgArray = messageArray{
                    self?.messages = msgArray
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
            }
        }
    }
    
    
    /// To save message in database when user send the message
    /// - Parameter message: as ' Message ' to be saved in databse
    func saveMessage(message: Message) {
        guard let docRef = self.docReference else { return }
        FirebaseManager.shared.saveMessage(message, docReference: docRef) { [weak self] (status) in
            if status {
               self?.messagesCollectionView.reloadData()
               self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        }
    }
        
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: String(self.senderId), senderName: self.senderName)
        //calling function to insert and save message
        self.saveMessage(message: message)
        //clearing input field
        inputBar.inputTextView.text = ""

    }
    
    //to tell details about the sender in chat room
    func currentSender() -> MessageKit.SenderType {
        return ChatUser(senderId: String(self.senderId), displayName: String(self.senderName))
    }
    
    //getting the message at each index
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    //number of messages to be shown
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
    
    // We want the default avatar size. This method handles the size of the avatar of user that'll be displayed with message
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return .zero
    }
    
    //Styling the bubble to have a tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    //Background color for sender and receiver message
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue : .systemGray4
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
