//
//  ContactsController.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 19/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit
import CoreData

class ContactsController: UITableViewController, UISearchBarDelegate {

    var contacts = [Contact]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.contacts = CoreDataManager.shared.fetchContacts()

        view.backgroundColor = .white

        navigationItem.title = "Contacts"

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Delete all",
                            style: .plain,
                            target: self,
                            action: #selector(handleReset))

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Create",
                            style: .plain,
                            target: self,
                            action: #selector(handleAddContact))

        tableView.register(ContactCell.self, forCellReuseIdentifier: "cellId")

        tableView.tableFooterView = UIView()

        tableView.keyboardDismissMode = .onDrag

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    @objc func handleAddContact() {
        let createContactController = CreateContactController()

        let navController =
            CustomNavigationController(rootViewController: createContactController)

        createContactController.delegate = self

        present(navController, animated: true, completion: nil)
    }

    @objc func handleReset() {
        if CoreDataManager.shared.handleReset() {
            var indexPathsToRemove = [IndexPath]()
            for (index, _) in contacts.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            contacts.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightBlue

        view.addSubview(searchBarUsers)
        searchBarUsers.anchor(top: view.topAnchor, left: view.leftAnchor,
                     bottom: view.bottomAnchor, right: view.rightAnchor,
                     paddingTop: 4, paddingLeft: 18,
                     paddingBottom: 4, paddingRight: 18,
                     width: 0, height: 0)
        return view
    }

    private lazy var searchBarUsers: UISearchBar = {
        let searchBar = UISearchBar()

        searchBar.tintColor = .lightBlue
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .darkBlue

        searchBar.barTintColor = .lightBlue

        searchBar.layer.borderColor = searchBar.barTintColor?.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.searchBarStyle = .minimal


        searchBar.placeholder = "Enter contact name"
        searchBar.delegate = self

        searchBar.keyboardAppearance = .light
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none

        searchBar.layer.cornerRadius = 20
        searchBar.clipsToBounds = true

        searchBar.setImage(UIImage(named: "search_unselected"), for: .search, state: .normal)

        return searchBar
    }()

    func searchBar(_: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            navigationController?.navigationBar.prefersLargeTitles = true
            self.searchBarUsers.setImage(UIImage(named: "search_unselected"), for: .search, state: .normal)
            contacts = CoreDataManager.shared.fetchContacts()
            view.frame.origin.y = 0
        } else {
            navigationController?.navigationBar.prefersLargeTitles = false
            self.searchBarUsers.setImage(UIImage(named: "search_selected"), for: .search, state: .normal)
            contacts = contacts.filter({ (contact) -> Bool in
                guard let firstname = contact.firstname else { return false }
                guard let surname = contact.surname else { return false }
                let name = "\(firstname) \(surname)"
                return name.lowercased().contains(searchText.lowercased())
            })
        }

        tableView?.reloadData()
    }

}

