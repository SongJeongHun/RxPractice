//
//  ListViewModel.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation
import RxSwift
import Action

class ListViewModel:ViewModelType{
    private var repository:KakaoSearchAPI = KakaoSearchAPI()
    var getList:Observable<[Image]>{
        return repository.getList()
    }
    lazy var detailAction: Action<Image,Void> = {
        return Action { image in
            let url = URL(string: image.sourceURL)!
            let detailScene = Scene.detail(url)
            return self.coordinator.transition(to: detailScene, using: .push, animated: true).asObservable().map{ _ in }
        }
    }()
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
        repository.searching(queryItem: queryItem,true)
    }
    func previous(queryItem:String){
        repository.searching(queryItem: queryItem,false,true)
    }
}
