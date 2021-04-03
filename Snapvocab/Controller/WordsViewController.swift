//
//  ViewController.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-08.
//

import UIKit
import SafariServices

class WordsViewController: UIViewController {
    
    @IBOutlet weak var wordsTableView: UITableView!
    @IBOutlet weak var addWordTextField: UITextField!
    
    private var libraryService: LibraryService?
    
    private var words: [Word] = []
    
    func setLibraryService(_ libraryService:LibraryService) {
        self.libraryService = libraryService
        self.libraryService!.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordsTableView.dataSource = self
        addWordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        libraryService?.loadFrequentWords()
    }
    
    @IBAction func logInPressed(_ sender: UIBarButtonItem) {
        let safariViewController = SFSafariViewController(url: OAuthService.authorizeEndpointUrl)
        self.present(safariViewController, animated: true, completion: nil)
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
            libraryService?.deleteWord(with: words[indexPath.row].id)
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
            libraryService?.addWord(with: textField.text!)
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
        DispatchQueue.main.async {
            self.wordsTableView.reloadData()
        }
    }
}
