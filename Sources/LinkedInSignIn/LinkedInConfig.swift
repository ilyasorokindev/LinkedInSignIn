//
//  LinkedInConfig.swift
//  LISignIn
//
//  Created by Serhii Londar on 11/16/17.
//  Copyright © 2017 Appcoda. All rights reserved.
//

import Foundation

public class LinkedInConfig {
    public let linkedInKey: String
    public let linkedInSecret: String
    public let redirectURL: String
    public let scope: String
    
    public init(linkedInKey: String, linkedInSecret: String, redirectURL: String, scope: String = "r_basicprofile") {
        self.linkedInKey = linkedInKey
        self.linkedInSecret = linkedInSecret
        self.redirectURL = redirectURL
        self.scope = scope
    }
}
