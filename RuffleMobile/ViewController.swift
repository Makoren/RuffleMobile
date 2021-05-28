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
                print("Could not copy files to web server. Reason: \(error.localizedDescription)")
            }
        }

        httpServer = GCDWebServer()
        httpServer.addGETHandler(forBasePath: "/", directoryPath: wwwDestinationUrl.path, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
        let options: [String: Any] = [
            GCDWebServerOption_Port: HTTP_PORT,
            //GCDWebServerOption_BindToLocalhost: true
        ]
        
        do {
            try httpServer.start(options: options)
        } catch let error {
            print("Could not start HTTP server. Reason: \(error.localizedDescription)")
        }
        
        loadWebContent(shouldReload: false, shouldClearCache: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Picked documents at \(urls) from \(controller)")
        let importedFileUrl = urls.first!   // safe to force unwrap, VC doesn't allow multiple selection
        let newFileUrl = wwwDestinationUrl.appendingPathComponent(SWF_NAME)
        
        do {
            let swfData = try Data(contentsOf: importedFileUrl)
            
            do {
                try swfData.write(to: newFileUrl)
                loadWebContent(shouldReload: true, shouldClearCache: true)
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
        loadWebContent(shouldReload: true, shouldClearCache: true)
    }
    
    func createErrorAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func loadWebContent(shouldReload: Bool, shouldClearCache: Bool) {
        let websiteDataTypes = Set<String>(arrayLiteral: WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache)
        let cacheDate = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: cacheDate, completionHandler: {})
    
        if shouldReload {
            webView.reload()
        } else {
            let request = URLRequest(url: URL(string: "http://localhost:\(HTTP_PORT)/")!)
            webView.load(request)
        }
    }
}
