//
//  HomeDetailViewController.m
//  LightUp
//
//  Created by Forever.H on 15/9/26.
//  Copyright (c) 2015年 Atlas19. All rights reserved.
//

#import "HomeDetailViewController.h"
#import "API.h"
#import "User.h"
#import "Message.h"
#import <UIImageView+AFNetworking.h>
#import "SingleHomeDetailViewController.h"
#import "NetworkConstants.h"
@interface HomeDetailViewController ()
@property (nonatomic, strong) NSMutableArray *source;
@end

@implementation HomeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.HomeTableView.delegate = self;
    self.HomeTableView.dataSource = self;
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO; //必须要加上这句话，不然上面会有留白
    //设置导航条样式
    //默认的时白色半透明（有点灰的感觉），UIBarStyleBlack,UIBarStyleBlackTranslucent,UIBarStyleBlackOpaque都是黑色半透明，其实它们有的时不透明有的时透明有的时半透明，但不知为何无效果
    self.navigationController.navigationBar.barStyle=UIBarStyleDefault;
    //设置导航条背景颜色，也是半透明玻璃状的颜色效果
    //self.navigationController.navigationBar.backgroundColor=[UIColor orangeColor];
    //可以用self.navigationController.navigationBar.frame.size获得高宽，还有self.navigationController.navigationBar.frame.origin获得x和y
    //高44，宽375，如果是Retina屏幕，那么宽和高@2x即可分别是750和88
    //x是0很明显，y是20，其中上面20就是留给状态栏的高度
    //NSLog(@"%f",self.navigationController.navigationBar.frame.origin.y);
    
    //隐藏导航条，由此点击进入其他视图时导航条也会被隐藏，默认是NO
    //以下一个直接给navigationBarHidden赋值，一个调用方法，都是一样的，下面一个多了一个动画选项而已
    self.navigationController.navigationBarHidden=NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //给导航条增加背景图片，其中forBarMetrics有点类似于按钮的for state状态，即什么状态下显示
    //UIBarMetricsDefault-竖屏横屏都有，横屏导航条变宽，则自动repeat图片
    //UIBarMetricsCompact-竖屏没有，横屏有，相当于之前老iOS版本里地UIBarMetricsLandscapePhone
    //UIBarMetricsCompactPrompt和UIBarMetricsDefaultPrompt暂时不知道用处，官方解释是Applicable only in bars with the prompt property, such as UINavigationBar and UISearchBar，以后遇到时再细说
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"LightupTitle.png"] forBarMetrics:UIBarMetricsDefault];
    //如果图片太大会向上扩展侵占状态栏的位置，在状态栏下方显示
    //clipsToBounds就是把多余的图片裁剪掉
    //self.navigationController.navigationBar.clipsToBounds=YES;
    
    //设置导航标题
    //[self.navigationItem setTitle:@"主页"];
    
    //设置导航标题视图，就是这一块可以加载任意一种视图
    //视图的x和y无效，视图上下左右居中显示在标题的位置
    //UIView *textView1=[[UIView alloc]initWithFrame:CGRectMake(10, 10, 50, 30)];
    //textView1.backgroundColor=[UIColor whiteColor];
    //[self.navigationItem setTitleView:textView1];
    
    //设置导航条的左右按钮
    //先实例化创建一个UIBarButtonItem，然后把这个按钮赋值给self.navigationItem.leftBarButtonItem即可
    //初始化文字的按钮类型有UIBarButtonItemStylePlain和UIBarButtonItemStyleDone两种类型，区别貌似不大
    //UIBarButtonItem *barBtn1=[[UIBarButtonItem alloc]initWithTitle:@"左边" style:UIBarButtonItemStylePlain target:self action:@selector(changeColor)];
    //self.navigationItem.leftBarButtonItem=barBtn1;
    
    //我们还可以在左边和右边加不止一个按钮，,且可以添加任意视图，以右边为例
    //添加多个其实就是rightBarButtonItems属性，注意还有一个rightBarButtonItem，前者是赋予一个UIBarButtonItem对象数组，所以可以显示多个。后者被赋值一个UIBarButtonItem对象，所以只能显示一个
    //显示顺序，左边：按数组顺序从左向右；右边：按数组顺序从右向左
    //可以初始化成系统自带的一些barButton，比如UIBarButtonSystemItemCamera是摄像机，还有Done，Reply等等，会显示成一个icon图标
    //还可以initWithImage初始化成图片
    //还可以自定义，可以是任意一个UIView
    //UIBarButtonItem *barBtn2=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(UsersInfo)];
    //UIBarButtonItem *barBtn3=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Users.png"] style:UIBarButtonItemStylePlain target:self action:@selector(UsersInfo)];
    //UIView *view4=[[UIView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
    //view4.backgroundColor=[UIColor blackColor];
    //UIBarButtonItem *barBtn4=[[UIBarButtonItem alloc]initWithCustomView:view4];
    //NSArray *arr1=[[NSArray alloc]initWithObjects:barBtn3, nil];
    //self.navigationItem.rightBarButtonItems=arr1;
    
    
    self.CommentView.hidden = YES;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.source=[NSMutableArray array];
    UIAlertView *waitView=[[UIAlertView alloc] initWithTitle:@"请稍候" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [waitView show];
    if (self.district==nil || [self.district isEqualToString:@"-1"]) {
        [[API sharedAPI] allMessagesWithUserId:[User sharedInstance].userId andBLock:^(id responseObject, NSError *error) {
            [waitView dismissWithClickedButtonIndex:0 animated:YES];
            NSArray *array=(NSArray*)responseObject;
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"网络异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            else {
                for (NSDictionary *dic in array) {
                    Message *message=[[Message alloc] init];
                    message.userId=dic[@"User_id"];
                    message.userName=dic[@"User_name"];
                    message.headImageUrl=dic[@"User_headshot"];
                    message.percentage=dic[@"User_achievement" ];
                    message.messageId=dic[@"Message_id" ];
                    message.messageContent=dic[@"Message_content"];
                    message.messageImageUrl=dic[@"Message_image"];
                    message.regionId=dic[@"Region_id"];
                    message.messageTime=dic[@"Message_time"];
                    message.messageLike=dic[@"Message_like"];
                    message.state=dic[@"state"];
                    [self.source addObject:message];
                }
                [self.HomeTableView reloadData];
            }
        }];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.source count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell" forIndexPath:indexPath];
    Message *message=self.source[indexPath.row];
    cell.userNameLabel.text=message.userName;
    double percent=[message.percentage doubleValue];
    percent*=100;
    cell.percentLabel.text=[NSString stringWithFormat:@"%.2f%%",percent];
    cell.timeLabel.text=message.messageTime;
    [cell.userImage setImageWithURL:[NSURL URLWithString:[ApiBaseUrl stringByAppendingString:message.headImageUrl]]];
    [cell.messageImage setImageWithURL:[NSURL URLWithString:[ApiBaseUrl stringByAppendingString:message.messageImageUrl]]];
    cell.myDelegate=self;
    if ([message.state isEqualToString:@"1"]) {
        [cell.likeButton setBackgroundImage:[UIImage imageNamed:@"LikeOn"] forState:UIControlStateNormal];
    }
    return cell;
}

