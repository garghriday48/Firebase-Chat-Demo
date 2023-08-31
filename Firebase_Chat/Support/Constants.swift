//
//  Constants.swift
//  Firebase_Chat
//
//  Created by Pragath on 31/08/23.
//

import Foundation


struct Constants {
    
    struct Firebase {
        static var userCollection = "Users"
        static var chatCollection = "Chats"
        static var msgCollection  = "thread"
    }
    
    struct UserDefaultsKeys {
        static var userInfo = "userInfo"
        static var isUserSignedUp = "isUserSignedUp"
    }
    
    struct Heading {
        static var signIn = "Sign In"
        static var signUp = "Sign Up"
        static var logOut = "Log Out"
        static var addChat = "Add Chat"
        static var userNotFound = "User Not Found"
    }
    
    struct Identifier {
        static var channelVc = "ChannelsVC"
        static var authVc = "AuthVC"
        static var chatVc = "ChatVC"
        
        static var channelCell = "ChannelCell"
        
        static var mainStoryboard = "Main"
    }
    
    struct Buttons {
        static var save = "Save"
        static var cancel = "Cancel"
        static var ok = "Ok"
        
    }
    
    struct Placeholder {
        static var enterName = "Enter Name"
        static var enterCompany = "Enter Company"
    }
    
    struct Alerts {
        static var needToSignInSignUp = "Both users need to sign in or sign up before chatting."
    }
}
