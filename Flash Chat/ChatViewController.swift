//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import  ChameleonFramework

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
   
    
    
    //UITableViewDelegate helps to determine whether user have selected something or he/she makes a swipe gesture, and that ChatViewController is responsible to handle it
    //UITableViewDataSource is responsible for all the data
    // Declare instance variables here
    var messageArray :[Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate=self
        messageTableView.dataSource=self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate=self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName:"MessageCell",bundle:nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
       
        cell.messageBody.text=messageArray[indexPath.row].messageBody
        cell.senderUsername.text=messageArray[indexPath.row].sender
        cell.avatarImageView.image=UIImage(named:"egg")
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String!{
             cell.avatarImageView.backgroundColor=UIColor.flatYellow()
            cell.messageBackground.backgroundColor=UIColor.flatPink()
        }else{
            cell.avatarImageView.backgroundColor=UIColor.flatBlue()
            cell.messageBackground.backgroundColor=UIColor.flatTeal()
        }
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc  func tableViewTapped(){
            messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight=UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight=120.0
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
 
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=308
            //if any constraint or anything in view has changed then redraw again
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    //this function doesnt trigger automatically . we need to call it manually
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=50
            //if any constraint or anything in view has changed then redraw again
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    //MARK: - Send & Recieve from Firebase
    

    @IBAction func sendPressed(_ sender: AnyObject) {
        
          messageTextfield.endEditing(true)
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled=false
        sendButton.isEnabled=false
        
        //this creates new database "Messages" inside our main database
        let messageDB=Database.database().reference().child("Messages")
        let messageDictionary=["Sender":Auth.auth().currentUser?.email,"MessageBody":messageTextfield.text!]
        
        //this creates a custom random key for our message. So that our mesages can be saved under their own unique identifier
        messageDB.childByAutoId().setValue(messageDictionary){
            (err,reference) in
            if err != nil{
                print(err!)
            }else{
                print("Message saved successfully to database")
                self.messageTextfield.isEnabled=true
                self.sendButton.isEnabled=true
                self.messageTextfield.text=""
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages(){
        let messageDB=Database.database().reference().child("Messages")
        
        //this checks whether new iem is added to our "Messages" database
        //it return a snapshot which is the snapshot of the item added to databse
        messageDB.observe(.childAdded) { (snapshot) in
            
            //we are converting the value coz it is of type "Any" into dictionary as
            //we pushed data of type dictioanry into databases
            let result=snapshot.value as! Dictionary<String,String>
            
            let text=result["MessageBody"]!
            let sender=result["Sender"]!
            
            let messageObject=Message()
            messageObject.sender=sender
            messageObject.messageBody=text
            
            self.messageArray.append(messageObject)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
           try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }catch{
            print("Error: In signing out")
        }
        
    }
    


}
