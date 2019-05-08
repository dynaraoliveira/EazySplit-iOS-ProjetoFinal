import Foundation
import UIKit
import CPF_CNPJ_Validator

class ValidationError: Error {
    var message: String
    var label: UILabel
    
    init(_ message: String, _ label: UILabel) {
        self.message = message
        self.label = label
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case email(label: UILabel)
    case password(label: UILabel, compare: String?)
    case requiredField(field: String, label: UILabel)
    case date(label: UILabel)
    case phone(label: UILabel)
    case document(label: UILabel)
    case validate(label: UILabel)
}

enum ValidatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email(let label): return EmailValidator(label)
        case .password(let label, let compare): return PasswordValidator(label, compare)
        case .requiredField(let fieldName, let label): return RequiredFieldValidator(fieldName, label)
        case .date(let label): return DateValidator(label)
        case .phone(let label): return PhoneValidator(label)
        case .document(let label): return DocumentValidator(label)
        case .validate(let label): return ValidateValidator(label)
        }
    }
}

struct RequiredFieldValidator: ValidatorConvertible {
    private let fieldName: String
    private let errorLabel: UILabel
    
    init(_ field: String, _ errorLabel: UILabel) {
        fieldName = field
        self.errorLabel = errorLabel
    }
    
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Required field " + fieldName, errorLabel)
        }
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    private let errorLabel: UILabel
    private let compare: String?
    
    init(_ errorLabel: UILabel, _ compare: String? = "") {
        self.errorLabel = errorLabel
        self.compare = compare
    }
    
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("Password is required", errorLabel)}
        guard value.count >= 6 else { throw ValidationError("Password must have at least 6 characters", errorLabel) }
        if !(compare ?? "").isEmpty {
            guard value == compare else { throw ValidationError("Password does not match", errorLabel) }
        }
        
        return value
    }
}

struct EmailValidator: ValidatorConvertible {
    private let errorLabel: UILabel
    
    init(_ errorLabel: UILabel) {
        self.errorLabel = errorLabel
    }
    
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid e-mail", errorLabel)
            }
        } catch {
            throw ValidationError("Invalid e-mail", errorLabel)
        }
        return value
    }
}

struct DateValidator: ValidatorConvertible {
    private let errorLabel: UILabel
    
    init(_ errorLabel: UILabel) {
        self.errorLabel = errorLabel
    }
    
    func validated(_ value: String) throws -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard dateFormatter.date(from: value) != nil else {
            throw ValidationError("Invalid date", errorLabel)
        }
        
        return value
    }
}

struct PhoneValidator: ValidatorConvertible {
    private let errorLabel: UILabel
    
    init(_ errorLabel: UILabel) {
        self.errorLabel = errorLabel
    }
    
    func validated(_ value: String) throws -> String {
        let phone = NSPredicate(format: "SELF MATCHES %@", "^((\\+)|(00))[0-9]{6,14}$")
        let valuePhone = value.removeCharsFromStringPhone
        guard phone.evaluate(with: valuePhone) else {
            throw ValidationError("Invalid phone", errorLabel)
        }
        
        return valuePhone
    }
}

struct DocumentValidator: ValidatorConvertible {
    private let errorLabel: UILabel
    
    init(_ errorLabel: UILabel) {
        self.errorLabel = errorLabel
    }
    
    func validated(_ value: String) throws -> String {
        let valueDocument = value.removeCharsFromStringPhone
        guard BooleanValidator().validate(cpf: valueDocument) else {
            throw ValidationError("Invalid document", errorLabel)
        }
        
        return valueDocument
    }
}

struct ValidateValidator: ValidatorConvertible {
    private let errorLabel: UILabel
    
    init(_ errorLabel: UILabel) {
        self.errorLabel = errorLabel
    }
    
    func validated(_ value: String) throws -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        
        guard dateFormatter.date(from: value) != nil else {
            throw ValidationError("Invalid validate", errorLabel)
        }
        
        return value
    }
}
