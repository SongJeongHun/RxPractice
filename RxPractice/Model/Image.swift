//
//  Image.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/27.
//

import Foundation
struct Image :Codable{
    let sourceURL:String
    let imageURL:String
    init(sourceURL:String,imageURL:String) {
        self.sourceURL = sourceURL
        self.imageURL = imageURL
    }
    enum CodingKeys: String, CodingKey {
        case sourceURL = "doc_url"
        case imageURL = "image_url"
    }
}
