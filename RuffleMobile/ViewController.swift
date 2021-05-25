//
//  ViewController.swift
//  RuffleMobile
//
//  Created by Luke Lazzaro on 22/5/21.
//

import UIKit
import WebKit
import GCDWebServer

class ViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var httpServer: GCDWebServer!
    var webDAVServer: GCDWebDAVServer!
    
    var webDAVURL: String = ""
    
    let HTTP_PORT: UInt = 80
    let WEBDAV_PORT: UInt = 8080
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webContentUrl = Bundle.main.path(forResource: "www", ofType: nil)!

        httpServer = GCDWebServer()
        
        webDAVURL = "http://localhost:\(WEBDAV_PORT)/"
        webDAVServer = GCDWebDAVServer(uploadDirectory: webContentUrl)
        
        httpServer.addGETHandler(forBasePath: "/", directoryPath: webContentUrl, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
        httpServer.start(withPort: HTTP_PORT, bonjourName: nil)
        //webDAVServer.start(withPort: WEBDAV_PORT, bonjourName: "rufflemobile-dav")
        
        let options: [String: Any] = [
            GCDWebServerOption_Port: WEBDAV_PORT,
            //GCDWebServerOption_BindToLocalhost: true
        ]
        
        do {
            try webDAVServer.start(options: options)
        } catch let error {
            print("Could not start WebDAV server. Reason: \(error.localizedDescription)")
        }
        
        let request = URLRequest(url: URL(string: "http://localhost:\(HTTP_PORT)/")!)
        webView.load(request)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Picked documents at \(urls) from \(controller)")
        let importedFileUrl = urls.first!   // safe to force unwrap, VC doesn't allow multiple selection
        
        do {
            let data = try Data(contentsOf: importedFileUrl)
            
            var request = URLRequest(url: URL(string: "http://localhost:\(WEBDAV_PORT)/pixel.png")!)
            request.httpMethod = "PUT"
            
            let task = URLSession(configuration: .ephemeral).uploadTask(with: request, from: data) { data, response, error in
                print("Data: \(String(describing: data))")
                print("Response: \(String(describing: response))")
                print("Error: \(String(describing: error))")
                print(String(decoding: data!, as: UTF8.self))
            }
            
            task.resume()
            
        } catch let error {
            createErrorAlert(message: error.localizedDescription)
        }
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        let dpvc = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
        dpvc.delegate = self
        dpvc.allowsMultipleSelection = false
        present(dpvc, animated: true, completion: nil)
    }
    
    func createErrorAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
