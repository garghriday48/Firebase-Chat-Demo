//
//  FirebaseAuthManager.swift
//  Firebase_Chat
//
//  Created by Pragath on 29/08/23.
//

import Foundation
import FirebaseAuth

class FirebaseAuthManager {
    
    static var shared = FirebaseAuthManager()
    private init() {
        
    }
    
    func createUser(email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
            Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
                if let user = authResult?.user {
                    print(user)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
 
    func signIn(email: String, pass: String, completion: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
}
