//
//  DetailViewController.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/28.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate{
    var webURL: URL!
    @IBOutlet weak var webView:WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: webURL)
        webView.load(request)
        // Do any additional setup after loading the view.
    }
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame: self.view.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view = self.webView
    }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() } //모달창 닫힐때 앱 종료현상 방지.
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler() }))
        self.present(alertController, animated: true, completion: nil) }
    
    //confirm 처리
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in completionHandler(false) }))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler(true) }))
        self.present(alertController, animated: true, completion: nil) }
    
    // href="_blank" 처리
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
        return nil }
}
