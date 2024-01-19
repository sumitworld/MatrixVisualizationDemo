//
//  CustomFlowLayout.swift
//  MatrixVisualizationDemo
//
//  Created by Vivek Parmar on 2024-01-19.
//

import Foundation
import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .vertical
        itemSize = CGSize(width: 80, height: 80)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerReferenceSize = CGSize(width: 0, height: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
