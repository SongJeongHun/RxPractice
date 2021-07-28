//
//  Scene.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation
import UIKit
import RxSwift
enum Scene{
    case list(ListViewModel)
    case detail(URL)
}
extension Scene{
    //Scene별 ViewController 초기화 및 ViewModel 바인딩
    func instantiate(from storyboard:String = "Main") -> UIViewController{
        // Main.storyboard 초기화
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        switch self{
        // ListViewController 초기화 및 바인딩
        case .list(let listViewModel):
            guard let listNav = storyboard.instantiateViewController(identifier: "listNav") as? UINavigationController else { fatalError() }
            guard var listVC = listNav.children.first as? ListViewController else { fatalError() }
            listVC.bind(viewModel: listViewModel)
            return listNav
        // DetailViewController 초기화 및 바인딩
        case .detail(let url):
            guard let detailVC = storyboard.instantiateViewController(identifier: "detail") as? DetailViewController else { fatalError() }
            detailVC.webURL = url
            return detailVC
        }
    }
}
