//
//  FieldInfo.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 21/12/17.
//  Copyright © 2017 HATDeX. All rights reserved.
//

import HatForIOS

struct FieldInfo<T: HATObject> {

    var string: WritableKeyPath<T, String>?
    var tag: Int = 0
    var placeholder = ""
    
    init(string: WritableKeyPath<T, String>, tag: Int, placeholder: String) {
        
        self.string = string
        self.tag = tag
        self.placeholder = placeholder
    }
}
