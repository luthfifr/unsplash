//
//  USLoadingView.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 20/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import UIKit

import SnapKit

class USLoadingView: UIView {
    private var label: UILabel!
    private var activityIndicator: UIActivityIndicatorView!

    var titleText: String? {
        didSet {
            updateUI()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        setUpUI()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
}

// MARK: - Private Methods
extension USLoadingView {
    private func setUpUI() {
        setUpView()
        setUpActivityIndicator()
        setUpLabel()
    }

    private func setUpView() {
        isUserInteractionEnabled = false
        backgroundColor = .darkGray
        clipsToBounds = false
        isAccessibilityElement = false
        accessibilityIdentifier = "loading view"
    }

    private func setUpLabel() {
        if label == nil {
            label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: self.frame.width,
                                          height: 30))
            label.font = .preferredFont(forTextStyle: .headline)
            label.numberOfLines = 0
            label.textColor = UIColor.black.withAlphaComponent(0.8)
            label.sizeToFit()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            addSubview(label)

            label.snp.makeConstraints({ make in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY).offset(-100)
            })
        }
    }

    private func setUpActivityIndicator() {
        if activityIndicator == nil {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(activityIndicator)

            activityIndicator.snp.makeConstraints({ make in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY)
            })
        }
    }

    private func updateUI() {
        label.text = titleText ?? "Loading"
    }
}

// MARK: - Public Methods
extension USLoadingView {
    func animateSpinning(_ value: Bool) {
        if value {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
