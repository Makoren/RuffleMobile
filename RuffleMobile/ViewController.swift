//
//  ViewController.swift
//  RuffleMobile
//
//  Created by Luke Lazzaro on 22/5/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let localUrl = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www")!
        webView.loadFileURL(localUrl, allowingReadAccessTo: localUrl)
        let myRequest = URLRequest(url: localUrl)
        webView.load(myRequest)
    }
    
}
