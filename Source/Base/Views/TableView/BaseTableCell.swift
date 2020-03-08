//
//  BaseTableCell.swift
//  Cardial
//
//  Created by Renato Cardial on 2/22/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import UIKit

open class BaseTableCell<M>: UITableViewCell {
    
    open var viewModel:M!
    
    open func setupView(viewModel: M) {
        self.viewModel = viewModel
        self.textLabel?.text = "You need override setupView(viewModel: T)"
    }
}

