//
//  ActionsController.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 20/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit
import CoreData

class ActionsController: UITableViewController, AddActionControllerDelegate, UITextViewDelegate {

    var actions = [Action]()

    let cellId = "cellId"
    var allActions = [[Action]]()

    var contact: Contact? {
        didSet {
            if let imageData = contact?.imageData {
                contactImageView.image = UIImage(data: imageData)
            }

            if let firstname = contact?.firstname, let surname = contact?.surname {
                fullnameLabel.text = "\(firstname) \(surname)"
            }

            if let company = contact?.company {
                companyLabel.text = "\(company)"
            }

            if let notes = contact?.notes {
                if !notes.isEmpty {
                    notesTextView.hidePlaceholderLabel()
                    notesTextView.text = notes
                }
            }
        }
    }

    lazy var contactImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "fullname"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let companyLabel: UILabel = {
        let label = UILabel()
        label.text = "company"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let mobileButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "mobile.png"), for: .normal)
        button.setTitleColor( .darkBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(callMobile), for: .touchUpInside)
        return button
    }()

    let phoneButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "phone"), for: .normal)
        button.setTitleColor( .darkBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(callPhone), for: .touchUpInside)
        return button
    }()

    let emailButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "email"), for: .normal)
        button.setTitleColor( .darkBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openEmail), for: .touchUpInside)
        return button
    }()

    @objc func callMobile() {
        if let mobileNumber = contact?.mobile, !mobileNumber.isEmpty {
            if let url = URL(string: "tel://\(mobileNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            showError(title: "No mobile saved", message: "Please edit the contact to call")
        }
    }

    @objc func callPhone() {
        if let phoneNumber = contact?.phone, !phoneNumber.isEmpty{
            if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            showError(title: "No phone saved", message: "Please edit the contact to call")
        }
    }

    @objc func openEmail() {
        if let email = contact?.email, !email.isEmpty{
            if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            showError(title: "No email saved", message: "Please edit the contact to email")
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

    private let notesTextView: CommentInputTextView = {
        let textView = CommentInputTextView()
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.lightBlue
        textView.textColor = .darkBlue
        textView.layer.cornerRadius = 15
        textView.font = UIFont(name: "Avenir-Roman", size: 14)
        textView.autocapitalizationType = .none
        textView.textColor = .black
        return textView
    }()

    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here

        guard let notes = notesTextView.text else { return }

        DispatchQueue.global(qos: .background).async {
            let context = CoreDataManager.shared.persistentContainer.viewContext

            self.contact?.notes = notes

            do {
                try  context.save()
            } catch let saveErr {
                print("Failed to save notes:", saveErr)
            }
        }
    }

    private func fetchActions() {
        guard let contactActions = contact?.actions?.allObjects as? [Action] else { return }
        self.actions = contactActions

        arrayOfTypes = findAllTypes()

        if !arrayOfTypes.isEmpty {
            for i in 1...arrayOfTypes.count {
                allActions.append(contactActions.filter {  $0.type == arrayOfTypes[i - 1] })
            }
        } else {
            actions = []
        }

    }

    var setOfTypes = Set<String>() // Set to avoid duplicates of the same type
    var arrayOfTypes = [] as! [String] // array as it is easier to work with

    let typeOrder = ["Doing", "To Do", "Done"]
    /// Mark: appends new action to set and updates the arrayOfTypes
    func findAllTypes() -> [String] {
        actions.forEach({ (action) in
            if let actionType = action.type {
                setOfTypes.insert(actionType)
                arrayOfTypes = Array(setOfTypes)
                arrayOfTypes.orderActionTypes()
            }
        })

        return arrayOfTypes
    }



    var isCreatingNewType = false
    var newActionType = String()
    func didAddAction(action: Action) {

        self.actions.append(action)
        guard let actionType = action.type else { return }
        isCreatingNewType = false

        if let index = arrayOfTypes.index(of: actionType) { // append to exsiting type
            let row = allActions[index].count
            let insertionIndexPath = IndexPath(row: row, section: index + 1)
            allActions[index].append(action)
            tableView.insertRows(at: [insertionIndexPath], with: .middle)
        } else if allActions.isEmpty { //create the first type
            arrayOfTypes = findAllTypes()
            allActions.append([action])
            tableView.reloadData()
        } else { // create new type
            isCreatingNewType = true
            newActionType = actionType
            arrayOfTypes = findAllTypes()
            allActions.append([action])
            let index = arrayOfTypes.count
            tableView.insertSections([index], with: .top)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)

        setupAddButtonInNavBar(selector: #selector(handleAdd))

        fetchActions()

        tableView.tableFooterView = UIView()

        tableView?.reloadData()

        tableView.keyboardDismissMode = .onDrag

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    @objc func handleAdd() {
        let addActionController = AddActionController()
        addActionController.delegate = self
        addActionController.contact = contact
        
        let navController =
            CustomNavigationController(rootViewController: addActionController)
        present(navController , animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       if let firstname = contact?.firstname, let surname = contact?.surname {
            navigationItem.title = "\(firstname) \(surname)"
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if section == 0 {
            addProfileImageUI(headerView: view)

            let buttonsStackView = UIStackView(arrangedSubviews: [mobileButton,
                                                                  phoneButton,
                                                                  emailButton])

            buttonsStackView.distribution = .fillEqually
            buttonsStackView.axis = .horizontal
            buttonsStackView.spacing = 45

            view.addSubview(buttonsStackView)
            buttonsStackView.anchor(top: contactImageView.bottomAnchor, left: nil,
                                    bottom: nil, right: nil,
                                    paddingTop: 24, paddingLeft: 24,
                                    paddingBottom: 0, paddingRight: 24,
                                    width: (60 * 3) + (45 * 2), height: 60)
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

            // add full name
            view.addSubview(fullnameLabel)
            // width based on characte length of name
            let fullNameHeight = CGFloat(28)
            fullnameLabel.anchor(top: buttonsStackView.bottomAnchor, left: nil,
                                 bottom: nil, right: nil,
                                 paddingTop: 16, paddingLeft: 12, paddingBottom: 10, paddingRight: 12,
                                 width: 0, height: fullNameHeight)
            fullnameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            fullnameLabel.adjustsFontSizeToFitWidth = true

            // add lines next to fullname
            let leftLine = UIView()
            leftLine.backgroundColor = UIColor.darkBlue.lighter(by: 10)
            let rightLine = UIView()
            rightLine.backgroundColor = UIColor.darkBlue.lighter(by: 10)
            view.addSubview(leftLine)
            view.addSubview(rightLine)
            let linePadding = (fullNameHeight - 0.5) / 2
            leftLine.anchor(top: fullnameLabel.topAnchor, left: view.leftAnchor,
                            bottom: nil, right: fullnameLabel.leftAnchor,
                            paddingTop: linePadding, paddingLeft: 30, paddingBottom: 0, paddingRight: 8,
                            width: 0, height: 0.5)
            rightLine.anchor(top: fullnameLabel.topAnchor, left: fullnameLabel.rightAnchor,
                             bottom: nil, right: view.rightAnchor,
                             paddingTop: linePadding, paddingLeft: 8, paddingBottom: 0, paddingRight: 30,
                             width: 0, height: 0.5)

            // add full name
            view.addSubview(companyLabel)
            // width based on characte length of name
            let companyHeight = CGFloat(20)
            companyLabel.anchor(top: fullnameLabel.bottomAnchor, left: nil,
                                 bottom: nil, right: nil,
                                 paddingTop: 0, paddingLeft: 12, paddingBottom: 10, paddingRight: 12,
                                 width: 0, height: companyHeight)
            companyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            companyLabel.adjustsFontSizeToFitWidth = true

            let containerView = UIView()
            containerView.backgroundColor = .lightBlue
            containerView.layer.cornerRadius = 15

            view.addSubview(containerView)
            containerView.anchor(top: companyLabel.bottomAnchor, left: view.leftAnchor,
                                bottom: view.bottomAnchor, right: view.rightAnchor,
                                paddingTop: 12, paddingLeft: 16,
                                paddingBottom: -34, paddingRight: 16,
                                width: 0, height: 0)

            notesTextView.delegate = self
            containerView.addSubview(notesTextView)
            notesTextView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor,
                                 bottom: containerView.bottomAnchor, right: containerView.rightAnchor,
                                 paddingTop: 12, paddingLeft: 16,
                                 paddingBottom: 0, paddingRight: 8,
                                 width: 0, height: 0)
            containerView.layer.zPosition = -100
            notesTextView.layer.zPosition = -99
            return view
        } else {

            if actions.count > 0 {
                let label = UILabel()
                label.backgroundColor = .lightBlue
                if isCreatingNewType {
                    label.text = newActionType
                } else {
                    label.text = arrayOfTypes[section - 1]
                }
                label.font = UIFont.boldSystemFont(ofSize: 16)
                label.textColor = .darkBlue

                view.addSubview(label)
                label.anchor(top: view.topAnchor, left: view.leftAnchor,
                             bottom: view.bottomAnchor, right: nil,
                             paddingTop: 0, paddingLeft: 16,
                             paddingBottom: 0, paddingRight: 0,
                             width: 0, height: 0)

                view.backgroundColor = .lightBlue
                view.addSubview(label)
            }
            return view
        }
    }


    private func addProfileImageUI(headerView: UIView) {
        
        headerView.addSubview(contactImageView)
        contactImageView.anchor(top: headerView.topAnchor, left: nil,
                                bottom: nil, right: nil,
                                paddingTop: 16, paddingLeft: 0,
                                paddingBottom: 0, paddingRight: 0,
                                width: 100, height: 100)
        contactImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = 100 / 2
        contactImageView.contentMode = .scaleAspectFill
    }

    var isInPortaitMode = true
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            isInPortaitMode = false
        } else {
            isInPortaitMode = true
        }
    }

    /// Shifts the view up to accomodate the keyboard
    ///
    /// - Parameter notification: The Notification sent from `NotificationCenter` to notify that the keyboard
    ///     has appeared
    @objc func keyboardWillShow(notification _: NSNotification) {
        if (view.frame.origin.y == 140 || view.frame.origin.y == 111) , isInPortaitMode {
            view.frame.origin.y -= (200)
        } else if view.frame.origin.y == 32, !isInPortaitMode {
            view.frame.origin.y -= (200)
        }
    }

    /// Resets the view when the keyboard disappears
    ///
    /// - Parameter notification: The Notification sent from `NotificationCenter` to notify that the keyboard
    ///     has disappeared
    @objc func keyboardWillHide(notification _: NSNotification) {
        if (view.frame.origin.y != 140 || view.frame.origin.y != 111) , isInPortaitMode {
            view.frame.origin.y = 140
        } else if view.frame.origin.y != 32, !isInPortaitMode {
            view.frame.origin.y = 32
        }
    }
}

extension Array where Element == String {
    func orderActionTypes() -> [String] {
        let actionOrder = ["Doing", "To Do", "Done"]
        return self.sorted(by: { (a, b) -> Bool in
            if let first = actionOrder.index(of: a), let second = actionOrder.index(of: b) {
                return first < second
            }
            return false
        })
    }
}
