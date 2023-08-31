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
    //var messages = [Message]()
    var channels = [Channel]()
    
    var docRefArray = [(String,DocumentReference)]()
    
    let db = Firestore.firestore()
    
    
    func addUsers(data: Users, completion: @escaping (Bool) -> ()) {
        db.collection("Users").document("\(data.id)").setData(data.dictionary) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(false)
                } else {
                    //print("Document added with ID: \(ref!.documentID)")
                    completion(true)
                }
        }
    }
    
    func getUsers(completion: @escaping (Bool, [Users]?) -> ()){
        var users = [Users]()
        db.collection("Users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting Users: \(err)")
                completion(false, nil)
            } else {
                for document in querySnapshot!.documents {
                    let user = Users(dictionary: document.data())
                    guard let user = user else { return }
                    users.append(user)
                }
                completion(true, users)
            }
        }
    }
    
    func createNewChannel(channelData: Channel, completion: @escaping (Bool) -> ()) {
        let data = channelData.dictionary
        
        let db = Firestore.firestore().collection("Chats")
        db.addDocument(data: data){ (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                completion(false)
            } else {
               completion(true)
            }
        }
    }
    
    func loadChannels(completion: @escaping (Bool) -> ()) {
        var userId = ""
        if let user = UserDefaults.standard.object(forKey: "userInfo") as? Data,
           let userInfo = try? JSONDecoder().decode(Users.self, from: user) {
            userId = userInfo.id
        }
        //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("Chats")
            .order(by: "createdAt", descending: true)
            .whereFilter(Filter.orFilter([
                            Filter.whereField("senderId", isEqualTo: userId),
                            Filter.whereField("receiverId", isEqualTo: userId)
                        ]))
        completion(false)
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false)
            } else {
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else { return }
                
//                if queryCount == 0 {
//                    //If documents count is zero that means there is no chat available and we need to create a new instance
//                    self.createNewChannel(channelData: channelData)
//
//                } else
                if queryCount >= 1 {
                    if self.channels.count > 0 {
                        guard let lastDoc = chatQuerySnap!.documents.first?.data() else {return}
                        guard let channel = Channel(dictionary: lastDoc) else { return }
                        self.channels.append(channel)
                    } else {
                    //Chat(s) found for currentUser
                        for doc in chatQuerySnap!.documents {
                            let channel = Channel(dictionary: doc.data())
                            guard let channel = channel else { return }
                            self.channels.insert(channel, at: 0)
                            // to get the reference of document to directly add messages to it.
                            //                            self.docReference = doc.reference
                            self.docRefArray.append((doc.documentID, doc.reference))
                        }
                    } //end of for
                    completion(true)
                } else {
                    completion(false)
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
    
    func loadChat(docReference: DocumentReference, completion: @escaping (Bool, [Message]?) -> ()){
        //fetch it's thread collection
        var messages = [Message]()
        
        let query = docReference.collection("thread")
            .order(by: "created", descending: false)
            
//                            if let lastQuerySnapshot = self.lastQuerySnapshot {
//                                query?.start(afterDocument: lastQuerySnapshot)
//                            } else {
//                                self.messages.removeAll()
//                            }
        query.addSnapshotListener({ (threadQuery, error) in
                
               // self.lastQuerySnapshot = threadQuery?.documents.last
            
                if let error = error {
                    print("Error: \(error)")
                    completion(false, nil)
                } else {
                    if messages.count > 0 {
                        let msg = Message(dictionary: (threadQuery!.documents.last?.data())!)
                        messages.append(msg!)
                    } else {
                        for message in threadQuery!.documents {
                            let msg = Message(dictionary: message.data())
                            guard let msg = msg else { return }
                            messages.append(msg)
                            print("Data: \(msg.content)")
                            print("\(threadQuery!.documents.count)")
                        }
                    }
                    
                }
                completion(true, messages)
            })
    }
    
    func saveMessage(_ message: Message, docReference: DocumentReference, completion: @escaping (Bool) -> ()) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = message.dictionary
        //Writing it to the thread using the saved document reference we saved in load chat function
        docReference.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
}

