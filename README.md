# RxPractice
open API를 호출하여 셀에 바인딩하는 작업을 효율성과 기능등을 고려하며 연습한 앱 (2021.7.27 ~ 2021.7.28)

## 폴더구조
* Noti
  * 노티피케이션센터 파일
* Model
  * 모델파일
* Repository
  * APIsearching 파일
* NetworkUtil
  * 네트워크통신 파일
* ViewControllers
  * 뷰컨트롤러 파일
  * 스토리보드 파일
  * 뷰컨트롤러바인딩 프로토콜
* ViewModel
  * 뷰모델 파일
  * 뷰모델타입 파일
* Scene
  * 씬 파일
  * 씬 코디네이터 파일
  
  
# 프로젝트 설명
## 사용 라이브러리리
![Generic badge](https://img.shields.io/badge/RxSwift-6.2.0-blue.svg)
![Generic badge](https://img.shields.io/badge/Action-4.3.0-blue.svg)
![Generic badge](https://img.shields.io/badge/Alamofire-5.4.3-blue.svg)
![Generic badge](https://img.shields.io/badge/NSObject+Rx-5.2.2-blue.svg)
## 샐행화면
![my_video](https://user-images.githubusercontent.com/73823603/128628210-60b9cc79-3498-42be-85c3-20ff5a483d3c.mp4)
## 실행화면 설명
•사용자입력에 따른 검색결과를 출력합니다.  
•우상단의 버튼으로 GridCell <-> ListCell 레이아웃 변경이 가능합니다.  
•스크롤 다운으로 무한스크롤이 가능합니다.  
•셀을 탭하면 상세 웹페이지로 이동할 수 있습니다.   
•Image URL Loading시 카운팅을 확인할 수 있습니다.  



# 주요기능 
## -Image Loading
•캐시선언후 URL의 파일이름으로 키값을 초기화
```swift
func setCacheObj(url:URL,img:UIImage){ imageCache.setObject(img, forKey: url.lastPathComponent as NSString) }
```
•캐시히트 실패시 URL로부터 직접 다운로딩을 한후 캐싱해준다 (Loading Count + 1)
```swift
        if !fileManager.fileExists(atPath:filePath.path){
            //Download URL
            ApplicationNotiCenter.downLoadingCount.post()
            guard let imageData = try? Data(contentsOf: url) else { return urlImage }
            urlImage = UIImage(data:imageData)
            self.setCacheObj(url: url, img: urlImage!)
            self.fileManager.createFile(atPath: filePath.path,contents: imageData, attributes: nil)
        }
```
•캐시히트시 디스크에서 해당이미지를 가져온다.
```swift
        {
          guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return urlImage }
          var filePath = URL(fileURLWithPath: path)
          filePath.appendPathComponent(url.lastPathComponent)
            //Disk Cache
            guard let imageData = try? Data(contentsOf: filePath) else { return nil }
            guard let image = UIImage(data:imageData) else { return nil }
            return image
        }
```

## -사용자입력 처리
•Rx.debounce 메소드를 활용하여 API 호출을 줄임
```swift
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
```
## -Grid<->List 레이아웃 변경
•레이아웃 변경 로직
```swift
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
```
•버튼 바인딩
```swift
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
```
## -동기화작업
•observeOn 과 subcribeOn을 활용하여 스레드 동기화
```swift
self.viewModel.imageLoading(url: element.imageURL)
                        .subscribe(on: backgroundScheduler)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext:{img in
                            cell.thumbnail.image = img
                        })
                        .disposed(by: self.rx.disposeBag)
```                        
# 아쉬운 점
## 이미지 리사이징
사용되는 이미지가 불필요하게 사이즈가 커서 메모리가 낭비되는데, 이미지 리사이징을 사용하면 메모리 낭비를 막을 수 있음
## 인스턴스 재사용
많은 데이터를 받아서 파싱하는 과정에서 셀의 개수만큼 데이터 인스턴스가 생성되는데, 재사용하면 메모리 낭비를 방지할 
