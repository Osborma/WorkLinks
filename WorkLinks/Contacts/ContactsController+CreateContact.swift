//
//  ContactsController+CreateContact.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 20/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit

extension ContactsController: CreateContactControllerDelegate {

    func didAddContact(contact: Contact) {
        contacts.append(contact)
        let newIndexPath = IndexPath(row: contacts.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }

    func didEditContact(contact: Contact) {
        let row = contacts.index(of: contact)
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        tableView.reloadRows(at: [reloadIndexPath], with: .middle)
    }

}
