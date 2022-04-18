import Flutter
import UIKit
import FBSDKCoreKit

let FBMarketURL = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215");
let INSTAMarketURL = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id389801252");

public class SwiftMdInstaFbSharePlugin: NSObject, FlutterPlugin, SharingDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "md_insta_fb_share_plus", binaryMessenger: registrar.messenger())
    let instance = SwiftMdInstaFbSharePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if (call.method == "share_insta_story") {
          let args = (call.arguments as! NSDictionary)
          let sourceApplication = args["sourceApplication"] as! String;
          print(sourceApplication);
          let urlScheme = URL(string: "instagram-stories://share?source_application="+sourceApplication)!
          print(urlScheme);
          if (UIApplication.shared.canOpenURL(urlScheme)) {
              let backgroundImagePath = args["backgroundImage"] as! String;
              let externalUrl = args["externalUrl"] as! String;
              let backgroundTopColor = args["backgroundTopColor"] as! String;
              let backgroundBottomColor = args["backgroundBottomColor"] as! String;
              
              var backgroundImage: UIImage? = nil;
              let fileManager = FileManager.default;
              
        
              let isBackgroundImageExist = fileManager.fileExists(atPath: backgroundImagePath);
              if (isBackgroundImageExist) {
                  backgroundImage = UIImage(contentsOfFile: backgroundImagePath)!;
              } else {
                  result(2);
                  return;
              }
              
              let pasteboardItems = [
                "com.instagram.sharedSticker.stickerImage" : (backgroundImage ?? nil) as Any,
                "com.instagram.sharedSticker.contentURL" : (externalUrl ?? nil) as Any,
                "com.instagram.sharedSticker.backgroundTopColor" : (backgroundTopColor ?? nil) as Any,
                "com.instagram.sharedSticker.backgroundBottomColor" : (backgroundBottomColor ?? nil) as Any
              ] as [String : Any];
              
              if #available(iOS 10.0, *) {
                  let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
                  UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                  UIApplication.shared.open(urlScheme, options: [:], completionHandler: { (success) in
                      if (success) {
                          result(0);
                      } else {
                          result(1);
                      }
                  })
              } else {
                  UIPasteboard.general.items = [pasteboardItems]
                  UIApplication.shared.openURL(urlScheme)
                  result(0);
              }
          } else {
              if #available(iOS 10.0, *) {
                  UIApplication.shared.open(INSTAMarketURL!, options: [:], completionHandler: { (success) in })
              } else {
                  UIApplication.shared.openURL(INSTAMarketURL!)
              }
              result(1);
          }
      } else if (call.method == "share_insta_feed") {
          let args = (call.arguments as! NSDictionary);
          let urlScheme = URL(string: "instagram-stories://app")!
          if (UIApplication.shared.canOpenURL(urlScheme)) {
              let backgroundImagePath = args["backgroundImage"] as! String;
            
              let fileManager = FileManager.default;
              
              let isBackgroundImageExist = fileManager.fileExists(atPath: backgroundImagePath);
              if (isBackgroundImageExist) {
                  postImageToInstagram(UIImage(contentsOfFile: backgroundImagePath)!, completion: result);
              } else {
                  result(2);
              }
          } else {
              if #available(iOS 10.0, *) {
                  UIApplication.shared.open(INSTAMarketURL!, options: [:], completionHandler: { (success) in })
              } else {
                  UIApplication.shared.openURL(INSTAMarketURL!)
              }
              result(1);
          }
      } else if (call.method == "share_FB_story") {
          let args = (call.arguments as! NSDictionary)
          let urlScheme = URL(string: "facebook-stories://share")!
          if (UIApplication.shared.canOpenURL(urlScheme)) {
              let backgroundImagePath = args["backgroundImage"] as! String;
              
              var backgroundImage: UIImage? = nil;
              let fileManager = FileManager.default;
              
        
              let isBackgroundImageExist = fileManager.fileExists(atPath: backgroundImagePath);
              if (isBackgroundImageExist) {
                  backgroundImage = UIImage(contentsOfFile: backgroundImagePath)!;
              } else {
                  return result(2);
              }
              
              let facebookAppID = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String;
              
              if (facebookAppID == nil) {
                  print("FacebookAppID not specified in info.plist");
                  result(4);
                  return;
              }
              
              let pasteboardItems = [
                "com.facebook.sharedSticker.backgroundImage" : (backgroundImage ?? nil) as Any,
                "com.facebook.sharedSticker.appID": facebookAppID!,
              ] as [String : Any];
              
              if #available(iOS 10.0, *) {
                  let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
                  UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                  UIApplication.shared.open(urlScheme, options: [:], completionHandler: { (success) in
                      if (success) {
                          result(0);
                      } else {
                          result(1);
                      }
                  })
              } else {
                  UIPasteboard.general.items = [pasteboardItems]
                  UIApplication.shared.openURL(urlScheme)
                  result(0);
              }
          } else {
              if #available(iOS 10.0, *) {
                  UIApplication.shared.open(FBMarketURL!, options: [:], completionHandler: { (success) in })
              } else {
                  UIApplication.shared.openURL(FBMarketURL!)
              }
              result(1);
          }
      } else if (call.method == "share_FB_feed") {
          let args = (call.arguments as! NSDictionary)
          let backgroundImagePath = args["backgroundImage"] as! String;
          
          let urlScheme = URL(string: "facebook-stories://app")!
          if (!UIApplication.shared.canOpenURL(urlScheme)) {
              if #available(iOS 10.0, *) {
                  UIApplication.shared.open(FBMarketURL!, options: [:], completionHandler: { (success) in })
              } else {
                  UIApplication.shared.openURL(FBMarketURL!)
              }
              return result(1);
          }
          
          var backgroundImage: UIImage? = nil;
          let fileManager = FileManager.default;
          
          let isBackgroundImageExist = fileManager.fileExists(atPath: backgroundImagePath);
          if (isBackgroundImageExist) {
              backgroundImage = UIImage(contentsOfFile: backgroundImagePath)!;
          } else {
              return result(1);
          }
          
          let photo = SharePhoto(
              image: backgroundImage!,
              isUserGenerated: true
          );
          let content = SharePhotoContent();
          content.photos = [photo];
          
          let viewController = UIApplication.shared.delegate?.window??.rootViewController;
          ShareDialog(viewController: viewController, content: content, delegate: self).show()
          result(0);
      } else if (call.method == "check_insta") {
          let urlScheme = URL(string: "instagram-stories://app")!
          result(UIApplication.shared.canOpenURL(urlScheme));
      } else if (call.method == "check_FB") {
          let urlScheme = URL(string: "facebook-stories://app")!
          result(UIApplication.shared.canOpenURL(urlScheme));
      } else {
          result("Not implemented");
      }
  }
    func postImageToInstagram(_ image: UIImage, completion: @escaping FlutterResult) {
        if UIApplication.shared.canOpenURL(URL(string: "instagram://app")!) {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    completion(0);
                } else {
                    completion(3);
                }
            }
        } else {
            completion(1);
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
            return
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let lastAsset = fetchResult.firstObject {
            let localIdentifier = lastAsset.localIdentifier
            let u = "instagram://library?LocalIdentifier=" + localIdentifier
            let url = NSURL(string: u)!
            if UIApplication.shared.canOpenURL(url as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil);
                } else {
                    UIApplication.shared.openURL(URL(string: u)!);
                }
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(INSTAMarketURL!, options: [:], completionHandler: { (success) in })
                } else {
                    UIApplication.shared.openURL(INSTAMarketURL!)
                }
            }
            
        }
    }
    
    //Facebook delegate methods
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("Share: Success")
        
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("Share: Fail")
        
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        print("Share: Cancel")
    }
}
