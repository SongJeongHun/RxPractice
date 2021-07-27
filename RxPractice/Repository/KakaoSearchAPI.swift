//
//  KakaoSearchAPI.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/26.
//

import Foundation
import RxSwift
class KakaoSearchAPI{
    private let apiKey:String = "6f810a6d493ff8aad7b7184b6c7bc136"
    private let httpClient = HttpClient(baseURL: "https://dapi.kakao.com/v2/search")
    private let maxPage = 50
    private let maxSize = 80
    private var currentPage = 1
    private var currentSize = 20
    private var imageList:[Image] = []
    private let bag = DisposeBag()
    private let imageLoader = ImageLoader()
    func imageLoading(url:String) -> Observable<UIImage>{
        return imageLoader.loadImage(url: url)
    }
    func getList(queryItem:String) -> Observable<[Image]>{
        let subject = PublishSubject<[Image]>()
        httpClient.getJson(path: "/image", params: [
            "query":queryItem,
            "page":currentPage,
            "size":currentSize
        ],apikey:apiKey)
            .subscribe(onNext:{[unowned self] data in
                let dict = data as! [String:Any]
                let docs = dict["documents"] as! Array<Any>
                for i in docs{
                    let result = i as! [String:Any]
                    let sourceURL = result["doc_url"] as! String
                    let thumbnailURL = result["thumbnail_url"] as! String
                    imageList.append(Image(sourceURL: sourceURL, imageURL: thumbnailURL))
                }
                subject.onNext(imageList)
            },onError:{err in
                subject.onError(err)
            })
        .disposed(by: bag)
        return subject
    }
    func nextList(){
        
    }
    func validCheck() -> Bool{
        if currentSize <= maxSize && currentPage <= maxPage{ return true }
        return false
    }
}
