/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import MarkdownView
import SafariServices

// MARK: class

/// The terms and conditions view controller class
internal class TermsAndConditionsViewController: UIViewController {
    
    // MARK: - Variables
    
    private var safari: SFSafariViewController?
    var url: String = "https://s3-eu-west-1.amazonaws.com/developers.hubofallthings.com/legals/RumpelLite-Terms-of-Service.md"
    
    // MARK: - IBOutlets

    /// An IBOutlet to handle the webview
    @IBOutlet private weak var markDownView: MarkdownView!
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let session = URLSession(configuration: .default)
        let url = URL(string: self.url)!
        let task = session.dataTask(with: url) { [weak self] data, _, _ in
            
            let str = String(data: data!, encoding: String.Encoding.utf8)
            DispatchQueue.main.async {
                
                self?.markDownView.load(markdown: str)
            }
        }
        task.resume()
        
        self.markDownView.onTouchLink = { [weak self] request in
            
            if let weakSelf = self {
                
                guard let url = request.url else {
                    
                    return false
                }
                
                if url.scheme == "file" {
                    
                    return true
                } else if url.scheme == "https" {
                    
                    weakSelf.safari = SFSafariViewController.openInSafari(url: String(describing: url), on: weakSelf, animated: true, completion: nil)
                    
                    return false
                } else {
                    
                    return false
                }
            } else {
                
                return false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

}
