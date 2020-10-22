//
//  ViewController.m
//  IAPDemo
//
//  Created by OFweek01 on 2020/10/22.
//

#import "ViewController.h"
#import "RMStore.h"
#import "WalletService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //充值productID
    NSSet *set = [NSSet setWithObjects:@"com.yiqi.LIEBANG.chongzhibi6",
                  @"com.yiqi.LIEBANG.chongzhibi30",
                  @"com.yiqi.LIEBANG.chongzhibi60",
                  @"com.yiqi.LIEBANG.chongzhibi108",
                  @"com.yiqi.LIEBANG.chongzhibi298",
                  @"com.yiqi.LIEBANG.chongzhibi518",
                  @"com.yiqi.LIEBANG.chongzhibi998",
                  @"com.yiqi.LIEBANG.chongzhibi1998",
                  @"com.yiqi.LIEBANG.chongzhibi2998", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    });
    // 准备
    //[self displayOverFlowActivityView];
    [[RMStore defaultStore] requestProducts:set success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        });
        //[self removeOverFlowActivityView];
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        });
        //[self removeOverFlowActivityView];
    }];
}

- (void)pay {
    
    if (![RMStore canMakePayments]) return;
    
    NSArray *ids = @[@"com.yiqi.LIEBANG.chongzhibi6",
                     @"com.yiqi.LIEBANG.chongzhibi30",
                     @"com.yiqi.LIEBANG.chongzhibi60",
                     @"com.yiqi.LIEBANG.chongzhibi108",
                     @"com.yiqi.LIEBANG.chongzhibi298",
                     @"com.yiqi.LIEBANG.chongzhibi518",
                     @"com.yiqi.LIEBANG.chongzhibi998",
                     @"com.yiqi.LIEBANG.chongzhibi1998",
                     @"com.yiqi.LIEBANG.chongzhibi2998"];
    
    //self.isPaying = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //[self displayOverFlowActivityView];
    [[RMStore defaultStore] addPayment:ids.firstObject success:^(SKPaymentTransaction *transaction) {
        [self GetMGRMStoreWithReceipt];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //[self removeOverFlowActivityView];
        //self.isPaying = NO;
        //[self showAlertWithString:[NSString stringWithFormat:@"充值失败\n%@",error.localizedDescription]];
    }];
}

- (NSString *)GetMGRMStoreWithReceipt
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [self saveReceiptData:receiptStr];
    // 验证服务器票据（修改订单状态）
    [self verifyPurchaseForServiceWithReceipt:receiptStr];
    return receiptStr;
}

- (void)verifyPurchaseForServiceWithReceipt:(NSString *)receiptString {
    
    [WalletService appleRechargeWithParameters:[self getReceiptData] success:^(NSString *data) {
        //self.isPaying = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //[self removeOverFlowActivityView];
        [self removeLocReceiptData];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self loadBalance];
        });
    } failure:^(NSUInteger code, NSString *errorStr) {
        //self.isPaying = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //[self removeOverFlowActivityView];
    }];
}

#pragma mark -- 本地保存一次支付凭证
static NSString *const kSaveReceiptData = @"kSaveReceiptData";

- (void)saveReceiptData:(NSString *)receiptData
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self getReceiptData]];
    [array addObject:receiptData];
    [[NSUserDefaults standardUserDefaults] setValue:array forKey:kSaveReceiptData];
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


@end
