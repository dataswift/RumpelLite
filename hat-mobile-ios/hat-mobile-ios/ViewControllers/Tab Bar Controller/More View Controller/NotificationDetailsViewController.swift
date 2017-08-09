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

import HatForIOS
import MarkdownView
import SafariServices

// MARK: Class

internal class NotificationDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var markdownView: MarkdownView!
    
    // MARK: - Variables
    
    var notificationToShow: NotificationObject?
    private var safari: SFSafariViewController?
    
    // MARK: - Auto generated methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.markdownView.load(markdown: self.notificationToShow?.notice.message)
        self.markdownView.onTouchLink = { [weak self] request in
            
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

}
