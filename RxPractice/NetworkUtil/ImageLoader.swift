//
//  ImageLoader.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/25.
//
import UIKit
import RxSwift

class ImageLoader{
    // NSCache<KeyType,ObjectType>
    private var imageCache = NSCache<NSString,UIImage>()
    var fileManager = FileManager()
    // 캐시 오브젝트 초기화 url의 이미지 파일에서 이름만 가져와서 키값으로 초기화
    func setCacheObj(url:URL,img:UIImage){ imageCache.setObject(img, forKey: url.lastPathComponent as NSString) }
    func getFile(url:URL) -> UIImage? {
        var urlImage:UIImage? = nil
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return urlImage }
        var filePath = URL(fileURLWithPath: path)
        filePath.appendPathComponent(url.lastPathComponent)
        if !fileManager.fileExists(atPath:filePath.path){
            //Download URL
            ApplicationNotiCenter.downLoadingCount.post()
            guard let imageData = try? Data(contentsOf: url) else { return urlImage }
            urlImage = UIImage(data:imageData)
            self.setCacheObj(url: url, img: urlImage!)
            self.fileManager.createFile(atPath: filePath.path,contents: imageData, attributes: nil)
        }else{
            //Disk Cache
            guard let imageData = try? Data(contentsOf: filePath) else { return nil }
            guard let image = UIImage(data:imageData) else { return nil }
            return image
        }
        return urlImage
    }
    func loadImage(url: String) -> Observable<UIImage> {
        return Observable<UIImage>.create{ [unowned self] observer in
            let url = URL(string: url)!
            let data = self.getFile(url: url)!
            observer.onNext(data)
            return Disposables.create()
        }
    }
}
