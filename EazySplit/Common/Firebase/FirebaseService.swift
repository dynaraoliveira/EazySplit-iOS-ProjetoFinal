//
//  FirebaseService.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 25/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

enum Result {
    case success
    case error(Error)
}

class FirebaseService {
    
    class var shared: FirebaseService {
        struct Static {
            static let instance: FirebaseService = FirebaseService()
        }
        return Static.instance
    }
    
    private let authFirebase: Auth
    private let collectionUsers = "users"
    private let collectionRestaurants = "restaurants"
    private let collectionCards = "cards"
    
    private var firestoreListener: ListenerRegistration!
    private var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        var firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    
    init() {
        authFirebase = Auth.auth()
    }
    
    func saveUser(_ user: User, photoData: Data? = nil, completion: @escaping((Result) -> Void)) {
        if authFirebase.currentUser != nil {
            self.savePhotoFireStorage(user, photoData, {
                completion(.success)
            })
        } else {
            authFirebase.createUser(withEmail: user.email, password: user.password) { (authResult, error) in
                if let error = error {
                    completion(.error(error))
                    return
                }
                
                self.savePhotoFireStorage(user, photoData, {
                    completion(.success)
                })
                
            }
        }
    }
    
    func saveCard(_ card: Card, completion: @escaping(() -> Void)) {
        let uid = authFirebase.currentUser?.uid ?? ""
        
        let docData: [String: Any] = [
            "number": card.number,
            "name": card.name,
            "codeValidate": card.codeValidate,
            "monthValidate": card.monthValidate,
            "yearValidate": card.yearValidate,
            "document": card.document,
            "flag": card.flag
        ]
        
        if card.id == "" {
            firestore.collection(collectionUsers).document(uid).collection(collectionCards).addDocument(data: docData)
        } else {
            firestore.collection(collectionUsers).document(uid).collection(collectionCards).document(card.id).updateData(docData)
        }
        
        completion()
    }
    
    func listRestaurants(completion: @escaping((Result, [Restaurant]?) -> Void)) {
        var restaurantList: [Restaurant] = []
        
        firestoreListener = firestore.collection(collectionRestaurants)
            .order(by: "name", descending: false)
            .addSnapshotListener(includeMetadataChanges: true){ (snapshot, error) in
                if snapshot?.count == 0 {
                    completion(.success, nil)
                    return
                }
                
                if let error = error {
                    completion(.error(error), nil)
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    restaurantList.removeAll()
                    
                    for document in snapshot.documents {
                        let data = document.data()
                        
                        if let address = data["address"] as? String,
                            let description = data["description"] as? String,
                            let geolocation = data["geolocation"] as? GeoPoint,
                            let name = data["name"] as? String,
                            let rating = data["rating"] as? Int,
                            let type = data["type"] as? String,
                            let urlImage = data["url_image"] as? String
                        {
                            let restaurant = Restaurant(id: document.documentID, name: name, urlImage: urlImage, type: type, description: description, rating: rating, address: address, latitude: geolocation.latitude, longitude: geolocation.longitude)
                            restaurantList.append(restaurant)
                        }
                    }
                    
                    completion(.success, restaurantList)
                    return
                }
        }
    }
    
    func listCards(completion: @escaping((Result, [Card]?) -> Void)) {
        let uid = authFirebase.currentUser?.uid ?? ""
        var cards: [Card] = []
        
        firestoreListener = firestore.collection(collectionUsers).document(uid).collection(collectionCards)
            .addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
                if snapshot?.count == 0 {
                    completion(.success, nil)
                    return
                }
                
                if let error = error {
                    completion(.error(error), nil)
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    cards.removeAll()
                    
                    for document in snapshot.documents {
                        let data = document.data()
                        let id = document.documentID
                        if let number = data["number"] as? String,
                            let name = data["name"] as? String,
                            let codeValidate = data["codeValidate"] as? Int,
                            let monthValidate = data["monthValidate"] as? Int,
                            let yearValidate = data["yearValidate"] as? Int,
                            let document = data["document"] as? String,
                            let flag = data["flag"] as? String
                        {
                            let card = Card(id: id, number: number, name: name, flag: flag, codeValidate: codeValidate, monthValidate: monthValidate, yearValidate: yearValidate, document: document)
                            cards.append(card)
                        }
                    }
                    
                    completion(.success, cards)
                    return
                }
        }
        
        
    }
    
    func deleteCard(id: String, completion: @escaping((Result) -> Void)) {
        let uid = authFirebase.currentUser?.uid ?? ""
        
        firestore.collection(collectionUsers).document(uid).collection(collectionCards).document(id).delete() { error in
            if let error = error {
                completion(.error(error))
            } else {
                completion(.success)
            }
        }
        
    }
    
    func getUser(completion: @escaping((Result, User?) -> Void)) {
        let uid = authFirebase.currentUser?.uid ?? ""
        let name = authFirebase.currentUser?.displayName ?? ""
        let email = authFirebase.currentUser?.email ?? ""
        let photoURL = authFirebase.currentUser?.photoURL?.absoluteString ?? ""
        
        firestore.collection(collectionUsers).document(uid).getDocument { (document, error) in
            if let error = error {
                completion(.error(error), nil)
                return
            }
            
            guard let data = document?.data() else {
                let user = User(name: name, email: email, phoneNumber: "", birthDate: Date(), password: "", photoURL: photoURL, cards: nil)
                completion(.success, user)
                return
            }
            
            if let phoneNumber = data["phoneNumber"] as? String,
                let birthDate = data["birthDate"] as? Timestamp {
                let user = User(name: name, email: email, phoneNumber: phoneNumber, birthDate: birthDate.dateValue(), password: "", photoURL: photoURL, cards: nil)
                completion(.success, user)
                return
            }
        }
    }
    
    private func savePhotoFireStorage(_ user: User, _ photoData: Data?, _ completion: @escaping(() -> Void)) {
        
        if let photoData = photoData {
            let imageName = authFirebase.currentUser?.uid.description ?? ""
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            var user = user
            storageRef.delete { (_) in
                storageRef.putData(photoData, metadata: nil, completion: { (_, error) in
                    if let _ = error { return }
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if let _ = error { return }
                        guard let url = url else { return }
                        user.photoURL = url.absoluteString
                        
                        self.performUserChange(user, {
                            completion()
                        })
                    })
                })
            }
        } else {
            self.performUserChange(user, {
                completion()
            })
        }
    }
    
    private func performUserChange(_ user: User, _ completion: @escaping(() -> Void)) {
        let changeResquest = authFirebase.currentUser?.createProfileChangeRequest()
        changeResquest?.displayName = user.name
        changeResquest?.photoURL = URL(string: user.photoURL)
        changeResquest?.commitChanges { (_) in
            self.performUserChangeOthersData(user, {
                completion()
            })
        }
    }
    
    private func performUserChangeOthersData(_ user: User, _ completion: @escaping(() -> Void)) {
        let uid = authFirebase.currentUser?.uid ?? ""
        
        let docData: [String: Any] = [
            "birthDate": user.birthDate,
            "phoneNumber": user.phoneNumber
        ]
        
        firestore.collection(collectionUsers).document(uid).setData(docData) { _ in
            completion()
        }
    }
}
