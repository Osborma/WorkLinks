//
//  AddAction.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 20/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit

protocol AddActionControllerDelegate {
    func didAddAction(action: Action)
}

class AddActionController: UIViewController {

    var contact: Contact?
    
    var delegate: AddActionControllerDelegate?

    let actionLabel: UILabel = {
        let label = UILabel()
        label.text = "Action"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let actionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter an action"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let addDeadlineButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Deadline", for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.setTitleColor( .darkBlue, for: .normal)
        button.backgroundColor = UIColor.lightBlue.darker(by: 8)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addDatePicker), for: .touchUpInside)
        button.layer.cornerRadius = 15
        return button
    }()


    lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.datePickerMode = .date
        return dp
    }()


    override func viewDidLoad() {

        navigationItem.title = "Add Action"

        setupCancelButtonInNavBar()

        view.backgroundColor = .white

        setupUI()

        setupAddButtonInNavBar(selector: #selector(addAction))

        hideKeyboardWhenTappedAround()

    }

    @objc private func addAction() {

        guard let action = actionTextField.text else { return }
        guard let contact = contact else { return }

        if actionTypeSegmentedControl.selectedSegmentIndex == -1 {
                showError(title: "Invalid classification",
                          message: "Please classify the type of action")
                return
        }

        guard let actionType =
            actionTypeSegmentedControl.titleForSegment(at:
                actionTypeSegmentedControl.selectedSegmentIndex) else { return }

        let deadlineDate = datePicker.date

        if deadlineDate < Date().addingTimeInterval( -1 * (60 * 60 * 24)) {
            showError(title: "Invalid Date",
                      message: "Please set a date that isn't in that past")
            return
        }
        
        if action.isEmpty {
            showError(title: "Invalid Action",
                      message: "Please add an action")
            return
        }


         if isAddingDatePicker {
            let tuple = CoreDataManager.shared.actionAction(actionName: action,
                                                              contact: contact,
                                                              deadline: deadlineDate,
                                                              actionType: actionType)
            if let error = tuple.error {
                showError(title: "Error", message: "\(error)")
            } else {
                dismiss(animated: true, completion: {
                    guard let action = tuple.action else { return }
                    self.delegate?.didAddAction(action: action)
                })
            }

         } else {
            let tuple = CoreDataManager.shared.actionAction(actionName: action,
                                                            contact: contact,
                                                            actionType: actionType)
            if let error = tuple.error {
              showError(title: "Error", message: "\(error)")
            } else {
                dismiss(animated: true, completion: {
                    guard let action = tuple.action else { return }
                    self.delegate?.didAddAction(action: action)
                })
            }
        }
    }

    var isAddingDatePicker = false
    let extraLightBlueBackgroundView = UIView()
    @objc func addDatePicker() {

        isAddingDatePicker.toggle()

        if isAddingDatePicker {
            addDeadlineButton.setTitle("Remove Deadline", for: .normal)
            extraLightBlueBackgroundView.backgroundColor = .lightBlue
            extraLightBlueBackgroundView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(extraLightBlueBackgroundView)
            extraLightBlueBackgroundView.anchor(top: lightBlueBackgroundView.bottomAnchor, left: view.leftAnchor,
                                           bottom: nil, right: view.rightAnchor,
                                           paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                                           width: 0, height: 150)

            view.addSubview(datePicker)
            datePicker.anchor(top: extraLightBlueBackgroundView.topAnchor, left: view.leftAnchor,
                              bottom: extraLightBlueBackgroundView.bottomAnchor, right: view.rightAnchor,
                              paddingTop: 8, paddingLeft: 16,
                              paddingBottom: 8, paddingRight: 16,
                              width: 0, height: 0)
        } else {
            addDeadlineButton.setTitle("Add Deadline", for: .normal)
            extraLightBlueBackgroundView.removeFromSuperview()
            datePicker.removeFromSuperview()
        }

    }

    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok",
                                                style: .default,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    let actionTypeSegmentedControl: UISegmentedControl = {
        let types = ["Doing","To Do", "Done"]
        let sc = UISegmentedControl(items: types)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .darkBlue
        return sc
    }()


    var lightBlueBackgroundView = UIView()

    func setupUI() {

        lightBlueBackgroundView = setUpLightBlueBackgroundView(height: 170)

        view.addSubview(actionLabel)
        actionLabel.anchor(top: lightBlueBackgroundView.topAnchor, left: view.leftAnchor,
                         bottom: nil, right: nil,
                         paddingTop: 12, paddingLeft: 16,
                         paddingBottom: 0, paddingRight: 0,
                         width: 100, height: 50)

        view.addSubview(actionTextField)
        actionTextField.anchor(top: actionLabel.topAnchor, left: actionLabel.rightAnchor,
                             bottom: actionLabel.bottomAnchor, right: view.rightAnchor,
                             paddingTop: 0, paddingLeft: 0,
                             paddingBottom: 0, paddingRight: 0
            , width: 0, height: 0)

        view.addSubview(actionTypeSegmentedControl)
        actionTypeSegmentedControl.anchor(top: actionLabel.bottomAnchor, left: view.leftAnchor,
                                            bottom: nil, right: view.rightAnchor,
                                            paddingTop: 8, paddingLeft: 16,
                                            paddingBottom: 0, paddingRight: 16,
                                            width: 0, height: 40)

        view.addSubview(addDeadlineButton)
        addDeadlineButton.anchor(top: actionTypeSegmentedControl.bottomAnchor, left: view.leftAnchor,
               bottom: nil, right: nil,
               paddingTop: 12, paddingLeft: 16,
               paddingBottom: 0, paddingRight: 0,
               width: 170, height: 40)

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.title = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
                    self.navigationItem.title = "Add Action"
                    self.navigationController?.navigationBar.prefersLargeTitles = true
            }
        }
    }

}
