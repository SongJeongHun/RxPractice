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
    var getList:Observable<[Image]>{
        return repository.getList()
    }
    func searching(queryItem:String){
        repository.searching(queryItem: queryItem)
    }
    func imageLoading(url:String) -> Observable<UIImage>{
        return repository.imageLoading(url: url)
    }
    func listCount() -> Int{
        return repository.getCount()
    }
    func next(queryItem:String){
        repository.searching(queryItem: queryItem, true)
    }
}
