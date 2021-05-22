//
//  ViewController.swift
//  RuffleMobile
//
//  Created by Luke Lazzaro on 22/5/21.
//

import UIKit
import WebKit
import GCDWebServer

class ViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var webServer: GCDWebServer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        webServer = GCDWebServer()
        let webContentPath = Bundle.main.path(forResource: "www", ofType: nil)!

        webServer.addGETHandler(forBasePath: "/", directoryPath: webContentPath, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
        webServer.start(withPort: 8080, bonjourName: "")
        
        let request = URLRequest(url: URL(string: "http://localhost:8080")!)
        webView.load(request)
    }
    
}
