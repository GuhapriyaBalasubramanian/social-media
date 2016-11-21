//
//  PostCell.swift
//  social-media
//
//  Created by Guhapriya Balasubramanian on 17/11/2016.
//  Copyright © 2016 Guhapriya Balasubramanian. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var firBaseRef: FIRDatabaseReference!
    var firBaseRef1: FIRDatabaseReference!
    var firData: FIRDataSnapshot!
    var postUserKey = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("GUHA: Unable to download image from Firebase storage")
                } else {
                    print("GUHA: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
        
       
        
        //populate the user name label
        firBaseRef = DataService.ds.REF_POSTS.child(post.postKey)
        firBaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userKey = snapshot.childSnapshot(forPath: "userKey") as? FIRDataSnapshot{
               
                if let currentUserKey = userKey.value as? NSString {
                //print("GUHA: currentUserKey - \(currentUserKey)")
                    self.postUserKey = currentUserKey as String
                }
                
                //Now get the useerName corresponding to the user in the post->userKey
                self.firBaseRef1 = DataService.ds.REF_USERS.child(self.postUserKey)
                self.firBaseRef1.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let userInfo = snapshot.childSnapshot(forPath: "userName") as? FIRDataSnapshot{
                        
                        if let currentUser = userInfo.value as? NSString {
                            //print("GUHA: currentUser - \(currentUser)")
                            self.usernameLbl.text = currentUser as String
                        }
                    }
                    
                })
            }
            
        })
        
        
       
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
}
