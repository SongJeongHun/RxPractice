//
//  ListViewModel.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation
import RxSwift
class ListViewModel:ViewModelType{
    var getList:Observable<[Image]>{
        return repository.getList()
    }
    private var repository:KakaoSearchAPI = KakaoSearchAPI()
    func searching(queryItem:String){
        repository.searching(queryItem: queryItem)
    }
    func imageLoading(url:String) -> Observable<UIImage>{
        return repository.imageLoading(url: url)
    }
}
