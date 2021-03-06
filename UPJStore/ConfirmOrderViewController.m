//
//  ConfirmOrderViewController.m
//  UPJStore
//
//  Created by upj on 16/4/12.
//  Copyright © 2016年 UPJApp. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "ComfirmOrderTableViewCell.h"
#import "OrderAddressTableViewCell.h"
#import "UIViewController+CG.h"
#import "CommodModel.h"
#import "WXApi.h"
#import "PrefixHeader.pch"
#import "PaySuccessViewController.h"
#import "MyAddressViewController.h"
#import "GoodSDetailViewController.h"
#import "OrderViewController.h"
#import "ChooseCouponViewController.h"


#import "SelectPayMethohViewController.h"


@interface ConfirmOrderViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    NSString * addressStr,*areaStr,*aidStr,*mobileStr,*provinceStr,*nameStr,*cityStr;
    NSString * orderID;
    UITextView *noteFieldView;
    NSDictionary * couponDic;
    UIView * noteView;
    UIImageView * imageView;
    UILabel *label;
}
@property (nonatomic,strong) UITableView * goodsTableView;
@property (nonatomic,strong) NSMutableArray * modelArr;
@property (nonatomic,strong) UILabel * PriceLabel;
@property (nonatomic,strong) NSDictionary *modelDic;
@property (nonatomic,strong) NSDictionary * addsDic;
@property (nonatomic,strong) UILabel * noLabel;
@property (nonatomic,strong) UIView * noView;
@property (nonatomic,strong) UILabel * couponLabel;
@end

@implementation ConfirmOrderViewController
-(NSMutableArray *)modelArr{
    if (!_modelArr) {
        self.modelArr = [NSMutableArray array];
    }
    return _modelArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    couponDic = @{@"reduce":@"0",@"coupon_code":@"0",@"couponid":@"0",@"title":@"0"};
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"确认订单";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backArrow"] style:UIBarButtonItemStyleDone target:self action:@selector(pop)];
    self.navigationItem.leftBarButtonItem.tintColor =  [UIColor colorWithRed:204.0/255 green:34.0/255 blue:69.0/255 alpha:1];
    
    self.isShowTab = YES;
    
    [self hideTabBarWithTabState:self.isShowTab];
    
    [self postOrderWtihDic:_dic];
    
    // Do any additional setup after loading the view.
}
-(void)pop{
    self.isShowTab = NO;
    [self showTabBarWithTabState:self.isShowTab];
    [self.navigationController popViewControllerAnimated:YES];
}
-(UITableView *)goodsTableView
{
    if (!_goodsTableView ) {
        _goodsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height-CGFloatMakeY(60)) style:UITableViewStylePlain];
        _goodsTableView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
        _goodsTableView.delegate = self;
        _goodsTableView.dataSource = self;
        [self.view addSubview:_goodsTableView];
    }
    return _goodsTableView;
}

-(void)postOrderWtihDic:(NSDictionary *)dic{
    
#pragma dic MD5
    NSDictionary * Ndic = [self md5DicWith:dic];
    
    AFHTTPSessionManager * manager = [self sharedManager];;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

    [manager POST:kOrder parameters:Ndic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     //   DLog(@"%@",responseObject);
        _modelDic = responseObject;
        NSArray *arr = responseObject[@"goods_list"];
        for (NSDictionary *dic in arr) {
            CommodModel *model = [[CommodModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [self.modelArr addObject:model];
        }
        
        
        [self endView];
        [self.goodsTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
    }];
    
}
-(void)endView
{
    UIView * endView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-CGFloatMakeY(60), self.view.bounds.size.width, CGFloatMakeY(60) )];
    endView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:endView];
    
    UILabel *totalLabel = [[UILabel alloc]initWithFrame:CGRectMake1(10, 10, 50, 40)];
    totalLabel.font =[UIFont systemFontOfSize:CGFloatMakeY(15)];
    totalLabel.text = @"合计：";
    [endView addSubview:totalLabel];
    
    _PriceLabel = [[UILabel alloc]initWithFrame:CGRectMake1(60, 10, 100, 40)];
    _PriceLabel.font =[UIFont systemFontOfSize:CGFloatMakeY(15)];
    _PriceLabel.text = [NSString stringWithFormat:@"¥%@元",_modelDic[@"total_price"]];
    _PriceLabel.textColor = [UIColor colorFromHexRGB:@"cc2245"];
    [endView addSubview:_PriceLabel];
    
    UIButton * makeSureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    makeSureBtn.frame =CGRectMake1(414-160, 10, 150, 40);
    [makeSureBtn setTitle:@"提交订单" forState:UIControlStateNormal];
    makeSureBtn.layer.cornerRadius = 5;
    [makeSureBtn addTarget:self action:@selector(postData:) forControlEvents:UIControlEventTouchUpInside];
    makeSureBtn.backgroundColor = [UIColor colorFromHexRGB:@"cc2245"];
    [endView addSubview:makeSureBtn];
    
}
-(void)postData:(UIButton *)btn
{
    
    if (aidStr == nil)
    {
        MyAddressViewController * addVC = [[MyAddressViewController alloc]init];
        
        addVC.isFromDetail =YES;
        //    self.navigationController.navigationBar.translucent = NO;
        
        [self.navigationController pushViewController:addVC animated:YES];
        
        
    }
    else
    {
        [self setMBHUD];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handlePayResult:) name:WX_PAY_RESULT object:nil];
        
        NSDictionary * dic =@{@"appkey":APPkey,@"mid":[self returnMid],@"aid":aidStr,@"coupon_code":couponDic[@"coupon_code"],@"couponid":couponDic[@"couponid"]};
