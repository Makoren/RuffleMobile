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
        
        let myUrl = URL(string: "https://www.google.com")
        let myRequest = URLRequest(url: myUrl!)
        webView.load(myRequest)
    }
    
}

