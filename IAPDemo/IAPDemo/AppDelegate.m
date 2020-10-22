//
//  AppDelegate.m
//  IAPDemo
//
//  Created by OFweek01 on 2020/10/22.
//

#import "AppDelegate.h"
#import "WalletService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //IAP内购丢单处理
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkOrderStatus];
//        [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
//
//        } failure:^(NSError *error) {
//
//        }];
    });
    
    return YES;
}

#pragma mark -- 丢单处理
static NSString *const kSaveReceiptData = @"kSaveReceiptData";
//检查漏单情况
- (void)checkOrderStatus
{
    NSMutableArray *orderInfo = [self getReceiptData];
    if (orderInfo != nil) {
        [self verifyPurchaseForServiceWithReceipt:orderInfo];
    }
}

- (void)verifyPurchaseForServiceWithReceipt:(NSMutableArray *)receiptString {
    [WalletService appleRechargeWithParameters:receiptString success:^(NSString *data) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self removeLocReceiptData];
    } failure:^(NSUInteger code, NSString *errorStr) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)saveReceiptData:(NSDictionary *)receiptData
{
    [[NSUserDefaults standardUserDefaults] setValue:receiptData forKey:kSaveReceiptData];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSMutableArray *)getReceiptData
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kSaveReceiptData];
}

- (void)removeLocReceiptData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSaveReceiptData];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
