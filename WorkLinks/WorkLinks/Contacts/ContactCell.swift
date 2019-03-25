//
//  ContactCell.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 20/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    var contact: Contact? {
        didSet {

            if let imageData = contact?.imageData {
                contactImageView.image = UIImage(data: imageData)
            }

            if let firstname = contact?.firstname, let surname = contact?.surname {
                contactLabel.text = "\(firstname) \(surname)"
            }

            if let company = contact?.company {
                companyLabel.text = "\(company)"
            }

            if let actions = contact?.actions?.count, let company = contact?.company   {
                if actions > 0 {
                    companyLabel.text = "\(company) • \(actions) actions"
                }
            }
        }
    }

    let contactImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let contactLabel: UILabel = {
        let label = UILabel()
        label.text = "Contact Name"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let companyLabel: UILabel = {
        let label = UILabel()
        label.text = "Company"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.darkBlue.lighter(by: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white

        addSubview(contactImageView)
        let contactImageViewDiameter = CGFloat(50)
        contactImageView.anchor(top: nil, left: leftAnchor,
                                bottom: nil, right: nil,
                                paddingTop: 0, paddingLeft: 16,
                                paddingBottom: 0, paddingRight: 0,
                                width: contactImageViewDiameter, height: contactImageViewDiameter)
        contactImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = contactImageViewDiameter / 2

        addSubview(contactLabel)
        contactLabel.anchor(top: topAnchor, left: contactImageView.rightAnchor,
                                    bottom: nil, right: nil,
                                    paddingTop: 12, paddingLeft: 16,
                                    paddingBottom: 0, paddingRight: 0,
                                    width: 0, height: 25)

        addSubview(companyLabel)
        companyLabel.anchor(top: contactLabel.topAnchor, left: contactImageView.rightAnchor,
                            bottom: bottomAnchor, right: nil,
                            paddingTop: 12, paddingLeft: 16,
                            paddingBottom: 0, paddingRight: 0,
                            width: 0, height: 25)


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
