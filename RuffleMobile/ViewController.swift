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
    let HTTP_PORT: UInt = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webContentUrl = Bundle.main.path(forResource: "www", ofType: nil)!

        httpServer = GCDWebServer()
        
        httpServer.addGETHandler(forBasePath: "/", directoryPath: webContentUrl, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
        
        httpServer.addDefaultHandler(forMethod: "POST", request: GCDWebServerDataRequest.self) { request in
            // get body of request somehow and store data in "www" directory
            let dataRequest = request as! GCDWebServerDataRequest
            print("Request received: \(String(decoding: dataRequest.data, as: UTF8.self))")
            
            // create file for request data
            var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsPath.appendPathComponent("arbitrary.txt")
            
            do {
                try dataRequest.data.write(to: documentsPath)
                print(documentsPath)
            } catch let error {
                print(error.localizedDescription)
            }
            
            let items = try! FileManager.default.contentsOfDirectory(atPath: webContentUrl)
            for item in items {
                print(item)
            }
            
            // attempt to request data from server
            
            return GCDWebServerResponse(statusCode: 200)
        }
        
        httpServer.start(withPort: HTTP_PORT, bonjourName: nil)
        
        let request = URLRequest(url: URL(string: "http://localhost:\(HTTP_PORT)/")!)
        webView.load(request)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Picked documents at \(urls) from \(controller)")
        let importedFileUrl = urls.first!   // safe to force unwrap, VC doesn't allow multiple selection
        
        do {
            let data = try Data(contentsOf: importedFileUrl)

            var request = URLRequest(url: URL(string: "http://localhost:\(HTTP_PORT)/")!)
            request.httpMethod = "POST"

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
        let dpvc = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .import)
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
