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
    private let wordsApi: WordsApi
    var delegate: LibrayServiceDelegate?
    	
    init(_ wordsApi:WordsApi) {
        self.wordsApi = wordsApi
    }
    
    func loadFrequentWords() {
        wordsApi.fetchFrequentWords(completionHandler: self.onFrequentWordsFetched)
    }
    
    fileprivate func onFrequentWordsFetched(frequentWords: [Word]) {
        self.delegate?.didLoadFrequentWords(frequentWords)
    }
    
    func deleteWord(with wordId: String) {
        wordsApi.deleteWord(with: wordId, completionHandler: self.onWordAddedOrDeleted)
    }
    
    fileprivate func onWordAddedOrDeleted() {
        loadFrequentWords()
    }
    
    func addWord(with wordValue: String) {
        wordsApi.add(wordValue.trimmingCharacters(in: .whitespacesAndNewlines), completionHandler: self.onWordAddedOrDeleted)
    }
}
