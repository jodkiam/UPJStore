//
//  CodeViewController.m
//  UPJStore
//
//  Created by upj on 16/3/11.
//  Copyright © 2016年 UPJApp. All rights reserved.
//

#import "CodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "AFNetWorking.h"
#import "GoodSDetailViewController.h"
#import <CommonCrypto/CommonDigest.h>



@interface CodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    UIButton *backBtn;
    UILabel *title;
    UILabel *subTitle;
    UIImageView *codeFrame;
    UIImageView *cornerView;
    NSString *code;
    UIAlertController *alertCon;
    NSString *productId;
}

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;
@end

@implementation CodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置navigationBar
    self.view.backgroundColor = [UIColor lightGrayColor];
    // 毛玻璃效果
    /*
     UIVisualEffectView *visualView1 = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
     UIVisualEffectView *visualView2 = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
     UIVisualEffectView *visualView3 = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
     UIVisualEffectView *visualView4 = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
     
     visualView1.frame = CGRectMake(0, 0, kWidth, (kHeight-220)/2);
     visualView2.frame = CGRectMake(0, (kHeight-220)/2, (kWidth-220)/2,220);
     visualView2.layer.borderWidth = 0;
     visualView3.frame = CGRectMake((kWidth-220)/2+220,(kHeight-220)/2, (kWidth-220)/2,220);
     visualView4.frame = CGRectMake(0,(kHeight-220)/2+220, kWidth, (kHeight-220)/2);
     
     [self.view addSubview:visualView1];
     [self.view addSubview:visualView2];
     [self.view addSubview:visualView3];
     [self.view addSubview:visualView4];
     */
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake1(0, 0, kWidth, (kHeight-220)/2)];
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake1(0, (kHeight-220)/2, (kWidth-220)/2,220)];
    UIView *view3 = [[UIView alloc]initWithFrame:CGRectMake1((kWidth-220)/2+220,(kHeight-220)/2, (kWidth-220)/2,220)];
    UIView *view4 = [[UIView alloc]initWithFrame:CGRectMake1(0,(kHeight-220)/2+220, kWidth, (kHeight-220)/2)];
    view1.backgroundColor = [UIColor blackColor];
    view1.alpha = 0.8;
    view2.backgroundColor = [UIColor blackColor];
    view2.alpha = 0.8;
    view3.backgroundColor = [UIColor blackColor];
    view3.alpha = 0.8;
    view4.backgroundColor = [UIColor blackColor];
    view4.alpha = 0.8;
    
    [self.view addSubview:view1];
    [self.view addSubview:view2];
    [self.view addSubview:view3];
    [self.view addSubview:view4];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backArrow"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    
    title = [[UILabel alloc]initWithFrame:CGRectMake(0,0,kWidth,44)];
    title.text = @"二维码/条形码";
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = title;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // 副标题
    subTitle = [[UILabel alloc]initWithFrame:CGRectMake1(0,(kHeight-220)/2-35, kWidth, 30)];
    subTitle.text = @"对准二维码/条形码到框内即可扫描";
    subTitle.font = [UIFont boldSystemFontOfSize:11];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:subTitle];
    
    // 扫码框
    codeFrame = [[UIImageView alloc]initWithFrame:CGRectMake1((kWidth-220)/2, (kHeight-220)/2, 220, 220)];
    codeFrame.backgroundColor = [UIColor clearColor];
    codeFrame.layer.borderWidth = 2;
    codeFrame.layer.borderColor = [[UIColor whiteColor]CGColor];
    [self.view addSubview:codeFrame];
    
    // 四角
    cornerView = [[UIImageView alloc]initWithFrame:CGRectMake1((kWidth-230)/2, (kHeight-230)/2, 230, 230)];
    cornerView.backgroundColor = [UIColor clearColor];
    cornerView.image = [UIImage imageNamed:@"corner"];
    [self.view addSubview:cornerView];
    
    //扫描二维码
    // Device
    _device = [ AVCaptureDevice defaultDeviceWithMediaType : AVMediaTypeVideo ];
    
    // Input
    NSError *error;
    
    _input = [ AVCaptureDeviceInput deviceInputWithDevice : self.device error:&error];
    DLog(@"%@",error);
    // Output
    _output = [[ AVCaptureMetadataOutput alloc ] init ];
    [ _output setMetadataObjectsDelegate : self queue : dispatch_get_main_queue ()];
    [ _output setRectOfInterest : CGRectMake (( 124 )/ kHeight ,(( kWidth - 156 )/ 2 )/ kWidth , 220 /kHeight , 220 / kWidth )];
    // Session
    _session = [[ AVCaptureSession alloc ] init ];
    [ _session setSessionPreset : AVCaptureSessionPresetHigh ];
    if ([ _session canAddInput : self . input ])
    {
        [ _session addInput : self . input ];
    }
    if ([ _session canAddOutput : self . output ])
    {
        [ _session addOutput : self . output ];
    }
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    // Preview
    _preview =[ AVCaptureVideoPreviewLayer layerWithSession : _session ];
    _preview . videoGravity = AVLayerVideoGravityResizeAspectFill ;
    _preview . frame = self . view . layer . bounds ;
    [ self . view . layer insertSublayer : _preview atIndex : 0 ];
    // Start
    [ _session startRunning ];
    
    
    // Do any additional setup after loading the view.
}
-(void)backAction:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_session startRunning];
    self.tabBarController.tabBar.hidden = YES;
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- ( void )captureOutput:( AVCaptureOutput *)captureOutput didOutputMetadataObjects:( NSArray *)metadataObjects fromConnection:( AVCaptureConnection *)connection
{
    
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        DLog(@"%@",metadataObject.stringValue);
        code = metadataObject.stringValue;
        [_session stopRunning];
    }
    if ([self isPureInt:code]) {
        NSDictionary * dic = @{@"appkey":APPkey,@"code":code};
        
        NSDictionary * Ndic = [self md5DicWith:dic];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        [manager POST:kGoodDetailURL parameters:Ndic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            DLog(@"%@",responseObject);
            
            NSNumber *number = [responseObject valueForKey:@"errcode"];
            NSString *errcode = [NSString stringWithFormat:@"%@",number];
            if ([errcode isEqualToString:@"10240"]) {
                NSString *str1 = [responseObject valueForKey:@"errmsg"];
                alertCon = [UIAlertController alertControllerWithTitle:nil message:str1 preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [ _session startRunning ];
                }];
                [alertCon addAction:okAction];
                [self.navigationController presentViewController:alertCon animated:YES completion:nil];
                
            }else{
                GoodSDetailViewController * goodDetailVC = [[GoodSDetailViewController alloc]init];
                goodDetailVC.goodsDic = dic;
                [self.navigationController pushViewController:goodDetailVC animated:YES];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DLog(@"failure%@",error);
        }];
    }else if ([code rangeOfString:@"weisida"].location !=NSNotFound){
        DLog(@"%@",code);
        NSString *testStr = code;
        productId = [self getOnlyNum:testStr][1];
        DLog(@"结果为:%@",[self getOnlyNum:testStr][1]);
        
        /*
         NSRange range = NSMakeRange(47,4);//匹配得到的下标
         productId = [code substringWithRange:range];//截取范围类的字符串
         if (![self isPureInt:productId]) {
         productId = [productId substringToIndex:[productId length] - 1];
         DLog(@"id为：%@",productId);
         }
         */
        NSDictionary * dic = @{@"appkey":APPkey,@"id":productId};
        
        NSDictionary * Ndic = [self md5DicWith:dic];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        [manager POST:kGoodDetailURL parameters:Ndic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            DLog(@"%@",responseObject);
            
            NSNumber *number = [responseObject valueForKey:@"errcode"];
            NSString *errcode = [NSString stringWithFormat:@"%@",number];
            if ([errcode isEqualToString:@"10240"]) {
                NSString *str1 = [responseObject valueForKey:@"errmsg"];
                alertCon = [UIAlertController alertControllerWithTitle:nil message:str1 preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [ _session startRunning ];
                }];
                [alertCon addAction:okAction];
                [self.navigationController presentViewController:alertCon animated:YES completion:nil];
                
            }else{
                GoodSDetailViewController * goodDetailVC = [[GoodSDetailViewController alloc]init];
                goodDetailVC.goodsDic = dic;
                [self.navigationController pushViewController:goodDetailVC animated:YES];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DLog(@"failure%@",error);
        }];
        
    }else{
        NSString *str1 = @"请扫描正确的商品二维码或条形码!";
        alertCon = [UIAlertController alertControllerWithTitle:nil message:str1 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ _session startRunning ];
            
        }];
        [alertCon addAction:okAction];
        [self.navigationController presentViewController:alertCon animated:YES completion:nil];
    }
    
    //    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)getOnlyNum:(NSString *)str  {
    NSString *onlyNumStr = [str stringByReplacingOccurrencesOfString:@"[^0-9&]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [str length])];      NSArray *numArr = [onlyNumStr componentsSeparatedByString:@"&"];      return numArr;
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
-(NSString *)md5:(NSString *)str {
    
    const char* cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSInteger i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    
    return ret;
}
-(NSDictionary *)md5DicWith:(NSDictionary *)dic
{
    NSString *str = @"";
    NSArray * arr =[dic allKeys];
    NSArray *newArray = [arr sortedArrayUsingSelector:@selector(compare:)];
    //    DLog(@"new array = %@",newArray);
    
    for (int i = 0 ; i< newArray.count+1 ;i++) {
        
        if (i == arr.count) {
            str = [NSString stringWithFormat:@"%@&key=%@",str,appsecret];
        }
        else
        {
            if (str.length >0) {
                
                str = [NSString stringWithFormat:@"%@&%@=%@",str,newArray[i],[dic valueForKey:newArray[i]]];
                
            }
            else
                str = [NSString stringWithFormat:@"%@=%@",newArray[i],[dic valueForKey:newArray[i]]];
            
        }
    }
    
    //    DLog(@"str = %@",str);
    
    NSString *tokenStr = [self md5:str];
    
    NSMutableDictionary * Ndic = [NSMutableDictionary dictionaryWithObject:tokenStr forKey:@"token"];
    [Ndic addEntriesFromDictionary:dic];
    return Ndic;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
CG_INLINE CGRect
CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height){
    
    CGRect rect;
    //如果使用此结构体，那么对传递过来的参数，在内部做了比例系数的改变
    rect.origin.x = x;//原点的X坐标的改变
    rect.origin.y = y-64;//原点的Y坐标的改变
    rect.size.width = width;//宽的改变
    rect.size.height = height;//高的改变
    return rect;
}@end