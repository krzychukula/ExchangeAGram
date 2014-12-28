//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Krzysztof Kula on 28/12/14.
//  Copyright (c) 2014 Krzysztof Kula. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
