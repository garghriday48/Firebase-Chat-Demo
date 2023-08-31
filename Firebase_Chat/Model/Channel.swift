//
//  Chat.swift
//  Firebase_Chat
//
//  Created by Pragath on 25/08/23.
//

import Foundation
import UIKit
import Firebase

struct Channel {
    var id: String
    var senderId: String
    var receiverId: String
    var senderName: String
    var receiverName: String
    var senderCompany: String
    var receiverCompany: String
    var createdAt: Timestamp
    
    var dictionary: [String: Any] {
    return [
        "id": id,
        "senderId": senderId,
        "receiverId": receiverId,
        "senderName": senderName,
        "receiverName": receiverName,
        "senderCompany": senderCompany,
        "receiverCompany": receiverCompany,
        "createdAt": createdAt
    ]}
}

extension Channel {
    init?(dictionary: [String:Any]) {
        guard let id = dictionary["id"] as? String,
              let senderId = dictionary["senderId"] as? String,
              let receiverId = dictionary["receiverId"] as? String,
              let senderName = dictionary["senderName"] as? String,
              let senderCompany = dictionary["senderCompany"] as? String,
              let receiverName = dictionary["receiverName"] as? String,
              let receiverCompany = dictionary["receiverCompany"] as? String,
              let createdAt = dictionary["createdAt"] as? Timestamp
        else {return nil}
        
        self.init(id: id, senderId: senderId, receiverId: receiverId, senderName: senderName, receiverName: receiverName, senderCompany: senderCompany, receiverCompany: receiverCompany, createdAt: createdAt)
    }
    
    static var initialize = Channel(id: "1", senderId: "1", receiverId: "2", senderName: "Hriday", receiverName: "Himanshu", senderCompany: "Chicmic", receiverCompany: "Chicmic1", createdAt: Timestamp(date: Date()))
}
