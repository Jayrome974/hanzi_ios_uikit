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
        
        libraryService.loadFrequentWords()
    }
}

extension WordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.tableViewCellIdentifier, for: indexPath)
        
        var cellContentConfiguration = cell.defaultContentConfiguration();
        cellContentConfiguration.textProperties.color = .white
        cellContentConfiguration.text = (words[indexPath.row].value)
        cellContentConfiguration.secondaryTextProperties.color = .white
        cellContentConfiguration.secondaryText = "\(words[indexPath.row].nbOccurrences) times"
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
        if !isTextFieldValueEmpty(textField) {
            libraryService.addWord(with: textField.text!)
            textField.text = ""
        }
    }
    
    fileprivate func isTextFieldValueEmpty(_ textField: UITextField) -> Bool {
        if let wordValue = textField.text, !wordValue.isEmpty {
            return false
        }
        
        return true;
    }
}

extension WordsViewController: LibrayServiceDelegate {
    func didLoadFrequentWords(_ frequentWords: [Word]) {
        words = frequentWords
        wordsTableView.reloadData()
    }
}
