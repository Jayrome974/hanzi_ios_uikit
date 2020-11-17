//
//  ViewController.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-08.
//

import UIKit

class WordsViewController: UIViewController {
    
    @IBOutlet weak var wordsTableView: UITableView!
    @IBOutlet weak var addWordTextField: UITextField!
    
    var libraryService = LibraryService()
    
    var words: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordsTableView.dataSource = self
        addWordTextField.delegate = self
        libraryService.delegate = self
        
        navigationItem.title = K.navigationItemTitle
        libraryService.loadFrequentWords();
        
        //        navigationController?.navigationBar.prefersLargeTitles = true
        //        let appearance = UINavigationBarAppearance()
        //        appearance.backgroundColor = .black
        ////        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        //        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        ////        navigationController?.navigationBar.tintColor = .white
        //        navigationController?.navigationBar.standardAppearance = appearance
        //        navigationController?.navigationBar.compactAppearance = appearance
        //        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

extension WordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.tableViewCellIdentifier, for: indexPath)
        var cellContentConfiguration = cell.defaultContentConfiguration();
        cellContentConfiguration.text = "\(words[indexPath.row].value) \(words[indexPath.row].nbOccurrences)"
        cell.contentConfiguration = cellContentConfiguration
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            libraryService.deleteWord(with: words[indexPath.row].id)
        }
    }
}

extension WordsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let wordValue = textField.text {
            libraryService.addWord(with: wordValue)
        }
        
        textField.text = ""
    }
}

extension WordsViewController: LibrayServiceDelegate {
    func didLoadFrequentWords(_ frequentWords: [Word]) {
        words = frequentWords
        wordsTableView.reloadData()
    }
}