#pragma mark - CommentMethod
- (void)showCommentView:(NSInteger)cellRow
{
    self.CommentView.hidden = NO;
    self.currentRow = cellRow;
}

-(void)like:(id)sender{
    HomeTableViewCell *cell=sender;
    NSUInteger row=[self.HomeTableView indexPathForCell:cell].row;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[API sharedAPI] ];
    });

}

- (IBAction)SubmitCommentBtn:(id)sender {
    NSLog(@"Submmit!");
    UIAlertView *waitView=[[UIAlertView alloc] initWithTitle:@"请稍候" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
//    [waitView show];
//    [[API sharedAPI] :[User sharedInstance].userId andBLock:^(id responseObject, NSError *error) {
//        [waitView dismissWithClickedButtonIndex:0 animated:YES];
//        NSArray *array=(NSArray*)responseObject;
//        if (error) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"网络异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//        else {
//            for (NSDictionary *dic in array) {
//                Message *message=[[Message alloc] init];
//                message.userId=dic[@"User_id"];
//                message.userName=dic[@"User_name"];
//                message.headImageUrl=dic[@"User_headshot"];
//                message.percentage=dic[@"User_achievement" ];
//                message.messageId=dic[@"Message_id" ];
//                message.messageContent=dic[@"Message_content"];
//                message.messageImageUrl=dic[@"Message_image"];
//                message.regionId=dic[@"Region_id"];
//                message.messageTime=dic[@"Message_time"];
//                message.messageLike=dic[@"Message_like"];
//                message.state=dic[@"state"];
//                [self.source addObject:message];
//            }
//            [self.HomeTableView reloadData];
//        }
//    }];
}

- (IBAction)CancelCommentBtn:(id)sender {
    self.CommentTextView.text = NULL;
    self.CommentView.hidden = YES;
    NSLog(@"Cancel!");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SingleHomeDetailViewController *vc=segue.destinationViewController;
    if ([sender isKindOfClass:[UIButton class]]) {
        HomeTableViewCell *cell=(HomeTableViewCell*)[[sender superview] superview];
        vc.percent=cell.percentLabel.text;
        vc.user=cell.userImage.image;
        vc.content=cell.messageImage.image;
        vc.name=cell.userNameLabel.text;
        vc.locationDescription=cell.locationDescriptionLabel.text;
        vc.time=cell.timeLabel.text;
        int row=[self.HomeTableView indexPathForCell:cell].row;
        vc.message=self.source[row];
    }
}
@end
