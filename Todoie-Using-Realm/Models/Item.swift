//
//  Item.swift
//  Todoie-Using-Realm
//
//  Created by Rakibul Hasan on 15/4/20.
//  Copyright © 2020 Rakibul Hasan. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var bgColor: String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
