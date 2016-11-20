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
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    private var _userName: String!
    private var _provider: String!
    private var _userKey: String!
    private var _usersRef: FIRDatabaseReference!
    
    
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
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        _postRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
    
   
    
}
