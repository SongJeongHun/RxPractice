//
//  ListViewModel.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation
import RxSwift
class ListViewModel:ViewModelType{
    var repository:KakaoSearchAPI = KakaoSearchAPI()
    func getList(queryItem:String) -> Observable<[Image]>{
        return repository.getList(queryItem: queryItem)
    }
}
