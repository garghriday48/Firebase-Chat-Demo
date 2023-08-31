//
//  dataModel.swift
//  Firebase_Chat
//
//  Created by Pragath on 24/08/23.
//

import Foundation


struct People {
    var id: String
    var name: String
    var country: String
}


struct Users: Codable {
    var id: String
    var name: String
    var company: String
    var email: String
    var password: String
    
    var dictionary: [String: Any] {
    return [
        "id": id,
        "name": name,
        "company": company,
        "email": email,
        "password": password
    ]}
}

extension Users {
init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
        let name = dictionary["name"] as? String,
        let company = dictionary["company"] as? String,
        let email = dictionary["email"] as? String,
        let password = dictionary["password"] as? String
        else {return nil}
        
    self.init(id: id, name: name, company: company, email: email, password: password)
    }
}
