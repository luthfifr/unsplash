//
//  USMainViewController.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import UIKit
import RxSwift

class USMainViewController: UIViewController {

    private var viewModel: USMainViewModel!

    // MARK: - Initialization
    convenience init() {
        self.init(viewModel: nil)
    }

    init(viewModel: USMainViewModel?) {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue
    }
}
