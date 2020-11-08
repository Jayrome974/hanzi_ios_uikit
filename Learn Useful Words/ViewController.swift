//
//  ViewController.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-08.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var wordsTableView: UITableView!
    
    var words: [Word] = [
        Word(value: "家", nbOccurrences: 5),
        Word(value: "累", nbOccurrences: 3)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

