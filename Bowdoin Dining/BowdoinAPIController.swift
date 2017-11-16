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
    var data     : NSMutableData?
    var loginAttempts = 0
    
    init(user : User) {
        self.user     = user
        self.type     = ""
        
        super.init()
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
        
        // Create a URL connection
        let connection = NSURLConnection(request: req, delegate: self, startImmediately: false)
        
        if connection != nil {
            // Schedule this ASAP.
            connection!.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            
            // Start the connection.
            connection!.start()
        } else {
            // Handle failure.
            self.user.dataLoadingFailed()
        }
    }
    
}

extension BowdoinAPIController: NSURLConnectionDelegate {
    // Takes care of HTTP Authentication
    func connection(_ connection: NSURLConnection, didReceive challenge: URLAuthenticationChallenge) {
        // If we haven't tried to login yet, authenticate.
        if self.loginAttempts == 0 {
            let authMethod = challenge.protectionSpace.authenticationMethod
            
            // Authenticate with NTLM
            if authMethod == NSURLAuthenticationMethodNTLM {
                // Use username and password to form credential.
                let credential = URLCredential(user: self.user.username!,
                                               password: self.user.password!,
                                               persistence: URLCredential.Persistence.none)
                
                // Use credential with challenge request.
                challenge.sender?.use(credential, for: challenge)
            }
            
            // Increment login attempts.
            self.loginAttempts += 1
        }
        else {
            // Don't try more than once.
            connection.cancel()
            
            // Handle failure.
            self.user.dataLoadingFailed()
        }
    }
    
    private func connection(_ connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        // Response received, clear out data
        self.data = NSMutableData()
    }
    
    private func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
        // Store received data
        self.data?.append(data)
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        // The request has failed for some reason!
        print("ERROR: ", error.localizedDescription);
        
        // Handle failure.
        self.user.dataLoadingFailed()
    }
    
    func connection(_ connection: NSURLConnection!, willCacheResponse cachedResponse : CachedURLResponse) -> CachedURLResponse? {
        return nil
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        // ONLY IF the data loaded, parse it.
        if let data = self.data as Data? {
            self.user.parseData(data, type: self.type)
        }
    }
}
