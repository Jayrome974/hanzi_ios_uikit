//
//  SceneDelegate.swift
//  Learn Useful Words
//
//  Created by Jay on 2020-11-08.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let wordsViewController = getWordsViewController() {
            wordsViewController.setLibraryService(makeLibraryServiceInDemoMode())
        }
    }
    
    fileprivate func getWordsViewController() -> WordsViewController? {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            return navigationController.viewControllers.first as? WordsViewController
        }
        
        return nil
    }
    
    fileprivate func makeLibraryServiceInDemoMode() -> LibraryService {
        let wordsApi = InMemoryWordsApi()
        return LibraryService(wordsApi)
    }
    
    func scene(_ scene: UIScene,
               openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        if isAppCalledAfterSignedIn(URLContexts) {
            if let authorizationCode = getAuthorizationCode(from:URLContexts.first!.url),
               let wordsViewController = getWordsViewController() {
                wordsViewController.setLibraryService(makeLibraryServiceInSignedInMode(with:authorizationCode))
                // Hide log in button
                wordsViewController.navigationItem.setRightBarButton(nil, animated: false)
            }
            
            dismissSafariViewUsedForSigningIn()
        }
    }
    
    fileprivate func isAppCalledAfterSignedIn(_ openURLContexts: Set<UIOpenURLContext>) -> Bool {
        if let urlContext = openURLContexts.first {
            
            if urlContext.options.sourceApplication != K.safariApplicationName {
                return false
            }
            
            if let urlHost = urlContext.url.host,
               urlHost == K.oAuth.signInCallbackUrlHostName {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func getAuthorizationCode(from url: URL) -> String? {
        return URLComponents(url: url, resolvingAgainstBaseURL: true)?
            .queryItems?
            .first(where: { $0.name == K.oAuth.authorizeAuthorizationCodeQueryName})?
            .value
    }
    
    fileprivate func makeLibraryServiceInSignedInMode(with authorizationCode:String) -> LibraryService {
        let oAuthGetTokenState = OAuthAuthorizationCodeState(authorizationCode)
        let oAuthService = OAuthService(oAuthGetTokenState)
        let wordsApi = WordsApiClient(oAuthService)
        return LibraryService(wordsApi)
    }
    
    fileprivate func dismissSafariViewUsedForSigningIn() {
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

