//
//  AddMeansOfPaymentViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 02/05/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit

class AddMeansOfPaymentViewController: UIViewController {

    var card: Card?
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var validateTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var documentTextField: UITextField!
    @IBOutlet weak var numberErrorLabel: UILabel!
    @IBOutlet weak var cvcErrorLabel: UILabel!
    @IBOutlet weak var validateErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var documentErrorLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cleanErrors()
        setDelegate()
        setRegisterButton()
        
        if let card = card {
            loadUserData(card)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func loadUserData(_ card: Card) {
        numberTextField.text = card.number
        cvcTextField.text = "\(card.codeValidate)"
        validateTextField.text = "\(card.monthValidate)/\(card.yearValidate)"
        nameTextField.text = card.name
        documentTextField.text = card.document
    }
    
    private func cleanErrors() {
        numberErrorLabel.text = ""
        cvcErrorLabel.text = ""
        validateErrorLabel.text = ""
        nameErrorLabel.text = ""
        documentErrorLabel.text = ""
    }
    
    private func setDelegate() {
        numberTextField.delegate = self
        cvcTextField.delegate = self
        validateTextField.delegate = self
        nameTextField.delegate = self
        documentTextField.delegate = self
    }
    
    private func setRegisterButton() {
        saveButton.loadCornerRadius()
    }
    
    @IBAction func saveClick(_ sender: Any) {
        validate()
    }
    
    private func validate() {
        do {
            let number = try numberTextField.validatedText(validationType: .requiredField(field: "Number", label: numberErrorLabel))
            let codeValidate = try cvcTextField.validatedText(validationType: .requiredField(field: "Code Validate", label: cvcErrorLabel))
            let name = try nameTextField.validatedText(validationType: .requiredField(field: "Name", label: nameErrorLabel))
            let validate = try validateTextField.validatedText(validationType: ValidatorType.validate(label: validateErrorLabel))
            let document = try documentTextField.validatedText(validationType: ValidatorType.document(label: documentErrorLabel))
            
            guard let validateDate = dateFormatter.date(from: validate) else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: validateDate)
            formatter.dateFormat = "MM"
            let month = formatter.string(from: validateDate)
            
            let card = Card(id: self.card?.id ?? "", number: number, name: name, flag: "", codeValidate: Int(codeValidate) ?? 0, monthValidate: Int(month) ?? 0, yearValidate: Int(year) ?? 0, document: document)

            saveCard(card)
            
        } catch(let error) {
            let errorLabel = (error as! ValidationError).label
            errorLabel.text = (error as! ValidationError).message
        }
    }
    
    private func saveCard(_ card: Card) {
        Loader.shared.showOverlay(view: self.view)
        
        FirebaseService.shared.saveCard(card, completion: { () in
            Loader.shared.hideOverlayView()
            self.navigationController?.popViewController(animated: true)
        })
    }
}


extension AddMeansOfPaymentViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        cleanErrors()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return false }
        
        let char = string.cString(using: String.Encoding.utf8)
        let isBackSpace = strcmp(char, "\\b")
        
        switch textField.tag {
        case 1:
            textField.text = text.applyPatternOnNumbers(pattern: "####.####.####.####", replacmentCharacter: "#")
            if textField.text?.count ?? 0 >= 19 && isBackSpace != -92 { return false }
        case 2:
            if textField.text?.count ?? 0 >= 3 && isBackSpace != -92 { return false }
        case 3:
            if textField.text?.count ?? 0 >= 5 && isBackSpace != -92 { return false }
            textField.text = text.applyPatternOnNumbers(pattern: "##/##", replacmentCharacter: "#")
        case 5:
            if textField.text?.count ?? 0 >= 14 && isBackSpace != -92 { return false }
            textField.text = text.applyPatternOnNumbers(pattern: "###.###.###-##", replacmentCharacter: "#")
        default:
            return true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
