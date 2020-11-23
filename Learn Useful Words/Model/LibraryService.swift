//
//  LibraryService.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-13.
//

import Foundation

protocol LibrayServiceDelegate {
    func didLoadFrequentWords(_ frequentWords: [Word])
}

struct LibraryService {
    let wordsApi: InMemoryWordsApi
    var delegate: LibrayServiceDelegate?
    
    init() {
        wordsApi = InMemoryWordsApi()
    }
    
    func loadFrequentWords() {
        wordsApi.fetchFrequentWords(callback: self.onFrequentWordsFetched)
    }
    
    func onFrequentWordsFetched(frequentWords: [Word]) {
        self.delegate?.didLoadFrequentWords(frequentWords)
    }
    
    func deleteWord(with wordId: String) {
        wordsApi.deleteWord(with: wordId, callback: self.onWordAddedOrDeleted)
    }
    
    func onWordAddedOrDeleted() {
        loadFrequentWords()
    }
    
    func addWord(with wordValue: String) {
        wordsApi.add(wordValue.trimmingCharacters(in: .whitespacesAndNewlines), callback: self.onWordAddedOrDeleted)
    }
}
