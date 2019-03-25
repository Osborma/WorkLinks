//
//  UIViewController+Helpers.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 20/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit

extension UIViewController {

    func setupAddButtonInNavBar(selector: Selector) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add",
                                                            style: .plain,
                                                            target: self,
                                                            action: selector)
    }

    func setupCancelButtonInNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(handleCancel))

    }

    @objc func handleCancel() {
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }

    func setUpLightBlueBackgroundView(height: CGFloat) -> UIView {
        let lightBlueBackgroundView = UIView()
        lightBlueBackgroundView.backgroundColor = .lightBlue
        lightBlueBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(lightBlueBackgroundView)
        lightBlueBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                       bottom: nil, right: view.rightAnchor,
                                       paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                                       width: 0, height: height)
        return lightBlueBackgroundView
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
