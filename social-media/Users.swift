//
//  Users.swift
//  social-media
//
//  Created by Guhapriya Balasubramanian on 18/11/2016.
//  Copyright © 2016 Guhapriya Balasubramanian. All rights reserved.
//

import Foundation
import Firebase

class Users {
    
    private var _userName: String!
    private var _provider: String!
    private var _userKey: String!
    private var _userRef: FIRDatabaseReference!
    
    
    var userName: String {
        return _userName
    }
    
    var provider: String {
        return _provider
    }
    
    var userKey: String {
        return _userKey
    }
    
    
    init(userName:String,provider:String,userKey:String) {
        self._userName = userName
        self._provider = provider
        self._userKey = userKey
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey

        if let userName = userData["userName"] as? String {
            self._userName = userName
        }
        
        if let provider = userData["provider"] as? String {
            self._provider = provider
        }
        
        _userRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
    
   
    
}
