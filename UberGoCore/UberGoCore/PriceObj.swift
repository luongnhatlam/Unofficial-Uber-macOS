//
//  PriceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class PriceObj: BaseObj {

    // MARK: - Variable
    public var localizedDisplayName: String?
    public var distance: Float?
    public var displayName: String?
    public var productId: String?
    public var highEstimate: Float?
    public var lowEstimate: Float?
    public var duration: Float?
    public var estimate: String?
    public var currencyCode: String?
    public var surgeMultiplier: Double?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.localizedDisplayName = try unboxer.unbox(key: Constants.Object.Price.LocalizedDisplayName)
        self.distance = try unboxer.unbox(key: Constants.Object.Price.Distance)
        self.displayName = try unboxer.unbox(key: Constants.Object.Price.DisplayName)
        self.productId = try unboxer.unbox(key: Constants.Object.Price.ProductId)
        self.highEstimate = try unboxer.unbox(key: Constants.Object.Price.HighEstimate)
        self.lowEstimate = try unboxer.unbox(key: Constants.Object.Price.LowEstimate)
        self.duration = try unboxer.unbox(key: Constants.Object.Price.Duration)
        self.estimate = try unboxer.unbox(key: Constants.Object.Price.Estimate)
        self.currencyCode = try unboxer.unbox(key: Constants.Object.Price.CurrencyCode)
        self.surgeMultiplier = try unboxer.unbox(key: Constants.Object.Price.SurgeMultiplier)
    }
}
