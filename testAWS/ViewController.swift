//
//  ViewController.swift
//  testAWS
//
//  Created by Curtis Colly on 3/8/19.
//  Copyright © 2019 Snaap. All rights reserved.
//

import UIKit
import AWSS3
//import AWSAppSync

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTransfer()
        uploadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
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
        
        let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "transfer-utility-with-advanced-options")!

//        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(data,
                                   bucket: "quiddish",
                                   key: "YourFileName",
                                   contentType: "text/plain",
                                   expression: expression,
                                   completionHandler: completionHandler).continueWith {
                                    (task) -> AnyObject? in
                                    if let error = task.error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                    
                                    if let _ = task.result {
                                        // Do something with uploadTask.
                                    }
                                    return nil;
        }
    }
    
    
}

