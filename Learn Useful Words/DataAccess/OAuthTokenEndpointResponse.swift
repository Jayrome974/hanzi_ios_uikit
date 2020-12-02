//
//  OAuthTokenEndpointResponse.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-30.
//

import Foundation

struct OAuthTokenEndpointResponse: Codable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Int
}
