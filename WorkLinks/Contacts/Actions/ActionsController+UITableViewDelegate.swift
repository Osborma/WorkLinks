//
//  ActionsController+UITableViewDelegate.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 25/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit

extension ActionsController {

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No actions stored for this contact..."
        label.textColor = .darkBlue
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return actions.count == 0 ? 150 : 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if actions.count > 0 {
            return (allActions.count + 1)
        } else {
            return 1
        }
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 350
        } else {
            return 50
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
         if actions.count > 0, indexPath.section > 0 {
            let action = allActions[indexPath.section - 1][indexPath.row]
            cell.textLabel?.text = action.name


            if let deadline = action.actionInformation?.deadline{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyy"
                let deadlineDateString = dateFormatter.string(from: deadline)
                cell.textLabel?.text = "\(action.name ?? "") •  \(deadlineDateString)"
            }

            cell.backgroundColor = .tealColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
         }

        cell.isUserInteractionEnabled = false

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if actions.count > 0, section > 0 {
            return allActions[section - 1].count
        } else {
            return 1
        }
    }
}
