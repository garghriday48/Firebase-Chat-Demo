//
//  ChatUser.swift
//  Firebase_Chat
//
//  Created by Pragath on 25/08/23.
//

import Foundation
import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
