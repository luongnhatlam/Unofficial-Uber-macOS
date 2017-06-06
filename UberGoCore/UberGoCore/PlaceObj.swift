//
//  PlaceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import ObjectMapper

open class PlaceObj: BaseObj {

    // MARK: - Variable
    public var name: String?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.name <- map["name"]
    }
}
