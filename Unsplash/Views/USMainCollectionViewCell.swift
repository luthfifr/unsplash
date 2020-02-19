//
//  USMainCollectionViewCell.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

final class USMainCollectionViewCell: UICollectionViewCell {
    private var imgView: UIImageView!

    convenience init() {
        self.init()

        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }
    
    override func prepareForReuse() {
        imgView.sd_cancelCurrentImageLoad()
    }
}

// MARK: - Private Methods
extension USMainCollectionViewCell {
    private func setupView() {
        if imgView == nil {
            imgView = UIImageView(frame: .zero)
            imgView.contentMode = .scaleAspectFit
            if !contentView.subviews.contains(imgView) {
                contentView.addSubview(imgView)
            }
            imgView.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }
    }
}

// MARK: - Public Methods
extension USMainCollectionViewCell {
    func setupData(with urls: USResultURL?) {
        guard let strThumb = urls?.thumb,
            let url = URL(string: strThumb) else {
            return
        }
        imgView.sd_setImage(with: url, completed: nil)
    }
}
