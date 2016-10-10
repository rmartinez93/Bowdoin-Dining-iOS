//
//  BowdoinAPIController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/28/14.
//  Translated & modified from ObjC 
//  Original Created by Ben Johnson on 9/23/10
//

import Foundation

class BowdoinAPIController : NSObject, NSURLConnectionDelegate {
    var user     : User
    var type     : String
    var data     : NSMutableData?
    var loginAttempts = 0
    
    init(user : User) {
        self.user     = user
        self.type     = ""
        
        super.init()
    }
    
    //gets user account data (balance, points)
    func getAccountData() {
        self.type = "account"
        self.createSOAPRequestWithEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldSVCBalances/>"))
    }
    
    //gets meal data (number of meals remaining)
    func getMealData() {
        self.type = "meals"
        self.createSOAPRequestWithEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldMPBalances/>"))
    }
    
    //gets line status
    func getLineData() {
        self.type = "lines"
        self.createSOAPRequestWithEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldLineCountsHistogram/>"))
    }
    
    //gets recent transactions
    func getTransactionData() {
        self.type = "transactions"
        self.createSOAPRequestWithEnvelope(self.returnSoapEnvelopeForService("<tem:GetCSGoldGLTrans/>"))
    }
    
    //SOAP envelope for request
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
    
    //makes SOAP request
    func createSOAPRequestWithEnvelope(_ soapEnvelope : String) {
        //create request
        let url = URL(string: "https://gooseeye.bowdoin.edu/ws-csGoldShim/Service.asmx")!
        let req = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 5000)
        
        req.addValue("text/xml",    forHTTPHeaderField: "Content-Type")
        req.addValue("bowdoin.edu", forHTTPHeaderField: "Host")
        req.httpMethod = "POST"
        req.httpBody = soapEnvelope.data(using: String.Encoding.utf8)
        
        //begin connection
        let connection = NSURLConnection(request: req as URLRequest, delegate: self, startImmediately: false)
        
        if connection != nil {
            connection!.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            
            connection!.start()
        } else {
            self.user.dataLoadingFailed()
        }
    }
    
    //takes care of HTTP Authentication
    func connection(_ connection: NSURLConnection, didReceive challenge: URLAuthenticationChallenge) {
        if self.loginAttempts == 0 {
            let authMethod = challenge.protectionSpace.authenticationMethod
            if authMethod == NSURLAuthenticationMethodNTLM {

                let credential = URLCredential(user: self.user.username!,
                    password: self.user.password!,
                    persistence: URLCredential.Persistence.none)
                
                challenge.sender?.use(credential, for: challenge)
            }
            self.loginAttempts += 1
        } else {
            connection.cancel()
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
        //The request has failed for some reason!
        // Check the error var
        NSLog("ERR \(error)")
        self.user.dataLoadingFailed()
    }
    
    func connection(_ connection: NSURLConnection!, willCacheResponse cachedResponse : CachedURLResponse) -> CachedURLResponse? {
        return nil
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        self.user.parseData(self.data! as Data, type: self.type)
    }
}
