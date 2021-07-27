//
//  ListViewController.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/25.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ListViewController: UIViewController,ViewControllerBindType,UICollectionViewDelegate {
    var viewModel:ListViewModel!
    var input:String = "사과"
    var isGrid:Bool = false
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var gridCellButton:UIBarButtonItem!
    @IBOutlet weak var refreshButton:UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        convertToList()
        collectionView.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }
    func bindViewModel() {
        // Grid <-> List 셀전환 1초 쓰로틀
        gridCellButton.rx.tap
            .throttle((.milliseconds(1000)), scheduler: MainScheduler.instance)
            .subscribe(onNext:{ _ in
                if self.isGrid{
                    self.isGrid = false
                    self.convertToList()
                    
                }else{
                    self.isGrid = true
                    self.convertToGrid()
                }
            })
            .disposed(by: rx.disposeBag)
        viewModel.getList(queryItem: input)
            .bind(to:collectionView.rx.items){collectionView,row,element in
                // GridCell 일때
                if self.isGrid{
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: IndexPath(row: row, section: 0)) as? GridCell else { fatalError() }
                    // UIImage 바인딩 동기화문제 -> 인스턴스 생성은 ConcurrentDispatchQueueScheduler 을 통하여 url Loading을 백그라운드에서 작업을 하고
                    // UI 바인딩 작업은 MainScheduler에서 작업을 해야함
                    ImageLoader.loadImage(url: element.imageURL)
                        .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos:.background))
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext:{img in
                            cell.thumbnail.image = img
                        })
                        .disposed(by: self.rx.disposeBag)
                    return cell
                }else{
                    // ListCell 일때
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: IndexPath(row: row, section: 0)) as? ListCell else { fatalError() }
                    ImageLoader.loadImage(url: element.imageURL)
                        .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos:.background))
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext:{img in
                            cell.thumbnail.image = img
                        })
                        .disposed(by: self.rx.disposeBag)
                    cell.source.text = element.sourceURL
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
    }
}
// UI 관련 메소드
extension ListViewController{
    func convertToList(){
        // collectionView layout 정의
        // layout을 세팅해준후 현재 보이는 셀들의 레이아웃을 업데이트 해줌
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        collectionView.performBatchUpdates {[unowned self] in
            let visibleItems = self.collectionView.indexPathsForVisibleItems ?? []
            self.collectionView.reloadItems(at: visibleItems)
        }
    }
    func convertToGrid(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 60, height: 60)
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        collectionView.performBatchUpdates {[unowned self] in
            let visibleItems = self.collectionView.indexPathsForVisibleItems ?? []
            self.collectionView.reloadItems(at: visibleItems)
        }
    }
}
class ListCell:UICollectionViewCell{
    @IBOutlet weak var thumbnail:UIImageView!
    @IBOutlet weak var source:UILabel!
}
class GridCell:UICollectionViewCell{
    @IBOutlet weak var thumbnail:UIImageView!
}

