//
//  ViewController.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-08.
//

import UIKit

class ViewController: UIViewController {

    // TODO move to constants struct
    let cellIdentifier = "ReusableCell"
    
    @IBOutlet weak var wordsTableView: UITableView!
    
    var words: [Word] = [
        Word(value: "家", nbOccurrences: 5),
        Word(value: "累", nbOccurrences: 3)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        wordsTableView.dataSource = self
        navigationItem.title = "Library"
        
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

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var cellContentConfiguration = cell.defaultContentConfiguration();
        cellContentConfiguration.text = words[indexPath.row].value
        cell.contentConfiguration = cellContentConfiguration
        return cell
    }
}
