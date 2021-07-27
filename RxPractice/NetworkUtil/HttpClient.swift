//
//  HttpClient.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/25.
//
import Foundation
import RxSwift
import Alamofire

class HttpClient{
    private let baseURL:String
    init(baseURL:String) { self.baseURL = baseURL }
    func getJson(path:String,params:[String:Any],apikey:String) -> Observable<Any>{
        let subject = PublishSubject<Any>()
        AF.request(self.baseURL + path,method:.get ,parameters:params ,headers: HTTPHeaders(["Authorization":"KakaoAK \(apikey)"]))
            .responseJSON{ response in
                let result = response.result
                switch result{
                case .success(let data):
                    subject.onNext(data)
                case .failure(let error):
                    subject.onError(error)
                }
            }
        return subject
    }
}
