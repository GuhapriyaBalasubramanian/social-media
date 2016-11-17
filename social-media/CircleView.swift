//
//  CircleView.swift
//  social-media
//
//  Created by Guhapriya Balasubramanian on 17/11/2016.
//  Copyright © 2016 Guhapriya Balasubramanian. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
}

