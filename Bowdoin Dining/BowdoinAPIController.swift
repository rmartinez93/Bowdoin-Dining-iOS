//
//  BowdoinAPIController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/28/14.
//  Translated & modified from ObjC 
//  Original Created by Ben Johnson on 9/23/10
//

import Foundation

class BowdoinAPIController: NSObject {
    var user     : User
    var type     : String
    var session  : URLSession?
    var loginAttempts = 0
    
    init(user : User) {
        self.user     = user
        self.type     = ""
        
        super.init()
        
        self.session  = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    // Gets user account data (balance, points)
    func getAccountData() {
        self.type = "account"
        self.requestDataWithSoapEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldSVCBalances/>"))
    }
    
    // Gets meal data (number of meals remaining)
    func getMealData() {
        self.type = "meals"
        self.requestDataWithSoapEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldMPBalances/>"))
    }
    
    // Gets line status
    func getLineData() {
        self.type = "lines"
        self.requestDataWithSoapEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldLineCountsHistogram/>"))
    }
    
    // Gets recent transactions
    func getTransactionData() {
        self.type = "transactions"
        self.requestDataWithSoapEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldGLTrans/>"))
    }
    
    // SOAP envelope for request
    func returnSoapEnvelopeForService(_ serviceRequested : String) -> String {
        var soapEnvelope = "<?xml version=\"1.0\"?>"
        soapEnvelope += "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">"
        soapEnvelope += "<soapenv:Header/>"
        soapEnvelope += "<soapenv:Body>"
        soapEnvelope += serviceRequested
        soapEnvelope += "</soapenv:Body>"
        soapEnvelope += "</soapenv:Envelope>"
        
        return soapEnvelope
    }
    
    func createRequestWithBody(_ data: Data) -> URLRequest {
        let url = URL(string: "https://gooseeye.bowdoin.edu/ws-csGoldShim/Service.asmx")!
        let req = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 5000)
        
        // Add request metadata.
        req.addValue("text/xml",    forHTTPHeaderField: "Content-Type")
        req.addValue("bowdoin.edu", forHTTPHeaderField: "Host")
        req.httpMethod = "POST"
        req.httpBody = data
        
        return req as URLRequest
    }
    
    // Makes SOAP request
    func requestDataWithSoapEnvelope(_ soapEnvelope : String) {
        // Create the request.
        let req = createRequestWithBody(soapEnvelope.data(using: String.Encoding.utf8)!)
        
        // Request the data
        let dataTask = self.session!.dataTask(with: req) { (data, response, error) in
            if error != nil {
                print("ERROR!", response, error!)
                
                // Handle failure.
                self.user.dataLoadingFailed()
            }
            
            if data != nil {
                self.user.parseData(data!, type: self.type)
            }
        }
        
        dataTask.resume()
    }
}

extension BowdoinAPIController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("Received Login Challenge")
        // If we haven't tried to login yet, authenticate.
        if self.loginAttempts == 0 {
            let authMethod = challenge.protectionSpace.authenticationMethod
            
            // Authenticate with NTLM
            if authMethod == NSURLAuthenticationMethodNTLM {
                // Use username and password to form credential.
                let credential = URLCredential(user: self.user.username!,
                                               password: self.user.password!,
                                               persistence: URLCredential.Persistence.none)
                
                print("Sending credentials...")
                
                // Use credential with challenge request.
                completionHandler(.useCredential, credential)
                
                // Increment login attempts.
                self.loginAttempts += 1
            }
            
            // Make sure the server trusts us first.
            if authMethod == NSURLAuthenticationMethodServerTrust {
                print("Please trust us, Mr. Server...")
                
                completionHandler(.performDefaultHandling, nil)
            }
        }
        else {
            print("Fail login challenge")
            
            // Handle failure.
            self.user.dataLoadingFailed()
            
            // Don't try more than once.
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("Received Login Challenge V2")
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("ERROR!", error!.localizedDescription)
    }
}
