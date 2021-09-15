//
//  KakaoSearchAPI.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/26.
//

import Foundation
import RxSwift
class KakaoSearchAPI{
    private let apiKey:String = "MYAPI"
    private let httpClient = HttpClient(baseURL: "https://dapi.kakao.com/v2/search")
    private let maxPage = 50
    private let maxSize = 80
    private var currentSize:Int{ return totalCount % maxSize + 20}
    private var currentPage:Int{ return totalCount / maxSize + 1 }
    private var totalCount = 20
    private var imageList:[Image] = []
    lazy private var images = BehaviorSubject<[Image]>(value: imageList)
    private let bag = DisposeBag()
    private let imageLoader = ImageLoader()
    func imageLoading(url:String) -> Observable<UIImage>{
        return imageLoader.loadImage(url: url)
    }
    func getList() -> Observable<[Image]>{
        return images
    }
    func getCount() -> Int{
        return imageList.count
    }
    func searching(queryItem:String,_ next:Bool = false,_ previous:Bool = false){
        imageList = []
        if next {
            if totalCount + 20 < maxPage * maxSize{
                totalCount += 20
            }
        }
        if previous {
            if totalCount > 20{
                totalCount -= 20
            }
        }
        httpClient.getJson(path: "/image", params: [
            "query":queryItem,
            "page":currentPage,
            "size":currentSize
        ],apikey:apiKey)
        .subscribe(onNext:{[unowned self] data in
            let dict = data as! [String:Any]
            let docs = dict["documents"] as? Array<Any> ?? []
            for i in docs{
                let result = i as! [String:Any]
                let sourceURL = result["doc_url"] as! String
                let thumbnailURL = result["thumbnail_url"] as! String
                imageList.append(Image(sourceURL: sourceURL, imageURL: thumbnailURL))
            }
            self.images.onNext(imageList)
        },onError:{[unowned self]err in
            self.images.onError(err)
        })
        .disposed(by: bag)
    }
    func validCheck() -> Bool{
        if currentSize <= maxSize && currentPage <= maxPage{ return true }
        return false
    }
}
