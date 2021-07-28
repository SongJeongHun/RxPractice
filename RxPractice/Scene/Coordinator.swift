//
//  Coordinator.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa
extension UIViewController{
    var sceneViewController:UIViewController{ return self.children.first ?? self }
}
class Coordinator:SceneCoordinatorType{
    private let bag = DisposeBag()
    private let window:UIWindow
    var currentVC:UIViewController
    // 화면 전환을 위한 window 초기화 및 현재 ViewController 초기화
    init(window:UIWindow){
        self.window = window
        self.currentVC = window.rootViewController!
    }
    // 화면 전환 로직 정의
    func transition(to scene: Scene, using transition: Transition, animated: Bool) -> Completable {
        let target = scene.instantiate()
        let subject = PublishSubject<Void>()
        switch transition {
        // 모달 처리
        case .modal:
            currentVC.present(target, animated: animated){ subject.onCompleted() }
            currentVC = target.sceneViewController
        // 푸쉬 처리
        case .push:
            // 현재 VC의 NavigationController 존재 여부 확인
            guard let nav = currentVC as? UINavigationController else {
                subject.onError(TransitionError.naviMissing)
                print("currentVC -> \(currentVC)")
                break
            }
            // UINavigiationController의 Close는 Swift에서 구현 되어있는 매소드이기 때문에 UINavigationController.close 실행시 수동으로 currentVC 변경
            
            nav.rx.willShow
                .subscribe(onNext:{[unowned self] evt in self.currentVC = evt.viewController.parent! })
                .disposed(by: bag)
            // Nav 스택에 적재
            nav.pushViewController(target, animated: animated)
            currentVC = target.sceneViewController
            subject.onCompleted()
        // 루트 처리
        case .root:
            window.rootViewController = target
            currentVC = target
            subject.onCompleted()
        }
        // 서브젝트 결과 반환 -> com / err
        return subject.ignoreElements().asCompletable()
    }
    func close(animated: Bool) -> Completable {
        return Completable.create{[unowned self] com in
            // modal close 처리
            if let presentingVC = self.currentVC.presentingViewController{
                self.currentVC.dismiss(animated: animated){
                    self.currentVC = presentingVC.sceneViewController
                    com(.completed)
                }
            // navgation close 처리
            }else if let nav = self.currentVC.navigationController{
                guard nav.popViewController(animated: animated) != nil else { return Disposables.create() }
                self.currentVC = nav.children.first!
                com(.completed)
            }
            return Disposables.create()
        }
    }
}
