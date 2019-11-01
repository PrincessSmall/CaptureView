//
//  ViewController.m
//  CapturePictureDemo
//
//  Created by LiMin on 2019/10/24.
//  Copyright © 2019 LiMin. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UITableView *listTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUIFrame];
    // Do any additional setup after loading the view.
}
- (void)clickCaptureButtonAction {
    UIImage *image = [self captureCurrentView];
    [self saveToLibraryWithImage:image];
}

/**
 截取快照
 @return UIImage 截取的快照
 */
- (UIImage *)captureCurrentView {
    UIImage *image = nil;
    
    //1. 给出画布大小
    CGSize contentSize = CGSizeMake(self.listTableView.contentSize.width, self.listTableView.contentSize.height+70);
    
    //2. 开启画布
    UIGraphicsBeginImageContextWithOptions(contentSize, YES, 0.0);
    
    CGPoint saveContentOfset = self.listTableView.contentOffset;
    CGRect saveFrame = self.listTableView.frame;
    CGRect saveViewframe = self.view.frame;
    
    //将TableView的偏移量设置为(0,0)
    self.listTableView.contentOffset = CGPointZero;
    self.listTableView.frame = CGRectMake(0, saveFrame.origin.y, self.listTableView.contentSize.width, self.listTableView.contentSize.height);
    self.view.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);//这句话很重要不能缺少，这里view的frame决定了截取出来的快照的frame
    
    //3. 在当前上下文中渲染出tableView
    [self.listTableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    //4. 截取上下文生成Image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //恢复tableView的偏移量
    [self.listTableView setContentOffset:saveContentOfset];
    self.listTableView.frame = saveFrame;
    self.view.frame = saveViewframe;
    
    //5. 结束画布
    UIGraphicsEndImageContext();

    if (image != nil) {
        return image;
    }else {
        return nil;
    }
}

/**
 写入相册
 @param image 需要存入相册的image
 */
- (void)saveToLibraryWithImage:(UIImage *)image {
    //这里的图片可以是本地图片也可以是网络的图片，网络的需要通过SD转化
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已存入手机相册" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const reusIdetifier = @"reuseId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusIdetifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusIdetifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"这是第%ld行cell",indexPath.row];
    return cell;
}


#pragma mark --------layoutUIFrame

- (void)layoutUIFrame {
    [self.view addSubview:self.listTableView];
    [self.view addSubview:self.captureButton];
    
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.captureButton.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
    }];
    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
    }];
}


#pragma mark --------lazy

- (UIButton *)captureButton {
    if (!_captureButton) {
        _captureButton = [[UIButton alloc]init];
        _captureButton.backgroundColor = [UIColor redColor];
        [_captureButton setTitle:@"截屏" forState:UIControlStateNormal];
        [_captureButton addTarget:self action:@selector(clickCaptureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _captureButton;
}
- (UITableView *)listTableView {
    if (!_listTableView) {
        _listTableView = [[UITableView alloc]init];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.estimatedRowHeight = 0;
        _listTableView.estimatedSectionFooterHeight = 0;
        _listTableView.estimatedSectionHeaderHeight = 0;
    }
    return _listTableView;
}
@end
