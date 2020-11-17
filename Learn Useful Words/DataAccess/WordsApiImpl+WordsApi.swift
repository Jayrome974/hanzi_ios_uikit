//
//  WordsApi.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-13.
//

import Foundation

protocol WordsApi {
    func add(_ wordValue:String, callback: () -> Void)
    func deleteWord(with id:String, callback: () -> Void)
    func fetchFrequentWords(callback: ([Word]) -> Void)
}

struct InMemoryWordsApi: WordsApi {
    
    static var words: [Word] = [
        Word(id: "134", value: "家庭", nbOccurrences: 5),
        Word(id: "343", value: "累計", nbOccurrences: 3),
        Word(id: "666", value: "厲害", nbOccurrences: 3)
    ]
    
    func add(_ wordValue: String, callback: () -> Void) {
        let wordValueIndex = getIndex(of: wordValue)
        
        if let existingWordValueIndex = wordValueIndex {
            incrementExistingWordNbOccurrences(existingWordValueIndex)
        } else {
            save(makeNewWord(with: wordValue))
        }
        callback();
    }
    
    fileprivate func getIndex(of wordValue: String) -> Int? {
        return InMemoryWordsApi.words.firstIndex { (word) -> Bool in
            return wordValue == word.value
        }
    }
    
    fileprivate func incrementExistingWordNbOccurrences(_ existingWordValueIndex: Int) {
        let existingWord = InMemoryWordsApi.words[existingWordValueIndex]
        InMemoryWordsApi.words[existingWordValueIndex] =
            Word(id: existingWord.value,
                 value: existingWord.value,
                 nbOccurrences: existingWord.nbOccurrences + K.existingWordNbOccurrencesIncrement)
    }
    
    fileprivate func makeNewWord(with wordValue: String) -> Word {
        return Word(id: UUID().uuidString, value: wordValue, nbOccurrences: K.newWordNbOccurrences)
    }
    
    fileprivate func save(_ newWord: Word) {
        InMemoryWordsApi.words.append(newWord)
    }
    
    func deleteWord(with id: String, callback: () -> Void) {
        InMemoryWordsApi.words =
            InMemoryWordsApi.words.filter { (word) -> Bool in
                return word.id != id
            }
        callback();
    }
    
    func fetchFrequentWords(callback: ([Word]) -> Void) {
        callback(InMemoryWordsApi.words)
    }
}

struct WordsApiClient: WordsApi {
    
    func add(_ wordValue: String, callback: () -> Void) {
        // TODO
    }
    
    func deleteWord(with id: String, callback: () -> Void) {
        // TODO
    }
    
    func fetchFrequentWords(callback: ([Word]) -> Void) {
        // TODO
    }
}
