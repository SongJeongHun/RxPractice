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
    var downLoadingCount = 0
    let backgroundScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var gridCellButton:UIBarButtonItem!
    @IBOutlet weak var refreshButton:UIBarButtonItem!
    @IBOutlet weak var searchBar:UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = String(downLoadingCount)
        convertToList()
        addRefreshController()
        collectionView.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }
    func bindViewModel() {
        cellBinding()
        convertButtonBinding()
        searchBarBinding()
        scrollLoadBinding()
        transition()
        ApplicationNotiCenter.downLoadingCount.addObserver()
            .observe(on: MainScheduler.instance)
            // Closure 에서 순환 참조를 끊어주기 위한 무소유 참조[unowned self] or 약한 참조[weak self] 사용 -> memory leak 방지
            // 둘다 주소값을 참조하지만 참조 카운트가 올라가지 않음 단, 약한 참조는 옵셔널 값을 가지지만 무소유 참조는 옵셔널 값이 아님
            // -> 따라서 무소유 참조를 사용할 경우 피참조 변수값이 먼저 해제(nil)가 될 경우 참조한 변수는 메모리 해제가 안됨(nil 값을 가질 수 없기 때문에) 또한 값접근시 해당 주소는 해제 되어있는 상태이므로 오류 발생
            .subscribe(onNext:{[unowned self] _ in
                self.downLoadingCount += 1
                self.navigationItem.title = String(downLoadingCount)
            })
            .disposed(by: rx.disposeBag)
    }
    func scrollLoadBinding(){
        collectionView.rx.willDisplayCell
            .subscribe(onNext:{[unowned self] evt in
                if evt.at.row + 1 == self.viewModel.listCount(){
                    self.viewModel.next(queryItem: self.input)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    func searchBarBinding(){
        searchBar.rx.text.orEmpty
            // 1초 기다림
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            // 같은 아이템은 받지 않음
            .distinctUntilChanged()
            .subscribe(onNext:{[unowned self] text in
                self.input = text
                if input != ""{
                    self.viewModel.searching(queryItem: input)
                    self.view.endEditing(true)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    func convertButtonBinding(){
        // Grid <-> List 셀전환 1초 쓰로틀
        gridCellButton.rx.tap
            .throttle((.milliseconds(1000)), scheduler: MainScheduler.instance)
            .subscribe(onNext:{[unowned self] _ in
                if self.isGrid{
                    self.gridCellButton.title = "Grid"
                    self.isGrid = false
                    self.convertToList()
                }else{
                    self.gridCellButton.title = "List"
                    self.isGrid = true
                    self.convertToGrid()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    func cellBinding(){
        viewModel.getList
            .debug()
            .bind(to:collectionView.rx.items){[unowned self] collectionView,row,element in
                // GridCell 일때
                if self.isGrid{
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: IndexPath(row: row, section: 0)) as? GridCell else { fatalError() }
                    // UIImage 바인딩 동기화문제 -> 인스턴스 생성은 subscribe(on:) 을 통하여 url Loading을 백그라운드에서 작업을 하고
                    // UI 바인딩 작업은 observe(on:)에서 작업을 해야함
                    self.viewModel.imageLoading(url: element.imageURL)
                        .subscribe(on: backgroundScheduler)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext:{img in
                            cell.thumbnail.image = img
                        })
                        .disposed(by: self.rx.disposeBag)
                    return cell
                }else{
                    // ListCell 일때
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: IndexPath(row: row, section: 0)) as? ListCell else { fatalError() }
                    self.viewModel.imageLoading(url: element.imageURL)
                        .subscribe(on: backgroundScheduler)
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
    func transition(){
        collectionView.rx.modelSelected(Image.self)
            .do(onNext:{t in
                print(t)
            })
            .bind(to:viewModel.detailAction.inputs)
            .disposed(by: rx.disposeBag)
    }
}
// UI 관련 메소드
extension ListViewController: UIGestureRecognizerDelegate{
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
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        collectionView.performBatchUpdates {[unowned self] in
            let visibleItems = self.collectionView.indexPathsForVisibleItems ?? []
            self.collectionView.reloadItems(at: visibleItems)
        }
    }
    func addRefreshController(){
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(previous), for: .valueChanged)
    }
    @IBAction func previous(){
        viewModel.previous(queryItem: input)
        collectionView.refreshControl?.endRefreshing()
    }
}
class ListCell:UICollectionViewCell{
    @IBOutlet weak var thumbnail:UIImageView!
    @IBOutlet weak var source:UILabel!
}
class GridCell:UICollectionViewCell{
    @IBOutlet weak var thumbnail:UIImageView!
}

