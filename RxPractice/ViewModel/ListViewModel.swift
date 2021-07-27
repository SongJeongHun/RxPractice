//
//  ListViewModel.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation
import RxSwift
class ListViewModel:ViewModelType{
    private var repository:KakaoSearchAPI = KakaoSearchAPI()
    func getList(queryItem:String) -> Observable<[Image]>{
        return repository.getList(queryItem: queryItem)
    }
    func imageLoading(url:String) -> Observable<UIImage>{
        return repository.imageLoading(url: url)
    }
}
