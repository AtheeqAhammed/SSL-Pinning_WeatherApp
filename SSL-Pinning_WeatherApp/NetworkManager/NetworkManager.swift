//
//  NetworkManager.swift
//  SSL-Pinning_WeatherApp
//
//  Created by Ateeq Ahmed on 11/10/24.
//

import Foundation

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    var session: URLSession!
    
    private override init() {
        super.init()
        session = URLSession.init(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    }
    
    func request<T: Decodable>(url: URL?, expecting: T.Type , completion: @escaping(_ data: T?, _ error: Error?) -> () ) {
        
        guard let url else {
            print("cannot form URL")
            return }
        
        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(nil, error)
                return
            }
            guard let data else {
                print("something went wrong")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(T.self, from: data)
                completion(response, nil)
            }
            catch {
                completion(nil, error)
            }
        }
        .resume()
    }
}

//MARK: SSL Pinning

extension NetworkManager: URLSessionDelegate {
 
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        //MARK: Create server trust
        guard let serverTrust = challenge.protectionSpace.serverTrust, let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return
        }
        
        //MARK: SSL Policy for Domain check
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        
        //MARK: Evaluate the certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        //MARK: Local and Remote certificate data
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
        
        let pathToCertificate = Bundle.main.path(forResource: "openweathermap.org", ofType: "cer")
        
        let localCertificateData: NSData = NSData.init(contentsOfFile: pathToCertificate!)!
        
        //MARK: Compare data of both certificates
        if (isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)) {
            let credential: URLCredential = URLCredential(trust: serverTrust)
            print("Certificate Pinning is successful")
            completionHandler(.useCredential, credential)
        }
        else{
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
