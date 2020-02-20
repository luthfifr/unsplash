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
    private var loadingView: USLoadingView!

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
        showHideLoadingView(false)
    }
}

// MARK: - Private Methods
extension USMainCollectionViewCell {
    private func setupView() {
        setupImageView()
        setupLoadingView()
    }

    private func setupImageView() {
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

    private func setupLoadingView() {
        loadingView = USLoadingView(frame: contentView.frame)
        contentView.addSubview(loadingView)
        showHideLoadingView(true)
    }

    private func showHideLoadingView(_ value: Bool) {
        if let firstView = contentView.subviews.first(where: {
            $0.accessibilityIdentifier == "loading view"
        }), let loadingView = firstView as? USLoadingView {
            UIView.animate(withDuration: 5, animations: {
                loadingView.animateSpinning(value)
            }, completion: nil)
        }

        if value {
            contentView.bringSubviewToFront(loadingView)
        } else {
            contentView.sendSubviewToBack(loadingView)
        }
        loadingView.isHidden = !value
    }
}

// MARK: - Public Methods
extension USMainCollectionViewCell {
    func setupData(with urls: USResultURL?) {
        guard let strThumb = urls?.thumb,
            let url = URL(string: strThumb) else {
            return
        }

        imgView.sd_setImage(with: url, completed: { [weak self] (_, _, _, _) in
            guard let `self` = self else { return }
            self.showHideLoadingView(false)
        })
    }
}
