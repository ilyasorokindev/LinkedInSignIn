//
//  LinkedInLoginVC.swift
//  LISignIn
//
//  Created by Gabriel Theodoropoulos on 21/12/15.
//  Copyright © 2015 Appcoda. All rights reserved.
//

import UIKit
import WebKit

enum LinkedInLoginError: Error {
    case error(String)
}

class LinkedInLoginVC: UIViewController {
    var webView: WKWebView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var linkedInConfig: LinkedInConfig! = nil
    
    var loadingTitleString: String? = nil
    var loadingTitleFont: UIFont? = nil
    
    var navigationColor: UIColor? = nil
    
    var isCompleted : Bool = false
    
    var completion: ((String) -> Void)? = nil
    var failure: ((Error) -> Void)? = nil
    var cancel: (() -> Void)? = nil
    
    let authorizationEndPoint = "https://www.linkedin.com/uas/oauth2/authorization"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = self.navigationColor
        self.view.backgroundColor = self.navigationColor
        self.addWebView()
        self.showHUD()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isCompleted {
            if let cancel = cancel{
                cancel()
            }
        }
        
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func login(linkedInConfig: LinkedInConfig, completion: @escaping (String) -> Void, failure: @escaping (Error) -> Void, cancel: @escaping (() -> Void)) {
        self.completion = completion
        self.failure = failure
        self.cancel = cancel
        self.linkedInConfig = linkedInConfig
        self.startAuthorization(linkedInConfig.scope)
    }
    
    func startAuthorization(_ scope: String) {
        let responseType = "code"
        let state = self.linkedInConfig.state
        
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(linkedInConfig.linkedInKey)&"
        authorizationURL += "redirect_uri=\(linkedInConfig.redirectURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
        
        print(authorizationURL)
        
        let url = URL(string: authorizationURL)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
}

extension LinkedInLoginVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideHUD()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.failureError(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.contains(authorizationEndPoint) {
                decisionHandler(.allow)
                return
            }
            if url.absoluteString.contains(linkedInConfig.redirectURL), let code =  URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "code" })?.value  {
                isCompleted = true
                completion(code)
                decisionHandler(.cancel)
                return
            }
            if url.absoluteString.contains("error=access_denied") {
                failureString("Access Denied")
                isCompleted = false
                decisionHandler(.cancel)
                return
            } else if url.absoluteString.contains("login-cancel?") {
                failureString("Login Cancel")
                isCompleted = false
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
            return
        }
        decisionHandler(.allow)
    }
}

extension LinkedInLoginVC {
    func failureError(_ error: Error) {
        if let failure = failure {
            failure(LinkedInLoginError.error(error.localizedDescription))
        }
    }
    
    func failureString(_ error: String) {
        if let failure = failure {
            failure(LinkedInLoginError.error(error))
        }
    }
    
    func completion(_ accessToken: String) {
        if let completion = completion {
            completion(accessToken)
        }
    }
}

extension LinkedInLoginVC {
    func showHUD() {
//        DispatchQueue.main.async {
//            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
//            UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = UIColor.white
//            if let labeltext = self.loadingTitleString {
//                progressHUD?.labelText = labeltext
//            }
//            if let labelFont = self.loadingTitleFont {
//                progressHUD?.labelFont = labelFont
//            }
//            progressHUD?.color = UIColor(red: 0.0/255.0, green: 119.0/255.0, blue: 181.0/255.0, alpha: 1.0)
//            progressHUD?.bringSubviewToFront(self.view)
//        }
    }
    
    func hideHUD() {
//        DispatchQueue.main.async {
//            MBProgressHUD.hide(for: self.view, animated: true)
//        }
    }
}

extension LinkedInLoginVC {
    func addWebView() {
        webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: webView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: navigationBar, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: webView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: webView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: webView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0).isActive = true
    }
}
