//
//  ActionNotesTextView.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 25/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {

    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter notes..."
        label.textColor = .darkBlue
        label.font = UIFont(name: "Avenir-Roman", size: 14)
        return label
    }()

    func hidePlaceholderLabel() {
        placeholderLabel.isHidden = true
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange),
                                               name: UITextView.textDidChangeNotification, object: nil)

        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                paddingTop: 12, paddingLeft: 8,
                                paddingBottom: 0, paddingRight: 0,
                                width: 0, height: 0)
        UITextView.appearance().tintColor = .darkBlue
    }

    @objc func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