#pragma dic MD5
        NSDictionary * Ndic = [self md5DicWith:dic];
        
        AFHTTPSessionManager * manager = [self sharedManager];;
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

        
        
        [manager POST:kSubmit parameters:Ndic progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         //   DLog(@"%@",responseObject);
            NSDictionary * dic = responseObject;
            orderID = dic[@"order_id"];
            SelectPayMethohViewController *selectVC = [[SelectPayMethohViewController alloc]init];
            selectVC.orderID = orderID;
            selectVC.totalPrice = [NSString stringWithFormat:@"¥%.2f元", [_modelDic[@"total_price"] floatValue]-[couponDic[@"reduce"] floatValue]+[_modelDic[@"dispatch"] floatValue]];
            [self.navigationController pushViewController:selectVC animated:YES];
            [self.loadingHud hideAnimated:YES];
            self.loadingHud = nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            DLog(@"error : %@",error);
            
        }];
    }
}


- (void)handlePayResult:(NSNotification *)noti{
    DLog(@"Notifiction Object : %@",noti.object);
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"支付结果" message:[NSString stringWithFormat:@"%@",noti.object] preferredStyle:UIAlertControllerStyleActionSheet];
    if ([noti.object isEqualToString:@"成功"]) {
        PaySuccessViewController *success = [[PaySuccessViewController alloc]init];
        success.orderId = orderID;
        [self.navigationController pushViewController:success animated:YES];
        
        //添加按钮
        /*
         [alert addAction:[UIAlertAction actionWithTitle:@"跳转到支付成功页面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         
         
         }]];
         [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
         */
    }
    else
    {
        //添加按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"重新支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self postData:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    //上边添加了监听，这里记得移除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"weixin_pay_result" object:nil];}

#pragma mark — tableView设置(自定义一个地图tableviewCell)
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 1;
    }else if (section == 2){
        return 1;
    }else if (section == 3){
        return 1;
    }else{
        return _modelArr.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ComfirmOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell"];
        if (cell == nil) {
            cell = [[ComfirmOrderTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseCell"];
        }
        CommodModel *model = _modelArr[indexPath.row];
        [cell.productImg sd_setImageWithURL:[NSURL URLWithString:model.thumb]placeholderImage:[UIImage imageNamed:@"lbtP"]];
        cell.titleLabel.text = model.title;
        cell.totalPrice.text = [NSString stringWithFormat:@"￥%@",model.marketprice];
        cell.total.text = [NSString stringWithFormat:@"×%@",model.total];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    if(indexPath.section == 1){
        
        OrderAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"systemCell"];
        if (cell == nil) {
            cell = [[OrderAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"systemCell"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [[UIColor lightGrayColor]CGColor];
        cell.nameLab.text = nameStr;
        cell.mobileLab.text =mobileStr;
        cell.addressLab.text = [NSString stringWithFormat:@"%@%@%@%@",provinceStr,cityStr,areaStr,addressStr];
        
        if (imageView==nil) {
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake1(10, 40, 20, 20)];
            imageView.image = [UIImage imageNamed:@"addImg"];
            [cell.contentView addSubview:imageView];
            UIImageView * arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake1(414-30, 40, 20, 20)];
            arrowImageView.image = [UIImage imageNamed:@"箭头"];
            [cell.contentView addSubview:arrowImageView];
            
        }
        
        _noView =[[UIView alloc]initWithFrame:CGRectMake1(30, 20, 414-60, 30)];
        [cell.contentView addSubview:_noView];
        _noView.backgroundColor = [UIColor whiteColor];
        _noLabel = [[UILabel alloc]initWithFrame:CGRectMake1(0, 0, 414-60,60)];
        _noLabel.backgroundColor = [UIColor whiteColor];
        [_noView addSubview:_noLabel];
        _noLabel.text = @"亲，你还没有收货地址喔，点击这里添加。";
        _noLabel.numberOfLines = 0;
        
        if (nameStr == nil) {
            _noView.hidden = NO;
        }else
        {
            _noView.hidden = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
            
        }
        
        cell.contentView.layer.borderWidth = 1;
        cell.contentView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
        
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake1(20, 10, 30, 30)];
        imageView1.image = [UIImage imageNamed:@"addCoupon"];
        [cell addSubview:imageView1];
        
       // cell.imageView.image = [UIImage imageNamed:@"addCoupon"];
        
        if (_couponLabel == nil) {
            _couponLabel = [[UILabel alloc]initWithFrame:CGRectMake1(60, 10, 414-100, 30)];
            [cell.contentView addSubview:_couponLabel];
            _couponLabel.text = @"兑换优惠券";
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"remarkCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"remarkCell"];
            
        }
        
        cell.contentView.layer.borderWidth = 1;
        cell.contentView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
        
        if (noteView == nil) {
            
            noteView = [[UIView alloc]initWithFrame:CGRectMake1(0, 0, 414, 100)];
            noteView.backgroundColor =[UIColor whiteColor];
            [cell.contentView addSubview:noteView];
            
            UILabel *headLabel = [[UILabel alloc]initWithFrame:CGRectMake1(10, 5, 394, 20)];
            headLabel.text = @"备注信息：";
            headLabel.font = [UIFont systemFontOfSize:CGFloatMakeY(15)];
            [noteView addSubview:headLabel];
            
            noteFieldView = [[UITextView alloc]initWithFrame:CGRectMake1(10, 25, 394, 175)];
            noteFieldView.delegate = self;
            noteFieldView.returnKeyType = UIReturnKeyDone;
            
            noteFieldView.font = [UIFont systemFontOfSize:CGFloatMakeY(15)];
            [noteView addSubview:noteFieldView];
            
            label = [[UILabel alloc]initWithFrame:CGRectMake1(16, 30, 394, 20)];
            label.text = @"亲，还有什么要交代的话，告诉我们吧！";
            label.font = [UIFont systemFontOfSize:CGFloatMakeY(15)];
            UIColor *holdcolor = [UIColor colorWithWhite:0.75 alpha:1];
            label.textColor = holdcolor;
            [noteView addSubview:label];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
    return nil;
}

-(void)textViewDidChange:(UITextView *)textView
{    label.hidden =YES;
    if (noteFieldView.text.length ==0) {
        label.hidden = NO;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return CGFloatMakeY(30);
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, CGFloatMakeY(30))];
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width, CGFloatMakeY(30))];
    headerLabel.font = [UIFont systemFontOfSize:CGFloatMakeY(14)];
    [headerView addSubview:headerLabel];
    
    if (section == 0) {
        headerLabel.text = @"订单商品";
    }else if(section == 1){
        headerLabel.text = @"收货信息";
    }else if(section == 2){
        headerLabel.text = @"优惠券";
    }else if (section == 3){
        headerLabel.text = @"备注";
    }
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3) {
        return CGFloatMakeY(200);
    }else if(indexPath.section == 2)
    {
        return CGFloatMakeY(50);
    }else
    {
        return CGFloatMakeY(100);
    }
}

