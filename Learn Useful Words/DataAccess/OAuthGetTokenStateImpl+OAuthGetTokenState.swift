//
//  OAuthAuthorizationCodeState.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-30.
//

import Foundation

protocol OAuthGetTokenState {
    func update(context: OAuthService)
    func getAccessToken(completionHandler: @escaping (String) -> Void)
}

class OAuthBaseState: OAuthGetTokenState {
    private(set) weak var context:OAuthService?
    
    func update(context: OAuthService) {
        self.context = context
    }
    
    func getAccessToken(completionHandler: @escaping (String) -> Void) {}
    
    internal func makeGetTokenRequest(with body:URLComponents) -> URLRequest {
        var getTokenRequest = URLRequest(url: OAuthService.tokenEndpointUrl)
        getTokenRequest.httpMethod = K.oAuth.tokenEndpointHttpMethod
        getTokenRequest.allHTTPHeaderFields = [K.http.header.contentType:K.http.header.contentTypeFormUrlEncoded]
        getTokenRequest.httpBody = body.query?.data(using: .utf8)
        return getTokenRequest
    }
    
    internal func parseJSON(_ oAuthTokenEndpointResponseData: Data) -> OAuthTokenEndpointResponse? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(OAuthTokenEndpointResponse.self, from: oAuthTokenEndpointResponseData)
        } catch {
            print("error during JSON parsing oAuthTokenEndpointResponseData \(error)")
            return nil
        }
    }
}

class OAuthAuthorizationCodeState: OAuthBaseState {
    private let authorizationCode:String
    
    init(_ authorizationCode:String) {
        self.authorizationCode = authorizationCode
    }
    
    override func getAccessToken(completionHandler: @escaping (String) -> Void) {
        let getTokenRequest = makeGetTokenRequest()
        
        URLSession.shared.dataTask(with: getTokenRequest) { (data, response, error) in
            if let safeError = error {
                print(safeError.localizedDescription)
                return
            }
            
            if let safeData = data,
               let oAuthTokenEndpointResponse = self.parseJSON(safeData),
               let oAuthTokenEndpointResponseRefreshToken = oAuthTokenEndpointResponse.refresh_token{
                let oAuthRefreshTokenState = OAuthRefreshTokenState(
                    oAuthTokenEndpointResponse.access_token,
                    oAuthTokenEndpointResponseRefreshToken,
                    oAuthTokenEndpointResponse.expires_in)
                self.context?.transitionTo(oAuthGetTokenState: oAuthRefreshTokenState)
                completionHandler(oAuthTokenEndpointResponse.access_token)
            }
        }.resume()
    }
    
    fileprivate func makeGetTokenRequest() -> URLRequest {
        var getTokenRequestBodyComponents = URLComponents()
        getTokenRequestBodyComponents.queryItems = [
            URLQueryItem(name: K.oAuth.tokenBodyGrantTypeKey, value: K.oAuth.tokenBodyGrantTypeAuthorizationCode),
            URLQueryItem(name: K.oAuth.tokenBodyCodeKey, value: authorizationCode),
            URLQueryItem(name: K.oAuth.tokenBodyRedirectUriKey, value: OAuthService.redirectUriToCurrentApplication.absoluteString),
            URLQueryItem(name: K.oAuth.tokenBodyClientIdKey, value: K.oAuth.clientId)
        ]
        
        return makeGetTokenRequest(with: getTokenRequestBodyComponents)
    }
}

class OAuthRefreshTokenState: OAuthBaseState {
    private var accessToken:String!
    private let refreshToken:String
    private var accessTokenExpirationDate:Date!
    
    init(_ accessToken:String, _ refreshToken:String, _ accessTokenValidityInSeconds:Int) {
        self.refreshToken = refreshToken
        super.init()
        initAccessToken(from: accessToken, from: accessTokenValidityInSeconds)
    }
        
    fileprivate func initAccessToken(from accessToken:String, from accessTokenValidityInSeconds:Int) {
        self.accessToken = accessToken
        self.accessTokenExpirationDate = computeAccessTokenExpirationDate(from: accessTokenValidityInSeconds)
    }
    
    fileprivate func computeAccessTokenExpirationDate(from accessTokenValidityInSeconds:Int) -> Date {
        let accessTokenValidityAsTimeInterval:TimeInterval = Double(accessTokenValidityInSeconds)
        let twoMinutesAsTimeInterval:TimeInterval = K.twoMinutesInSecondsAsDouble
        return Date() + accessTokenValidityAsTimeInterval - twoMinutesAsTimeInterval
    }
    
    override func getAccessToken(completionHandler: @escaping (String) -> Void) {
        if isAccessTokenValid() {
            completionHandler(accessToken)
            return
        }
        
        let getTokenRequest = makeGetTokenRequest()
        
        URLSession.shared.dataTask(with: getTokenRequest) { (data, response, error) in
            if let safeError = error {
                print(safeError.localizedDescription)
                return
            }
            
            if let safeData = data,
               let oAuthTokenEndpointResponse = self.parseJSON(safeData) {
                self.initAccessToken(from: oAuthTokenEndpointResponse.access_token, from: oAuthTokenEndpointResponse.expires_in)
                completionHandler(self.accessToken)
            }
        }.resume()
    }
    
    fileprivate func isAccessTokenValid() -> Bool {
        return Date() <= accessTokenExpirationDate
    }
    
    fileprivate func makeGetTokenRequest() -> URLRequest {
        var getTokenRequestBodyComponents = URLComponents()
        getTokenRequestBodyComponents.queryItems = [
            URLQueryItem(name: K.oAuth.tokenBodyGrantTypeKey, value: K.oAuth.tokenBodyGrantTypeRefreshToken),
            URLQueryItem(name: K.oAuth.tokenBodyRefreshTokenKey, value: refreshToken),
            URLQueryItem(name: K.oAuth.tokenBodyRedirectUriKey, value: OAuthService.redirectUriToCurrentApplication.absoluteString),
            URLQueryItem(name: K.oAuth.tokenBodyClientIdKey, value: K.oAuth.clientId)
        ]
        
        return makeGetTokenRequest(with: getTokenRequestBodyComponents)
    }
}
