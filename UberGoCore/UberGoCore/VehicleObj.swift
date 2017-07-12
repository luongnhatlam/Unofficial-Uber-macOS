//
//  VehicleObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class VehicleObj: BaseObj {

    // MARK: - Variable
    public var make: String?
    public var model: String?
    public var licensePlate: String?
    public var pictureUrl: String?

    public var fullName: String {
        if self.model == nil && self.make == nil {
            return "Unknown"
        }
        return (self.make ?? "") + (self.model ?? "")
    }

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.make = try unboxer.unbox(key: Constants.Object.Vehicle.Make)
        self.model = try unboxer.unbox(key: Constants.Object.Vehicle.Model)
        self.licensePlate = try unboxer.unbox(key: Constants.Object.Vehicle.LicensePlate)
        self.pictureUrl = try unboxer.unbox(key: Constants.Object.Vehicle.PictureUrl)
    }
}
