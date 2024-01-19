//
//  MatrixBoxCell.swift
//  MatrixVisualizationDemo
//
//  Created by Vivek Parmar on 2024-01-19.
//

import UIKit

class MatrixBoxCell: UICollectionViewCell {

    static let identifier = "MatrixBoxCell"

//    let countLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        return label
//    }()

    let boxView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8.0
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        boxView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(boxView)

        NSLayoutConstraint.activate([
            boxView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            boxView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            boxView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            boxView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with recordCount: Int) {
        if recordCount == 0 {
            boxView.backgroundColor = .lightGray
        } else {
            let opacity = Float(recordCount) / 1000.0
            boxView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: CGFloat(opacity))
        }
    }
}
