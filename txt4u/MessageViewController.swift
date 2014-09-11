//
//  ViewController.swift
//  txt4u
//
//  Created by Katlyn Schwaebe on 9/10/14.
//  Copyright (c) 2014 Katlyn Schwaebe. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
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
    var conversation: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        messageField.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath:indexPath) as UITableViewCell
        cell.textLabel?.text = conversation[indexPath.row]["content"] as? String
        return cell
    }
    
    var defaults = NSUserDefaults.standardUserDefaults()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //println("inside will appear\(friend)")
        //conversation = defaults.arrayForKey(friend.username) as [PFObject]!
        
        var messageQuery = PFQuery(className: "Message")
        var possibleRelations = [PFUser.currentUser().username + friend.username, friend.username + PFUser.currentUser().username]
        messageQuery.whereKey("relation", containedIn: possibleRelations)
        
        
        messageQuery.findObjectsInBackgroundWithBlock { (messages: [AnyObject]!, error: NSError!) -> Void in
            if messages.count > 0 {
                self.conversation = messages as [PFObject]
                self.tableView.reloadData()
            }
            
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

        formHolder.frame.origin.y = UIScreen.mainScreen().bounds.size.height - 281
        println(textField.frame.origin.y)
        
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.sendMessage(textField)
        return true
    }

    @IBAction func sendMessage(sender: AnyObject) {
        
        messageField.resignFirstResponder()
       
        
        var message = PFObject(className: "Message")
        message["sender"] = PFUser.currentUser()
        message["receiver"] = friend
        message["content"] = messageField.text
        message["relation"] = PFUser.currentUser().username + friend.username
        message["read"] = false
        
        
        conversation.append(message)
        message.saveInBackground()
        tableView.reloadData()
        
        var deviceQuery = PFInstallation.query()
        deviceQuery.whereKey("user", equalTo: friend)
        
        var push = PFPush()
        push.setMessage(messageField.text)
        push.setQuery(deviceQuery)
        push.setData(NSDictionary(object: friend, forKey: "sender"))
        push.sendPushInBackground()
        
       
         messageField.text = ""
        
    }
    


}


