//
//  UIImageView+extension.swift
//  Cardial
//
//  Created by Renato Cardial on 3/1/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import UIKit

public extension UIImageView {
    
    func load(from urlString: String, placeholder: UIImage? = nil, showIndicator: Bool = false) {
        
        if placeholder != nil {
            DispatchQueue.main.async {
                self.image = placeholder
            }
        }
        
        if let url = URL(string: urlString) {
            if showIndicator {
                if #available(iOS 13.0, *) {
                    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .large)
                    activityIndicator.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                    activityIndicator.startAnimating()
                    addSubview(activityIndicator)
                } else {
                    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    activityIndicator.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                    activityIndicator.startAnimating()
                    addSubview(activityIndicator)
                }
            }
            
            let downloader = Downloadable(url: url)
            downloader.download(finished: { (error, data, id) in
                if showIndicator {
                    self.subviews.last?.removeFromSuperview()
                }
                if let data = data {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                    }
                }
            })
        }
    }
    
}
