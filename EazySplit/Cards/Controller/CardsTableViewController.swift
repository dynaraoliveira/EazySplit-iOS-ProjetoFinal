//
//  CardsTableViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 02/05/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit

class CardsTableViewController: UITableViewController {
    
    private var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavigationBar()
        loadCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func loadCards() {
        Loader.shared.showOverlay(view: self.view)
        
        FirebaseService.shared.listCards{ (result, cards) in
            Loader.shared.hideOverlayView()
            switch result {
            case .success:
                if let cards = cards {
                    self.cards = cards
                    self.tableView.reloadData()
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = cards[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell") as? CardTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setupCard(card)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FirebaseService.shared.deleteCard(id: cards[indexPath.row].id) { (result) in
                switch result {
                case .error(let error):
                    print(error.localizedDescription)
                default:
                    break
                }
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addEditCards(cards[indexPath.row])
    }
    
}

extension CardsTableViewController {
    private func loadNavigationBar() {
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAddCard))]
    }
    
    private func addEditCards(_ card: Card? = nil) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard
            .instantiateViewController(withIdentifier: "AddEditCardsViewController") as? AddEditCardsViewController else { return }
        
        vc.card = card
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func actionAddCard() {
        addEditCards()
    }
}
