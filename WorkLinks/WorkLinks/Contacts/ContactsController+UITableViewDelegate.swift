//
//  ContactsController+UITableViewDelegate.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 20/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit

extension ContactsController {

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        let contact = contacts[indexPath.row]
        let actionsController = ActionsController()
        actionsController.contact = contact
        navigationController?.pushViewController(actionsController, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let contact = self.contacts[indexPath.row]
            self.contacts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

            let context = CoreDataManager.shared.persistentContainer.viewContext
            context.delete(contact)
            do {
                try context.save()
            } catch let saveErr {
                print("Failed to delete Contact: ", saveErr)
            }
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: editHandlerFunction)

        deleteAction.backgroundColor = .darkBlue
        editAction.backgroundColor = .tealColor

        return [deleteAction, editAction]
    }

    private func editHandlerFunction(action: UITableViewRowAction, indexPath: IndexPath) {
        let editContactController = CreateContactController()
        editContactController.contact = contacts[indexPath.row]
        editContactController.delegate = self
        let navController =
            CustomNavigationController(rootViewController: editContactController)
        dismissKeyboard()
        present(navController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return contacts.count == 0 ? 0 : 60
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No contacts available..."
        label.textColor = .darkBlue
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return contacts.count == 0 ? 200 : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for:  indexPath) as! ContactCell

        let contact = contacts[indexPath.row]
        cell.contact = contact
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
}
