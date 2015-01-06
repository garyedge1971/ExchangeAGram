//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Gary Edgcombe on 21/12/2014.
//  Copyright (c) 2014 Gary Edgcombe Code. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    // MARK: - Login View Delegate Methods
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("Error:\(error.localizedDescription)")
        
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println(user)
        
        self.profileNameLabel.text = user.name
        
        let userImageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=small"
        
        let url = NSURL(string: userImageURL)
        let imageData = NSData(contentsOfURL: url!)
        
        let image = UIImage(data: imageData!)
        self.profileImageView.image = image
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        self.profileImageView.hidden = false
        self.profileNameLabel.hidden = false
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        self.profileImageView.hidden = true
        self.profileNameLabel.hidden = true
    }
}
