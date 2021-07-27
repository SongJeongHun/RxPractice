//
//  ImageLoader.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/25.
//
import UIKit
import RxSwift

class ImageLoader{
    static func loadImage(url: String) -> Observable<UIImage> {
        return Observable<UIImage>.create{ observer in
            let url = URL(string: url)
            let data = try! Data(contentsOf: url!)
            observer.onNext(UIImage(data:data)!)
            return Disposables.create()
        }
    }
}
