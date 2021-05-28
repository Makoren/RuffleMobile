//
//  ViewController.swift
//  RuffleMobile
//
//  Created by Luke Lazzaro on 22/5/21.
//

import UIKit
import WebKit
import GCDWebServer
import MobileCoreServices

class ViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var httpServer: GCDWebServer!
    var webDAVServer: GCDWebDAVServer!
    
    let HTTP_PORT: UInt = 80
    let SWF_NAME: String = "game.swf"
    
    let wwwSourcePath = "file://\(Bundle.main.path(forResource: "www", ofType: nil)!)"
    let wwwDestinationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("www")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: wwwDestinationUrl.path) {
            do {
                try fileManager.copyItem(at: URL(string: wwwSourcePath)!, to: wwwDestinationUrl)
            } catch let error {
                print("Could not copy directory despite it not existing at the destination path. Reason: \(error.localizedDescription)")
            }
        } else {
            // Replace web content with a fresh copy. When updating the app, the data sticks around, so I'd need to replace the ruffle.js with a fresh nightly build for example.
            do {
                try fileManager.removeItem(at: wwwDestinationUrl)
            } catch let error {
                print("Could not remove item. Reason: \(error.localizedDescription)")
            }
            
            do {
                try fileManager.copyItem(at: URL(string: wwwSourcePath)!, to: wwwDestinationUrl)
            } catch let error {
                print("Could not copy items to destination path. Reason: \(error.localizedDescription)")
            }
        }

        httpServer = GCDWebServer()
        webDAVServer = GCDWebDAVServer(uploadDirectory: wwwDestinationUrl.path)
        
        httpServer.addGETHandler(forBasePath: "/", directoryPath: wwwDestinationUrl.path, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
        
        httpServer.start(withPort: HTTP_PORT, bonjourName: nil)
        webDAVServer.start(withPort: 8080, bonjourName: nil)
        
        let request = URLRequest(url: URL(string: "http://localhost:\(HTTP_PORT)/")!)
        webView.load(request)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Picked documents at \(urls) from \(controller)")
        let importedFileUrl = urls.first!   // safe to force unwrap, VC doesn't allow multiple selection
        let newFileUrl = wwwDestinationUrl.appendingPathComponent(SWF_NAME)
        
        do {
            let swfData = try Data(contentsOf: importedFileUrl)
            
            do {
                try swfData.write(to: newFileUrl)
                webView.reload()
            } catch let error {
                print("Could not write to \(SWF_NAME). Reason: \(error.localizedDescription)")
            }
        } catch let error {
            print("Could not get data from SWF file. Reason: \(error.localizedDescription)")
        }
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        let dpvc = UIDocumentPickerViewController(documentTypes: ["com.makoren.ShockwaveFlash"], in: .import)
        dpvc.delegate = self
        dpvc.allowsMultipleSelection = false
        present(dpvc, animated: true, completion: nil)
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        webView.reload()
    }
    
    func createErrorAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
