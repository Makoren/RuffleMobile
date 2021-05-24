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
    let HTTP_PORT: UInt = 80
    let WEBDAV_PORT: UInt = 8080
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webContentUrl = Bundle.main.path(forResource: "www", ofType: nil)!

        httpServer = GCDWebServer()
        webDAVServer = GCDWebDAVServer(uploadDirectory: webContentUrl)
        
        httpServer.addGETHandler(forBasePath: "/", directoryPath: webContentUrl, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
        httpServer.start(withPort: HTTP_PORT, bonjourName: nil)
        webDAVServer.start(withPort: WEBDAV_PORT, bonjourName: nil)
        
        let request = URLRequest(url: URL(string: "http://localhost:\(HTTP_PORT)")!)
        webView.load(request)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        httpServer.stop()
        webDAVServer.stop()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Picked documents at \(urls) from \(controller)")
        let importedFileUrl = urls.first!   // safe to force unwrap, VC doesn't allow multiple selection
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        let dpvc = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
        dpvc.delegate = self
        dpvc.allowsMultipleSelection = false
        present(dpvc, animated: true, completion: nil)
    }
}