// 去掉tabelView headerView的粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 30;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        MyAddressViewController * addVC = [[MyAddressViewController alloc]init];
        
        addVC.isFromDetail =YES;
        //    self.navigationController.navigationBar.translucent = NO;
        
        [self.navigationController pushViewController:addVC animated:YES];
    }
    if (indexPath.section == 2) {
        ChooseCouponViewController * chooseVC = [[ChooseCouponViewController alloc]init];
        chooseVC.dic = @{@"appkey":APPkey,@"mid":[self returnMid],@"amount":_modelDic[@"total_price"]};
        [self.navigationController pushViewController:chooseVC animated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{   [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    if (_addsDic == nil) {
        
        for (NSDictionary * dic in [self returnAddress]) {
            if ([dic[@"isdefault"]isEqualToString:@"1"])
            {
                _addsDic = [NSDictionary dictionaryWithDictionary:dic];
            }
        }
        
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    [self addsInfoWithDic:_addsDic];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduce:) name:@"reduce" object:nil];
}

-(void)reduce:(NSNotification *)reduce
{
    couponDic = reduce.userInfo;
    _PriceLabel.text = [NSString stringWithFormat:@"¥%.2f元", [_modelDic[@"total_price"] floatValue]-[couponDic[@"reduce"] floatValue]];
    
    _couponLabel.text = couponDic[@"title"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reduce" object:nil];
}
-(void)addsInfoWithDic:(NSDictionary *)dic
{
    
    if (_addsDic == nil)
    {
        _noView.hidden = NO;
        aidStr = nil;
    }
    else
    {
        _noView.hidden =YES;
        addressStr  = dic[@"address"];
        areaStr = dic[@"area"];
        cityStr = dic[@"city"];
        aidStr = dic[@"id"];
        mobileStr = dic[@"mobile"];
        provinceStr = dic[@"province"];
        nameStr = dic[@"realname"];
        
        [_goodsTableView reloadData];
    }
    _addsDic = nil;
    
}

#pragma mark - 屏幕上弹
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //键盘高度216
    
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, -205.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
     [noteFieldView resignFirstResponder];
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
    return YES;
}

#pragma mark - UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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

@end