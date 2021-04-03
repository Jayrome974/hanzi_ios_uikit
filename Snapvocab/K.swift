//
//  K.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-16.
//

import Foundation

struct K {
    static let tableViewCellIdentifier = "ReusableCell"
    static let existingWordNbOccurrencesIncrement = 1
    static let newWordNbOccurrences = 1
    static let safariApplicationName = "com.apple.SafariViewService"
    static let twoMinutesInSecondsAsDouble = 120.0
    
    struct plist {
        static let urlTypesKey = "CFBundleURLTypes"
        static let urlSchemesKey = "CFBundleURLSchemes"
    }
    
    struct http {
        struct header {
            static let contentType = "Content-Type"
            static let contentTypeFormUrlEncoded = "application/x-www-form-urlencoded"
            static let contentTypeJson = "application/json"
            static let authorization = "Authorization"
            static let authorizationBearerPrefix = "Bearer "
        }
        struct scheme {
            static let https = "https"
        }
    }
    
    struct oAuth {
        static let host = "auth.snapvocab.com"
        static let authorizeEndpoint = "/authorize"
        static let authorizeClientIdQueryName = "client_id"
        static let clientId = "4t6klr6pti5hjogcn89m1m95p"
        static let authorizeResponseTypeQueryName = "response_type"
        static let authorizeResponseType = "code"
        static let authorizeScopeQueryName = "scope"
        static let authorizeScope = "email+openid"
        static let authorizeRedirectUriQueryName = "redirect_uri"
        static let signInCallbackUrlHostName = "callbackSignedIn"
        static let authorizeAuthorizationCodeQueryName = "code"
        static let tokenEndpoint = "/token"
        static let tokenEndpointHttpMethod = "POST"
        static let tokenBodyGrantTypeKey = "grant_type"
        static let tokenBodyGrantTypeAuthorizationCode = "authorization_code"
        static let tokenBodyGrantTypeRefreshToken = "refresh_token"
        static let tokenBodyCodeKey = "code"
        static let tokenBodyRedirectUriKey = "redirect_uri"
        static let tokenBodyClientIdKey = "client_id"
        static let tokenBodyRefreshTokenKey = "refresh_token"
    }
    
    struct backendApi {
        static let host = "snapvocab.com"
        static let getWordsEndpoint = "/Prod/words"
        static let getWordsEndpointHttpMethod = "GET"
        static let addWordEndpoint = "/Prod/addingsword"
        static let addWordEndpointHttpMethod = "POST"
        static let deleteWordEndpointPrefix = "/Prod/words/"
        static let deleteWordEndpointHttpMethod = "DELETE"
    }
}
