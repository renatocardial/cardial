//
//  UIView+extensions.swift
//  Cardial
//
//  Created by Renato Cardial on 2/15/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import UIKit

public struct Anchor {
    public var top: (NSLayoutYAxisAnchor,CGFloat)? = nil
    public var bottom: (NSLayoutYAxisAnchor, CGFloat)? = nil
    public var leading: (NSLayoutXAxisAnchor, CGFloat)? = nil
    public var trailing: (NSLayoutXAxisAnchor, CGFloat)? = nil
    public var width: CGFloat? = nil
    public var height: CGFloat? = nil
    
    public init(top: (NSLayoutYAxisAnchor,CGFloat)? = nil, bottom: (NSLayoutYAxisAnchor, CGFloat)? = nil, leading: (NSLayoutXAxisAnchor, CGFloat)? = nil, trailing: (NSLayoutXAxisAnchor, CGFloat)? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
        
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
        self.width = width
        self.height = height
    }
    
}

public extension UIView {
    
    var defaultAnchor: Anchor {
        get {
            return Anchor(
                top: (self.topAnchor, 0),
                bottom: (self.bottomAnchor, 0),
                leading: (self.leadingAnchor, 0),
                trailing: (self.trailingAnchor, 0)
            )
        }
    }
    
    func addTo(view: UIView, withAnchor: Anchor? = nil) {
        view.addSubview(self)
        
        let anchor = withAnchor ?? view.defaultAnchor
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let leading = anchor.leading {
            leadingAnchor.constraint(equalTo: leading.0, constant: leading.1).isActive = true
        }
        
        if let trailing = anchor.trailing {
            trailingAnchor.constraint(equalTo: trailing.0, constant: trailing.1).isActive = true
        }
        
        if let top = anchor.top {
            topAnchor.constraint(equalTo: top.0, constant: top.1).isActive = true
        }
        if let bottom = anchor.bottom {
            bottomAnchor.constraint(equalTo: bottom.0, constant: bottom.1).isActive = true
        }
        
        if let width = anchor.width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = anchor.height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}

