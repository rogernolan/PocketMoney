//
//  SignUpViewController.swift
//  PocketMoney
//
//  Created by Roger Nolan on 01/05/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit

class SignUpViewController: PFSignUpViewController {

    override func viewWillAppear(animated: Bool) {
        let logo = UIImage(named: "pig")
        let view = UIImageView(image: logo)
        view.contentMode = .ScaleAspectFit
        signUpView?.logo = view
        super.viewWillAppear(animated)
    }
}
