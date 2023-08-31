//
//  FirebaseManager.swift
//  Firebase_Chat
//
//  Created by Pragath on 24/08/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager {
    
    static var shared = FirebaseManager()
    private init() {
        
    }
    
    var docReference: DocumentReference?
    var lastQuerySnapshot: DocumentSnapshot?
    
    var docRefArray = [(String,DocumentReference)]()
    
    let db = Firestore.firestore()
    
    
    func addUsers(userId:String, data: [String:Any], completion: @escaping (Bool) -> Void) {
        db.collection(Constants.Firebase.userCollection).document(userId).setData(data) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(false)
                } else {
                    //print("Document added with ID: \(ref!.documentID)")
                    completion(true)
                }
        }
    }
    
    func getUsers(completion: @escaping (Bool, [[String:Any]]?) -> Void){
        var users = [[String:Any]]()
        db.collection(Constants.Firebase.userCollection).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting Users: \(err)")
                completion(false, nil)
            } else {
                for document in querySnapshot!.documents {
                    let user = document.data()
                    users.append(user)
                }
                completion(true, users)
            }
        }
    }
    
    func createNewChannel(channelId: String, channelData: [String:Any], completion: @escaping (Bool) -> Void) {
        
        let db = Firestore.firestore().collection(Constants.Firebase.chatCollection)
        db.document(channelId).setData(channelData){ (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                completion(false)
            } else {
               completion(true)
            }
        }
    }
    
    func loadChannels(completion: @escaping (Bool, [[String:Any]]?) -> Void) {
        
        var channelData = [[String:Any]]()
        var userId = ""
        
        if let user = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.userInfo) as? Data,
           let userInfo = try? JSONDecoder().decode(Users.self, from: user) {
            userId = userInfo.id
        }
        //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection(Constants.Firebase.chatCollection)
            .order(by: "createdAt", descending: true)
            .whereFilter(Filter.orFilter([
                            Filter.whereField("senderId", isEqualTo: userId),
                            Filter.whereField("receiverId", isEqualTo: userId)
                        ]))
        completion(false, nil)
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false, nil)
            } else {
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else { return }
                
                self.docRefArray = []
                for doc in chatQuerySnap!.documents {
                    self.docRefArray.append((doc.documentID, doc.reference))
                }
                
                if queryCount >= 1 {
                    if channelData.count > 0 {
                        guard let firstChannelData = chatQuerySnap!.documents.first?.data() else {return}
                        channelData.insert(firstChannelData , at: 0)
                        
                        completion(true, [firstChannelData])
                    } else {
                    //Chat(s) found for currentUser
                        for doc in chatQuerySnap!.documents {
                            let data = doc.data()
                            channelData.insert(data, at: 0)
                            // to get the reference of document to directly add messages to it.
                            //                            self.docReference = doc.reference
                            //self.docRefArray.append((doc.documentID, doc.reference))
                        }
                        completion(true, channelData)
                    } //end of for
                } else {
                    completion(false, nil)
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
    
    func loadChat(docReference: DocumentReference, completion: @escaping (Bool, [[String:Any]]?) -> Void){
        //fetch it's thread collection
        var chatData = [[String:Any]]()
        
        //query through which access data related to particular chat
        let query = docReference.collection(Constants.Firebase.msgCollection)
            .order(by: "created", descending: false)

        //Snapshot listener to listen for any changes that happens in particular collection
        //as given by above defined query.
        query.addSnapshotListener({ (threadQuery, error) in

                if let error = error {
                    print("Error: \(error)")
                    completion(false, nil)
                } else {
                    //Check if its first time - all data is send,
                    // else - only the added data is send
                    //so that all the data is not reloaded again whenever data is sent to database.
                    if chatData.count > 0 {
                        guard let lastElementData = threadQuery!.documents.last?.data() else { return }
                        chatData.append(lastElementData)
                        completion(true, [lastElementData])
                    } else {
                        for message in threadQuery!.documents {
                            let data = message.data()
                            chatData.append(data)
                            print("Data: \(data)")
                        }
                        completion(true, chatData)
                    }
                    
                }
            })
    }
    
    func saveMessage(_ message: [String:Any], docReference: DocumentReference, completion: @escaping (Bool) -> Void) {
        //Writing it to the thread using the saved document reference we saved in load chat function
        docReference.collection(Constants.Firebase.msgCollection).addDocument(data: message, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
}

