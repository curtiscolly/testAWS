//
//  ViewController.swift
//  testAWS
//
//  Created by Curtis Colly on 3/8/19.
//  Copyright © 2019 Snaap. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileClient

class ViewController: UIViewController {
    
    @IBOutlet weak var signInStateLabel: UILabel!
    
    // Reference the AppSync client
   // var appSyncClient: AWSAppSyncClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMobileClient()
//        signUpUser()  // we already did signed up a user
        showSignInState()

//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appSyncClient = appDelegate.appSyncClient
        configureTransfer()
//        uploadData()

    }
    
    func initializeMobileClient(){
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue) 🙃")
                self.uploadData()
            } else if let error = error {
                print("error: \(error.localizedDescription) 😮")
            }
        }
        
        print("client initialized 👍")
    }
    
    func signUpUser(){
        AWSMobileClient.sharedInstance().signUp(
            username: "your_username",
            password: "Abc@123!",
            userAttributes: ["email":"john@doe.com"]) { (signUpResult, error) in
                if let signUpResult = signUpResult {
                    switch(signUpResult.signUpConfirmationState) {
                    case .confirmed:
                        print("User is signed up and confirmed. 😀")
                    case .unconfirmed:
                        print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!) 😱")
                    case .unknown:
                        print("Unexpected case 😍")
                    }
                } else if let error = error {
                    if let error = error as? AWSMobileClientError {
                        switch(error) {
                        case .usernameExists(let message):
                            print(message)
                        default:
                            print("\(error) 🚀")
                            break
                        }
                    }
                    print("\(error.localizedDescription) 😡")
                }
        }
        
    }
    
    func showSignInState(){
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                case .signedIn:
                    DispatchQueue.main.async {
                        self.signInStateLabel.text = "Logged In 😉"
                    }
                case .signedOut:
                    AWSMobileClient.sharedInstance().showSignIn(navigationController: self.navigationController!, { (userState, error) in
                        if(error == nil){       //Successful signin
                            DispatchQueue.main.async {
                                self.signInStateLabel.text = "Logged In 😎"
                                self.downloadData()
                            }
                        }
                    })
                default:
                    AWSMobileClient.sharedInstance().signOut()
                }
                
            } else if let error = error {
                print("😈")
                print(error.localizedDescription)
            }
        }
        
    }
    
    //MARK: File Uploading Functions
    func configureTransfer(){
     
         //Setup credentials, see your awsconfiguration.json for the "YOUR-IDENTITY-POOL-ID"
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "cognito93c08f58_identitypool_93c08f58__myenv")
     
         //Setup the service configuration
         let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
     
         //Setup the transfer utility configuration
         let tuConf = AWSS3TransferUtilityConfiguration()
         tuConf.isAccelerateModeEnabled = true
     
         //Register a transfer utility object
         AWSS3TransferUtility.register(
         with: configuration!,
         transferUtilityConfiguration: tuConf,
         forKey: "transfer-utility-with-advanced-options"
         )
     
         //Look up the transfer utility object from the registry to use for your transfers.
         let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "transfer-utility-with-advanced-options")
     
     }
    
     func uploadData() {
     
         let data: Data = Data() // Data to be uploaded
     
         let expression = AWSS3TransferUtilityUploadExpression()
         expression.progressBlock = {(task, progress) in
             DispatchQueue.main.async(execute: {
             // Do something e.g. Update a progress bar.
             })
         }
     
         var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
         completionHandler = { (task, error) -> Void in
         DispatchQueue.main.async(execute: {
             print("transfer complete")
             // Do something e.g. Alert a user for transfer completion.
             // On failed uploads, `error` contains the error object.
             })
         }
     
//         let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "transfer-utility-with-advanced-options")!
         let transferUtility = AWSS3TransferUtility.default()
     
         transferUtility.uploadData(data,
         bucket: "quiddish",
         key: "test",
         contentType: "text/plain",
         expression: expression,
         completionHandler: completionHandler).continueWith {
         (task) -> AnyObject? in
         if let error = task.error {
            print("Error: \(error.localizedDescription) 🙀")
         }
     
         if let _ = task.result {
         // Do something with uploadTask.
         }
            return nil;
         }
     }
    
    func downloadData() {
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, URL, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed downloads, `error` contains the error object.
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
       // let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "transfer-utility-with-advanced-options")!
        
        transferUtility.downloadData(
            fromBucket: "quiddish",
            key: "brie.mp4",
            expression: expression,
            completionHandler: completionHandler
            ).continueWith {
                (task) -> AnyObject? in if let error = task.error {
                    print("Error: \(error.localizedDescription) 😩")
                }
                
                if let _ = task.result {
                    // Do something with downloadTask.
                    print("File Downloaded 😮")
                }
                return nil;
        }
    }
    
    func signOut(){
        AWSMobileClient.sharedInstance().signOut()
    }
    
    
}

