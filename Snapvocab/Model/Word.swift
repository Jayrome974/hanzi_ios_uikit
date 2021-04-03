//
//  Word.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-12.
//

import Foundation

struct Word: Decodable {
    let id: String
    let value: String
    let nbOccurrences: Int
}
