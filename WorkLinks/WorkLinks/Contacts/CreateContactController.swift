//
//  CreateContactController.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 19/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit
import Photos
import CoreData

protocol CreateContactControllerDelegate {
    func didAddContact(contact: Contact)
    func didEditContact(contact: Contact)
}

class CreateContactController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UITextFieldDelegate {

    var contact: Contact? {
        didSet {
            firstnameTextField.text = contact?.firstname
            surnameTextField.text = contact?.surname
            companyTextField.text = contact?.company

            if let imageData = contact?.imageData {
                contactImageView.image = UIImage(data: imageData)
                currentImage =  UIImage(data: imageData)!
            }

            if let email = contact?.email, !email.isEmpty {
                emailTextField.text = email
            }

            if let mobile = contact?.mobile, !mobile.isEmpty {
                mobileTextField.text = mobile
            }

            if let phone = contact?.phone, !phone.isEmpty {
                phoneTextField.text = phone
            }
        }
    }

    var currentImage = #imageLiteral(resourceName: "select_photo_empty")

    var delegate: CreateContactControllerDelegate?

    lazy var contactImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))
        return imageView
    }()

    let takePictureButton: UIButton = {
        let button = UIButton()
        button.setTitle("Capture", for: .normal)
        button.setTitleColor( .darkBlue, for: .normal)
        button.backgroundColor = UIColor.lightBlue.darker(by: 8)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePicture), for: .touchUpInside)
        return button
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cancel.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTakingPicture), for: .touchUpInside)
        return button
    }()

    var isFrontCamera = true
    let swapCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "swapToBack"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSwap), for: .touchUpInside)
        return button
    }()

    let firstnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Firstname"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let surnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Surname"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let companyLabel: UILabel = {
        let label = UILabel()
        label.text = "Company"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let mobileLabel: UILabel = {
        let label = UILabel()
        label.text = "Mobile"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let firstnameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter firstname"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 1
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        return textField
    }()

    let surnameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter surname"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 2
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        return textField
    }()

    let companyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter company"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 3
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        return textField
    }()

    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 4
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()

    let mobileTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter mobile number"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 5
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.keyboardType = .phonePad
        return textField
    }()

    let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter phone number"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.keyboardType = .phonePad
        return textField
    }()


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return false
    }

    @objc private func handleSelectPhoto() {
        handleCancelTakingPicture()

        let message = contact == nil ? "Create profile picture" : "Change profile picture?"
        let alertController = UIAlertController(title: nil, message: message,
                                                preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { _ in
            self.chooseFromLibrary()
        }))
        alertController.addAction(UIAlertAction(title: "Take a picture", style: .default, handler: { _ in
            self.takePicture()
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)

    }

    func chooseFromLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            contactImageView.image = editedImage
            currentImage = editedImage

        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage]  as? UIImage {
            contactImageView.image = originalImage
            currentImage = originalImage
        }

        dismiss(animated: true, completion: nil)
    }


    @objc func capturePicture() {
        takePictureButton.removeFromSuperview()
        swapCameraButton.removeFromSuperview()
        cancelButton.removeFromSuperview()
        cameraView?.removeFromSuperview()

        cameraController.handleCapturePhoto(isFrontCamera: isFrontCamera)
        contactImageView = previewPhotoContainer.previewImageView
        addContactImageView()

        pictureView.clipsToBounds = true
        pictureView.layer.cornerRadius = contactImageViewDiameter / 2

        pictureView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(handleSelectPhoto)))
    }

    @objc func cancelTakingPicture() {
        handleCancelTakingPicture()
    }

    func handleCancelTakingPicture() {
        takePictureButton.removeFromSuperview()
        swapCameraButton.removeFromSuperview()
        cancelButton.removeFromSuperview()
        cameraView?.removeFromSuperview()

        contactImageView.image = currentImage
        addContactImageView()
        pictureView.clipsToBounds = true
        pictureView.layer.cornerRadius = contactImageViewDiameter / 2
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = contactImageViewDiameter / 2

        pictureView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(handleSelectPhoto)))
    }

    @objc func handleSwap() {
        let image = isFrontCamera == true ?  #imageLiteral(resourceName: "swapToFront"): #imageLiteral(resourceName: "swapToBack.png")

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0,
                       options: .curveEaseOut, animations: {
                        self.swapCameraButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        UIView.animate(withDuration: 0.9, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0,
                       options: .curveEaseOut, animations: {
                        self.swapCameraButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.swapCameraButton.setImage(image, for: .normal)
        })

        cameraController.swapCamera(isFrontCamera: isFrontCamera)
        isFrontCamera.toggle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        view.backgroundColor = .white

        setupCancelButtonInNavBar()

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

        hideKeyboardWhenTappedAround()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = contact == nil ? "Create Contact" : "Edit Contact"

    }

    private func takePicture() {
        if hasAccessToCamera() {
            addPictureTakingViews()
        } else {
            PHPhotoLibrary.requestAuthorization { status -> Void in
                switch status {
                case .authorized:
                   self.addPictureTakingViews()
                case .denied, .restricted, .notDetermined:
                    self.showError(title: "You didn't grant Camera access",
                              message: "Please go into your settings and change the camera access")
                }
            }
        }
    }

    var cameraView: UIView?
    private func addPictureTakingViews() {

        cameraView = self.cameraController.view

        contactImageView.image = nil

        contactImageView.gestureRecognizers?.removeAll()
        contactImageView.removeFromSuperview()

        pictureView.addSubview(cameraView!)
        cameraView!.anchor(top: pictureView.topAnchor, left: pictureView.leftAnchor,
                          bottom: pictureView.bottomAnchor, right: pictureView.rightAnchor,
                          paddingTop: 0, paddingLeft: 0,
                          paddingBottom: 0, paddingRight: 0,
                          width: 0, height: 0)
        cameraView!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraView!.clipsToBounds = true
        cameraView!.layer.cornerRadius = contactImageViewDiameter / 2
        cameraView!.contentMode = .scaleAspectFill

        view.addSubview(takePictureButton)
        takePictureButton.anchor(top: cameraController.view.bottomAnchor, left: nil,
                                 bottom: nil, right: nil,
                                 paddingTop: 12, paddingLeft: 0,
                                 paddingBottom: 0, paddingRight: 0,
                                 width: 100, height: 40)
        takePictureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(swapCameraButton)
        swapCameraButton.anchor(top: nil, left: takePictureButton.rightAnchor,
                                bottom: takePictureButton.bottomAnchor, right: nil,
                                paddingTop: 0, paddingLeft: 16,
                                paddingBottom: 4, paddingRight: 0,
                                width: 40, height: 32)

        view.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: nil,
                                bottom: takePictureButton.bottomAnchor, right: takePictureButton.leftAnchor,
                                paddingTop: 0, paddingLeft: 0,
                                paddingBottom: 4, paddingRight: 12,
                                width: 32, height: 32)
    }

    lazy var previewPhotoContainer: PreviewPhotoContainerView = {
        let containerView = PreviewPhotoContainerView()
        return containerView
    }()
    
    private lazy var cameraController: CameraController = {
        let controller = CameraController()
        controller.previewContainerView = self.previewPhotoContainer
        return controller
    }()


    private func hasAccessToCamera() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
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

    let pictureView = UIView()
    let contactImageViewDiameter = CGFloat(100)

    private func addContactImageView() {
        pictureView.addSubview(contactImageView)
        contactImageView.anchor(top: pictureView.topAnchor, left: pictureView.leftAnchor,
                                bottom: pictureView.bottomAnchor, right: pictureView.rightAnchor,
                                paddingTop: 0, paddingLeft: 0,
                                paddingBottom: 0, paddingRight: 0,
                                width: 0, height: 0)
        contactImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = contactImageViewDiameter / 2
        contactImageView.contentMode = .scaleAspectFill
    }

    private func setupUI() {

        _ = setUpLightBlueBackgroundView(height: 450)

        view.addSubview(pictureView)

        pictureView.anchor(top: view.topAnchor, left: nil,
                                bottom: nil, right: nil,
                                paddingTop: 16, paddingLeft: 0,
                                paddingBottom: 0, paddingRight: 0,
                                width: contactImageViewDiameter, height: contactImageViewDiameter)
        pictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pictureView.layer.cornerRadius = contactImageViewDiameter / 2

        addContactImageView()

        let labelStackView = UIStackView(arrangedSubviews: [firstnameLabel,
                                                            surnameLabel,
                                                            companyLabel,
                                                            emailLabel,
                                                            mobileLabel,
                                                            phoneLabel])
        labelStackView.distribution = .fillEqually
        labelStackView.axis = .vertical
        labelStackView.spacing = 6

        view.addSubview(labelStackView)
        labelStackView.anchor(top:  pictureView.bottomAnchor, left: view.leftAnchor,
                         bottom: nil, right: nil,
                         paddingTop: 62, paddingLeft: 16,
                         paddingBottom: 0, paddingRight: 0,
                         width: 100, height: ((33 * 6) + (6 * 5)) )

        firstnameTextField.delegate = self
        surnameTextField.delegate = self
        companyTextField.delegate = self
        emailTextField.delegate = self
        mobileTextField.delegate = self

        let textFieldStackView = UIStackView(arrangedSubviews: [firstnameTextField,
                                                                surnameTextField,
                                                                companyTextField,
                                                                emailTextField,
                                                                mobileTextField,
                                                                phoneTextField])
        textFieldStackView.distribution = .fillEqually
        textFieldStackView.axis = .vertical
        textFieldStackView.spacing = 6

        view.addSubview(textFieldStackView)
        textFieldStackView.anchor(top: labelStackView.topAnchor, left: labelStackView.rightAnchor,
                              bottom: nil, right: view.rightAnchor,
                              paddingTop: 0, paddingLeft: 0,
                              paddingBottom: 0, paddingRight: 0,
                              width: 0, height: ((33 * 6) + (6 * 5)) )

    }

    @objc func handleSave() {

        guard let firstname = firstnameTextField.text else { return }
        guard let surname = surnameTextField.text else { return }
        guard let company = companyTextField.text else { return }

        if let email = emailTextField.text, !email.isEmpty {
            validationTest(firstname: firstname, surname: surname, company: company, email: email)
            if !isValidEmail(testStr: email) { return }
        } else {
            validationTest(firstname: firstname, surname: surname, company: company)
        }

        if ![firstname, surname, company].allSatisfy({ (!($0.isEmpty)) }) {
            return
        } else if contact == nil {
            createContact(firstname: firstname, surname: surname, company: company)
        } else {
            saveContactChanges()
        }
    }

    func validationTest(firstname: String, surname: String, company: String, email: String = "") {
        if firstname.isEmpty {
            showError(title: "Empty firstname",
                      message: "Please enter a firstname")
        }
        if surname.isEmpty {
            showError(title: "Empty surname",
                      message: "Please enter a surname")
        }
        if company.isEmpty {
            showError(title: "Empty company",
                      message: "Please enter a company")
        }
        if !isValidEmail(testStr: email) && !email.isEmpty {
            showError(title: "InValid",
                      message: "Please enter a valid email")
        }
    }

    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"

        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    private func createContact(firstname: String, surname: String, company: String) {

        let context = CoreDataManager.shared.persistentContainer.viewContext

        let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context)


        contact.setValue(firstname, forKey: "firstname")

        contact.setValue(surname, forKey: "surname")

        contact.setValue(company, forKey: "company")

        if let mobile = mobileTextField.text, !mobile.isEmpty {
            contact.setValue(mobile, forKey: "mobile")
        } else {
            contact.setValue("", forKey: "mobile")
        }

        if let phone = phoneTextField.text, !phone.isEmpty {
            contact.setValue(phone, forKey: "phone")
        } else {
             contact.setValue("", forKey: "phone")
        }

        if let email = emailTextField.text, !email.isEmpty {
            contact.setValue(email, forKey: "email")
        } else {
            contact.setValue("", forKey: "email")
        }

        if let contactImage = contactImageView.image {
            let imageData = contactImage.jpegData(compressionQuality: 0.8)
            contact.setValue(imageData, forKey: "imageData")
        }

        contact.setValue("", forKey: "notes")

        do {
            try  context.save()
            dismiss(animated: true) {
                self.delegate?.didAddContact(contact: contact as! Contact)
            }
        } catch let saveErr {
            print("Failed to save contact:", saveErr)
        }
    }

    private func saveContactChanges() {

        let context = CoreDataManager.shared.persistentContainer.viewContext

        contact?.firstname = firstnameTextField.text

        contact?.surname = surnameTextField.text

        contact?.company = companyTextField.text

        if let contactImage = contactImageView.image {
            let imageData = contactImage.jpegData(compressionQuality: 0.8)
            contact?.imageData = imageData
        }

        if let mobile = mobileTextField.text, !mobile.isEmpty {
            contact?.mobile = mobile
        }

        if let phone = phoneTextField.text, !phone.isEmpty {
            contact?.phone = phone
        }

        if let email = emailTextField.text, !email.isEmpty {
            contact?.email = email
        }

        do {
            try context.save()
            dismiss(animated: true) {
                self.delegate?.didEditContact(contact: self.contact!)
            }
        } catch let saveErr {
            print("Failed to save contact changes:", saveErr)
        }
    }

    var isInPortaitMode = true
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            isInPortaitMode = false
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            isInPortaitMode = true
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.title = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
                self.navigationItem.title = self.contact == nil ? "Create Contact" : "Edit Contact"
                self.navigationController?.navigationBar.prefersLargeTitles = true
            }
        }
    }

    /// Shifts the view up to accomodate the keyboard
    ///
    /// - Parameter notification: The Notification sent from `NotificationCenter` to notify that the keyboard
    ///     has appeared
    var portraitOrigin = CGFloat()
    var landscapeOrigin = CGFloat()

    @objc func keyboardWillShow(notification _: NSNotification) {

        if (view.frame.origin.y == 140 || view.frame.origin.y == 111) , isInPortaitMode {
            portraitOrigin = view.frame.origin.y
            view.frame.origin.y -= (pictureView.frame.height + 70)
        } else if view.frame.origin.y == 32, !isInPortaitMode {
            landscapeOrigin = view.frame.origin.y
            view.frame.origin.y -= (pictureView.frame.height + 70)
        }
    }

    /// Resets the view when the keyboard disappears
    ///
    /// - Parameter notification: The Notification sent from `NotificationCenter` to notify that the keyboard
    ///     has disappeared
    @objc func keyboardWillHide(notification _: NSNotification) {
        if (view.frame.origin.y != 140 || view.frame.origin.y != 111), isInPortaitMode {
            view.frame.origin.y = portraitOrigin
        } else if view.frame.origin.y != 32, !isInPortaitMode {
             view.frame.origin.y = landscapeOrigin
        }
    }
}
