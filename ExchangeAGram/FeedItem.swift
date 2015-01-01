//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Krzysztof Kula on 01/01/15.
//  Copyright (c) 2015 Krzysztof Kula. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData

}
