//
//  ViewController.swift
//  txt4u
//
//  Created by Katlyn Schwaebe on 9/10/14.
//  Copyright (c) 2014 Katlyn Schwaebe. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    @IBOutlet weak var formHolder: UIView!
                            
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    var friend : PFUser! {
        willSet(user) {
        println("inside will set\(user)")
    }
        didSet(user) {
            println("inside will set\(user)")
        }
    }
    var conversation: [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var defaults = NSUserDefaults.standardUserDefaults()
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("inside will appear\(friend)")
        conversation = defaults.arrayForKey(friend.username) as [PFObject]!
        
        var messageQuery = PFQuery(className: "Message")

        messageQuery.whereKey("sender", equalTo: PFUser.currentUser())

        messageQuery.findObjectsInBackgroundWithBlock { (messages: [AnyObject]!, error: NSError!) -> Void in
            
            self.conversation = messages as [PFObject]
            
        }
    }

    @IBAction func sendMessage(sender: AnyObject){
        var message = PFObject(className: "Message")
        message["sender"] = PFUser.currentUser().username
        message["receiver"] = friend.username
        message["content"] = messageField.text
        
        conversation.append(message)
        message.saveInBackground()
        
    }


}

