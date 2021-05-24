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
    
    var webServer: GCDWebServer!
    let PORT: UInt = 8080
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dpvc = UIDocumentPickerViewController(documentTypes: ["public.png"], in: .import)
        
        webServer = GCDWebServer()
        let webContentPath = Bundle.main.path(forResource: "www", ofType: nil)!

        webServer.addGETHandler(forBasePath: "/", directoryPath: webContentPath, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
        webServer.start(withPort: PORT, bonjourName: "")
        
        let request = URLRequest(url: URL(string: "http://localhost:\(PORT)")!)
        webView.load(request)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webServer.stop()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Picked documents at \(urls) from \(controller)")
    }
}
