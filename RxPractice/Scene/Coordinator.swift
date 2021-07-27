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
            guard let nav = currentVC.children.first as? UINavigationController else {
                subject.onError(TransitionError.naviMissing)
                break
            }
            // UINavigiationController의 Close는 Swift에서 구현 되어있는 매소드이기 때문에 UINavigationController.close 실행시 수동으로 currentVC 변경
            // Closure 에서 순환 참조를 끊어주기 위한 무소유 참조[unowned self] or 약한 참조[weak self] 사용 -> memory leak 방지
            // 둘다 주소값을 참조하지만 참조 카운트가 올라가지 않음 단, 약한 참조는 옵셔널 값을 가지지만 무소유 참조는 옵셔널 값이 아님
            // -> 따라서 무소유 참조를 사용할 경우 피참조 변수값이 먼저 해제(nil)가 될 경우 참조한 변수는 메모리 해제가 안됨(nil 값을 가질 수 없기 때문에) 또한 값접근시 해당 주소는 해제 되어있는 상태이므로 오류 발생
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
