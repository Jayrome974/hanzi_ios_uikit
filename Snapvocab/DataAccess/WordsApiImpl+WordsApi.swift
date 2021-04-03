//
//  WordsApi.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-13.
//

import Foundation

protocol WordsApi {
    func add(_ wordValue:String, completionHandler: @escaping () -> Void)
    func deleteWord(with id:String, completionHandler: @escaping () -> Void)
    func fetchFrequentWords(completionHandler: @escaping ([Word]) -> Void)
}

struct InMemoryWordsApi: WordsApi {
    
    private static var words: [Word] = [
        Word(id: "134", value: "Welcome! This is a demo mode", nbOccurrences: 5),
        Word(id: "666", value: "Please log in to manage your library", nbOccurrences: 5),
        Word(id: "6ee", value: "thank you", nbOccurrences: 6),
        Word(id: "d12", value: "謝謝", nbOccurrences: 3),
        Word(id: "5ed", value: "gracias", nbOccurrences: 10),
        Word(id: "lop", value: "merci", nbOccurrences: 4),
        Word(id: "g12", value: "ありがとう", nbOccurrences: 3),
    ]
    
    func add(_ wordValue: String, completionHandler: @escaping () -> Void) {
        let wordValueIndex = getIndex(of: wordValue)
        
        if let safeWordValueIndex = wordValueIndex {
            incrementExistingWordNbOccurrences(safeWordValueIndex)
        } else {
            save(makeNewWord(with: wordValue))
        }
        completionHandler();
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
    
    func deleteWord(with id: String, completionHandler: @escaping () -> Void) {
        InMemoryWordsApi.words =
            InMemoryWordsApi.words.filter { (word) -> Bool in
                return word.id != id
            }
        completionHandler();
    }
    
    func fetchFrequentWords(completionHandler: @escaping ([Word]) -> Void) {
        completionHandler(InMemoryWordsApi.words)
    }
}

struct WordsApiClient: WordsApi {
    private static let getWordsEndpointUrl:URL = {
        var getWordsEndpointUrlComponents = URLComponents()
        
        getWordsEndpointUrlComponents.scheme = K.http.scheme.https
        getWordsEndpointUrlComponents.host = K.backendApi.host
        getWordsEndpointUrlComponents.path = K.backendApi.getWordsEndpoint
        
        return getWordsEndpointUrlComponents.url!
    }()
    
    private static let addWordEndpointUrl:URL = {
        var addWordEndpointUrlComponents = URLComponents()
        
        addWordEndpointUrlComponents.scheme = K.http.scheme.https
        addWordEndpointUrlComponents.host = K.backendApi.host
        addWordEndpointUrlComponents.path = K.backendApi.addWordEndpoint
        
        return addWordEndpointUrlComponents.url!
    }()
    
    private let oAuthService: OAuthService
    
    init(_ oAuthService:OAuthService) {
        self.oAuthService = oAuthService
    }
    
    func add(_ wordValue: String, completionHandler: @escaping () -> Void) {
        oAuthService.getAccessToken { (accessToken) in
            let addWordRequest = makeAddWordRequest(with: accessToken, with: wordValue)
            
            URLSession.shared.dataTask(with: addWordRequest) { (data, response, error) in
                if let safeError = error {
                    print(safeError.localizedDescription)
                    return
                }
                
                completionHandler()
            }.resume()
        }
    }
    
    fileprivate func makeAddWordRequest(with accessToken:String, with wordValue:String) -> URLRequest {
        var addWordRequest = URLRequest(url: WordsApiClient.addWordEndpointUrl)
        
        let addWordRequestBodyData = try? JSONSerialization.data(
            withJSONObject: ["word": wordValue],
            options: []
        )
        
        addWordRequest.httpMethod = K.backendApi.addWordEndpointHttpMethod
        addWordRequest.allHTTPHeaderFields = [
            K.http.header.contentType:K.http.header.contentTypeJson,
            K.http.header.authorization:K.http.header.authorizationBearerPrefix + accessToken
        ]
        addWordRequest.httpBody = addWordRequestBodyData
        
        return addWordRequest
    }
    
    func deleteWord(with id: String, completionHandler: @escaping () -> Void) {
        oAuthService.getAccessToken { (accessToken) in
            let deleteWordRequest = makeDeleteWordRequest(with: accessToken, with: id)
            
            URLSession.shared.dataTask(with: deleteWordRequest) { (data, response, error) in
                if let safeError = error {
                    print(safeError.localizedDescription)
                    return
                }
                
                completionHandler()
            }.resume()
        }
    }
    
    fileprivate func makeDeleteWordRequest(with accessToken:String, with wordId:String) -> URLRequest {
        var deleteWordRequest = URLRequest(url: makeDeleteWordEndpointUrl(for: wordId))
        
        deleteWordRequest.httpMethod = K.backendApi.deleteWordEndpointHttpMethod
        deleteWordRequest.allHTTPHeaderFields = [
            K.http.header.authorization:K.http.header.authorizationBearerPrefix + accessToken
        ]
        
        return deleteWordRequest
    }
    
    fileprivate func makeDeleteWordEndpointUrl(for wordId:String) -> URL {
        var deleteWordEndpointUrlComponents = URLComponents()
        
        deleteWordEndpointUrlComponents.scheme = K.http.scheme.https
        deleteWordEndpointUrlComponents.host = K.backendApi.host
        deleteWordEndpointUrlComponents.path = K.backendApi.deleteWordEndpointPrefix + wordId
        
        return deleteWordEndpointUrlComponents.url!
    }
    
    func fetchFrequentWords(completionHandler: @escaping ([Word]) -> Void) {
        oAuthService.getAccessToken { (accessToken) in
            let getWordsRequest = makeGetWordsRequest(with: accessToken)
            
            URLSession.shared.dataTask(with: getWordsRequest) { (data, response, error) in
                if let safeError = error {
                    print(safeError.localizedDescription)
                    return
                }
                
                if let safeData = data,
                   let frequentWords = self.parseGetWordsEndpointJSONResponse(safeData) {
                    completionHandler(frequentWords)
                    return
                }
            }.resume()
        }
    }
    
    fileprivate func makeGetWordsRequest(with accessToken:String) -> URLRequest {
        var getWordsRequest = URLRequest(url: WordsApiClient.getWordsEndpointUrl)
        
        getWordsRequest.httpMethod = K.backendApi.getWordsEndpointHttpMethod
        getWordsRequest.allHTTPHeaderFields = [K.http.header.authorization:K.http.header.authorizationBearerPrefix + accessToken]
        
        return getWordsRequest
    }
    
    fileprivate func parseGetWordsEndpointJSONResponse(_ getWordsEndpointResponseData: Data) -> [Word]? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Array<Word>.self, from: getWordsEndpointResponseData)
        } catch {
            print("error during JSON parsing getWordsEndpointResponseData \(error)")
            return nil
        }
    }
    
}
