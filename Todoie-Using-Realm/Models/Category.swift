//
//  Category.swift
//  Todoie-Using-Realm
//
//  Created by Rakibul Hasan on 15/4/20.
//  Copyright © 2020 Rakibul Hasan. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var bgColor: String = ""
    let items = List<Item>()
}
