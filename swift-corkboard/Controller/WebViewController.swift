//
//  WebViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/24/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet var webpageTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        
        let urlString: String = "https://www.google.com"
        let url:URL = URL(string: urlString)!
        let urlRequest: URLRequest = URLRequest(url: url)
        webView.load(urlRequest)
        
        webpageTitle.text = urlString
    }
    
    @IBOutlet var webView: WKWebView!
    
    @IBAction func backButton(_ sender: UIButton) {
    }
    
}
