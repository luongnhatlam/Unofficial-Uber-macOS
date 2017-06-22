//
//  UserObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import OAuthSwift
import ObjectMapper
import RxSwift

open class UserObj: BaseObj {

    // MARK: - Current User
    fileprivate struct Static {
        static var instance: UserObj? {
            didSet {
                //FIXME : Smell code => Find new way to call binding()
                // It didn't call in init()
                // Due by we get currentUser from Disk persistance
                // 
                // Might be cause serious bug if call binding twice
                instance?.binding()
            }
        }
    }

    // MARK: - Variable
    public var name: String?
    public var oauthToken: String?
    public var oauthRefreshToken: String?
    public var oauthTokenSecret: String?
    public var oauthTokenExpiresAt: Date?
    public var authenticateState: AuthenticationState {
        guard let oauthToken = self.oauthToken else {
            return .unAuthenticated
        }
        guard oauthToken != "" else {
            return .unAuthenticated
        }
        return .authenticated
    }

    fileprivate var _currentUserInstance: UserObj?
    fileprivate static let lock = NSLock()

    // MARK: - Observer
    public let reloadUberDataPublisher = PublishSubject<Void>()
    public let paymentMethodObjVar = Variable<PaymentObj?>(nil)
    public var selectedNewPaymentObjVar = Variable<PaymentAccountObj?>(nil)
    public var currentPaymentAccountObjVar = Variable<PaymentAccountObj?>(nil)

    // MARK: - Init
    override init() {
        super.init()
    }

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.name <- map[Constants.Object.User.Name]
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.name = aDecoder.decodeObject(forKey: Constants.Object.User.Name) as? String
        self.oauthToken = aDecoder.decodeObject(forKey: Constants.Object.User.OauthToken) as? String
        self.oauthRefreshToken = aDecoder.decodeObject(forKey: Constants.Object.User.OauthTokenSecret) as? String
        self.oauthTokenSecret = aDecoder.decodeObject(forKey: Constants.Object.User.OauthTokenSecret) as? String
        self.oauthTokenExpiresAt = aDecoder.decodeObject(forKey: Constants.Object.User.OauthTokenExpiresAt) as? Date
    }

    public required init?(map: Map) {
        super.init(map: map)
    }

    override public func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.name, forKey: Constants.Object.User.Name)
        aCoder.encode(self.oauthToken, forKey: Constants.Object.User.OauthToken)
        aCoder.encode(self.oauthRefreshToken, forKey: Constants.Object.User.OauthRefreshToken)
        aCoder.encode(self.oauthTokenSecret, forKey: Constants.Object.User.OauthTokenSecret)
        aCoder.encode(self.oauthTokenExpiresAt, forKey: Constants.Object.User.OauthTokenExpiresAt)
    }

    // MARK: - Binding
    public func binding() {

        // Payment
        self.reloadUberDataPublisher
            .asObserver()
            .flatMapLatest { _ -> Observable<PaymentObj> in
                return UberService().paymentMethodObserver()
            }
            .do(onNext: { (paymentObj) in
                Logger.info("Curent PaymentMethods count = \(paymentObj.paymentAccountObjs?.count ?? 0 )")
            })
            .bind(to: self.paymentMethodObjVar)
            .addDisposableTo(self.disposeBag)

        // Last User or select
        let lastUsed = self.paymentMethodObjVar.asObservable()
            .filterNil()
            .flatMapLatest({ (paymentObj) -> Observable<PaymentAccountObj> in
                guard let lastUser = paymentObj.lastUsedPaymentAccount else {
                    return Observable.empty()
                }
                return Observable.just(lastUser)
            })

        let newSelectAccount = self.selectedNewPaymentObjVar
            .asObservable()
            .filterNil()

        // Combine
        Observable.merge([lastUsed, newSelectAccount])
        .bind(to: self.currentPaymentAccountObjVar)
        .addDisposableTo(self.disposeBag)
    }

    //TODO: Don't use UserDefault
    // Should try CoreData or Realm instead
    public func historyPlace() -> [PlaceObj] {
        let userDefault = UserDefaults.standard
        guard let data = userDefault.data(forKey: "history") else {
            return []
        }

        guard let histories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PlaceObj] else {
            return []
        }

        return histories
    }

    public func saveHistoryPlace(_ place: PlaceObj) {
        var histories = self.historyPlace()

        if histories.contains(place) == false {
            histories.insert(place, at: 0)
        }

        // Save
        let data = NSKeyedArchiver.archivedData(withRootObject: histories)
        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: "history")
        userDefault.synchronize()
    }
}

// MARK: - Authentication
extension UserObj {

    public static var currentUser: UserObj? {

        // Lock
        self.lock.lock()
        defer {
            self.lock.unlock()
        }

        // Critical resource
        if Static.instance != nil {
            return Static.instance
        }

        // Try to get from Disk
        if let userObj = self.getFromDisk() {
            Static.instance = userObj
        }

        return Static.instance
    }

    public class func convertCurrentUser(with credential: OAuthSwiftCredential) -> UserObj {

        // Lock
        self.lock.lock()
        defer {
            self.lock.unlock()
        }

        // Create User
        let user = self.makeNewUser(from: credential)

        //TODO: Save to keychain instead of disk
        // Save persistence
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: "currentUser")
        UserDefaults.standard.synchronize()

        // Set current User
        Static.instance = user

        return user
    }

    fileprivate class func makeNewUser(from credential: OAuthSwiftCredential) -> UserObj {
        let user = UserObj()
        user.oauthToken = credential.oauthToken
        user.oauthRefreshToken = credential.oauthRefreshToken
        user.oauthTokenExpiresAt = credential.oauthTokenExpiresAt
        user.oauthTokenSecret = credential.oauthTokenSecret
        return user
    }
}

// MARK: - Private
extension UserObj {

    fileprivate class func getFromDisk() -> UserObj? {

        guard let data = UserDefaults.standard.data(forKey: "currentUser") else { return nil }
        guard let userObj = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserObj else { return nil }

        return userObj
    }
}
