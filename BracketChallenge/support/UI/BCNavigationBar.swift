//
//  BCNavigationBar.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 8/14/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class BCNavigationBar: UINavigationBar {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        isTranslucent = false
        barTintColor = UIColor.bcGreen
        tintColor = UIColor.bcYellow
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white];
    }
}
