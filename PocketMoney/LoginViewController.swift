//
//  LoginViewController.swift
//  
//
//  Created by Roger Nolan on 28/04/2015.
//
//

import UIKit

class LoginViewController: PFLogInViewController {

    override func viewWillAppear(animated: Bool) {
        let logo = UIImage(named: "pig")
        let view = UIImageView(image: logo)
        view.contentMode = .ScaleAspectFit
        logInView?.logo = view
        super.viewWillAppear(animated)
    }
}
