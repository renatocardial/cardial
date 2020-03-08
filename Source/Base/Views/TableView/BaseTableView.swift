//
//  BaseTableView.swift
//  Cardial
//
//  Created by Renato Cardial on 2/22/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import UIKit

open class BaseTableView<T: BaseTableCell<M>, M>: UITableView {
    
    public var cellsViewModel = [M]()
    
    let cellId = String(describing: T.self)
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public override func numberOfRows(inSection section: Int) -> Int {
        return cellsViewModel.count
    }
    
    public override func cellForRow(at indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? T else {
            return UITableViewCell()
        }
        
        let cellViewModel = cellsViewModel[indexPath.row]
        cell.setupView(viewModel: cellViewModel)
        
        return cell
    }
    
    private func registerCell() {
        self.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func setupView() {
        registerCell()
        separatorStyle = .none
    }
}
