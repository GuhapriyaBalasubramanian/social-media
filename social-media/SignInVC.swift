//
//  ViewController.swift
//  social-media
//
//  Created by Guhapriya Balasubramanian on 17/11/2016.
//  Copyright © 2016 Guhapriya Balasubramanian. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper


class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    var userName = ""
    var users = [Users]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.users = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID){
            print("GUHA: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    
    @IBAction func facebookBtnTapped(_ sender: AnyObject) {
               
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            
            
            if error != nil {
                print("GUHA: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("GUHA: User cancelled Facebook authentication")
            } else {
                print("GUHA: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
                
            }
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name,picture{url}"]).start(completionHandler: { (connection, result, error) -> Void in
                    
                if (error == nil){
                    guard let resultDictionary = result as? [String : AnyObject] else { return }
                    guard let id = resultDictionary["id"] as? String else { return }
                    print("GUHA: fb id \(id)")
                    guard let user = resultDictionary["name"] as? String else { return }
                    self.userName = user
                    print("GUHA: user name \(self.userName)")
                    
                    guard let pic = resultDictionary["picture"] as? [String : AnyObject] else {return}
                    guard let data = pic["data"] as? [String : AnyObject] else { return}
                    guard let url = data["url"] as? String else {return}
                    print("GUHA: url \(url)")
                    
                                        
                    //self.getFacebookProfileImage(userID: id)
                }
            })
            
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("GUHA: Unable to authenticate with Firebase - \(error)")
            } else {
                print("GUHA: Successfully authenticated with Firebase")
                if let user = user {
                    //self.userName = user.email!
                    let userData: Dictionary<String, String> = [
                        "provider": credential.provider as String,
                        "userName": self.userName as String
                        
                    ]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("GUHA: Email user authenticated with Firebase")
                    if let user = user {
                        self.userName = user.email!
                        let userData: Dictionary<String, String> = [
                            "provider": user.providerID as String,
                            "userName": self.userName as String
                            
                        ]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("GUHA: Unable to authenticate with Firebase using email")
                        } else {
                            print("GUHA: Successfully authenticated with Firebase")
                            if let user = user {
                                self.userName = user.email!
                                let userData: Dictionary<String, String> = [
                                    "provider": user.providerID as String,
                                    "userName": self.userName as String
                                    
                                ]
                                 self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String,String>) {
        
        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        
        let provName = userData["provider"]
        
        //Store the values
        let userObj = Users(userName:userName,provider:provName!,userKey:id)
        users.append(userObj)
        
        
        //let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        let keychainResult = KeychainWrapper.defaultKeychainWrapper.set(id, forKey: KEY_UID)
        print("GUHA: Data saved to keychain \(keychainResult)")
        
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
}



