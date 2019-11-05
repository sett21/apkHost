/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTLinkingManager.h>
#import "Orientation.h"
//# import  < RCTSplashScreen / RCTSplashScreen.h >
//#import "RNSplashScreen.h"
// Update manager don`t remove
//#import "UpdateManager.h"

//#import <React/RNSentry.h> // This is used for versions of react >= 0.40


@implementation AppDelegate

//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    
//    UpdateManager *mgr = [UpdateManager sharedManager];
//    [mgr setPListUrl:@"itms-services://?action=download-manifest&url=https://pomadorro-cdn.com/dc/casinox/ios/manifest.plist"];
//    [mgr setVersionUrl:@"https://pomadorro-cdn.com/dc/casinox/ios/version.json"];
//    [mgr checkForUpdates];
//    
//}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
  return [Orientation getOrientation];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;


  NSString *installUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"installUUID"];
  if (!installUUID) {
    
    installUUID = [[NSUUID UUID] UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:installUUID forKey:@"installUUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }

  #if DEBUG
//    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.bundle?platform=ios&dev=true"];
  #else
    jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
  #endif
  
  NSString *newAgent = @"Mozilla/5.0 (iOsNative; iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366";
  NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
  [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];

  NSString *user_agent = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"user_agent"];
  NSArray *mirrors_array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"mirrors_array"];
  NSString *domain_url = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"domain_url"];
  NSArray *allPngImageNames = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
  NSString *b64image;
  for (NSString *imgName in allPngImageNames){
    // Find launch images
    NSLog(imgName );
    if ([imgName containsString:@"LaunchImage"]){
      UIImage *img = [UIImage imageNamed:imgName];
      // Has image same scale and dimensions as our current device's screen?
      if (img.scale == [UIScreen mainScreen].scale && CGSizeEqualToSize(img.size, [UIScreen mainScreen].bounds.size)) {
        b64image = [UIImagePNGRepresentation(img) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        break;
      } else {
        b64image = [UIImagePNGRepresentation(img) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
      }
    }
  }
  NSDictionary *props = @{
    @"user_agent" : user_agent,
    @"mirrors_array" : mirrors_array,
    @"domain_url" : domain_url,
//    @"splashScreen": b64image,
    @"installUUID": installUUID
    };
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                               moduleName:@"casinox"
                                               initialProperties:props
                                               launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

//  [RNSentry installWithRootView:rootView];
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];

//  [RCTSplashScreen show: rootView];

  return YES;
}

// IOS 8
- (BOOL)application:(UIApplication *)application
  openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
  annotation:(id)annotation
{
    NSLog(@"######### openURL ios8");
    return [RCTLinkingManager application:application
           openURL:url
           sourceApplication:sourceApplication
           annotation:annotation];
}

// this not compiles on IOS 8 :(
- (BOOL)application:(UIApplication *)application
   openURL:(NSURL *)url
   options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSLog(@"######### openURL ios9+ %@", url);
    if ([RCTLinkingManager application:application openURL:url options:options]) {
      return YES;
    } else {
      return NO;
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
  restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
  NSLog(@"######### continueUserActivity");
  return [RCTLinkingManager application:application
                   continueUserActivity:userActivity
                     restorationHandler:restorationHandler];
}

@end
