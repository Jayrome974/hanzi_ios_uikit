//
//  OAuthService.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-26.
//

import Foundation

class OAuthService {
    
    static let appUrlScheme:String? = {
        if let schemas = Bundle.main.object(forInfoDictionaryKey: K.plist.urlTypesKey) as? [[String:Any]],
           let schema = schemas.first,
           let urlSchemes = schema[K.plist.urlSchemesKey] as? [String] {
            return urlSchemes.first
        }
        return nil
    }()
    
    static let redirectUriToCurrentApplication:URL = {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = appUrlScheme
        urlComponents.host = K.oAuth.signInCallbackUrlHostName
        
        return urlComponents.url!
    }()
    
    static let authorizeEndpointUrl:URL = {
        var authorizeEndpointUrlComponents = URLComponents()
        
        authorizeEndpointUrlComponents.scheme = K.http.scheme.https
        authorizeEndpointUrlComponents.host = K.oAuth.host
        authorizeEndpointUrlComponents.path = K.oAuth.authorizeEndpoint
        authorizeEndpointUrlComponents.queryItems = [
            URLQueryItem(name: K.oAuth.authorizeClientIdQueryName, value: K.oAuth.clientId),
            URLQueryItem(name: K.oAuth.authorizeResponseTypeQueryName, value: K.oAuth.authorizeResponseType),
            URLQueryItem(name: K.oAuth.authorizeScopeQueryName, value: K.oAuth.authorizeScope),
            URLQueryItem(name: K.oAuth.authorizeRedirectUriQueryName, value: redirectUriToCurrentApplication.absoluteString)
        ]
        
        return authorizeEndpointUrlComponents.url!
    }()
    
    static let tokenEndpointUrl:URL = {
        var tokenEndpointUrlComponents = URLComponents()
        
        tokenEndpointUrlComponents.scheme = K.http.scheme.https
        tokenEndpointUrlComponents.host = K.oAuth.host
        tokenEndpointUrlComponents.path = K.oAuth.tokenEndpoint
        
        return tokenEndpointUrlComponents.url!
    }()
    
    private var oAuthGetTokenState:OAuthGetTokenState
    
    init(_ oAuthGetTokenState:OAuthGetTokenState) {
        self.oAuthGetTokenState = oAuthGetTokenState
        transitionTo(oAuthGetTokenState: oAuthGetTokenState)
    }
    
    func transitionTo(oAuthGetTokenState: OAuthGetTokenState) {
        self.oAuthGetTokenState = oAuthGetTokenState
        self.oAuthGetTokenState.update(context: self)
    }
    
    func getAccessToken(completionHandler: @escaping (String) -> Void) {
        oAuthGetTokenState.getAccessToken(completionHandler: completionHandler)
    }
}
