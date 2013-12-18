//
//  ViewController.m
//  autoScrolling
//
//  Created by jeongyuchan on 2013. 12. 10..
//  Copyright (c) 2013년 jeongyuchan. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+UIScrollViewScrollingDirection.h"

#define MENUOPENDURATION 0.3
#define MENUCLOSEDURATION 0.2

@interface ViewController (){
    BOOL autoScroll;
    BOOL naviShow;
    CGSize webtoonSize;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet UIToolbar *customToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolbarButton1;
@property (nonatomic, retain) IBOutlet UINavigationBar *customNavigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *customBarButtonItem;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    naviShow = true;
    autoScroll = false;
    
    //Navigation Bar Custom Button
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 124, 44)];
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setFrame:CGRectMake(4, 4, 36, 36)];
    [button1 setImage:[UIImage imageNamed:@"musicOff.png"] forState:UIControlStateNormal];
    [button1 addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button1];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setFrame:CGRectMake(44, 0, 80, 44)];
    [button2 setTitle:@"모션스크롤" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(autoScrolling) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button2];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:container];
    
    [_customBarButtonItem setRightBarButtonItem:item];
    [_customNavigationBar setTintColor:[UIColor redColor]];
    [_customNavigationBar setFrame:CGRectMake(_customNavigationBar.frame.origin.x, _customNavigationBar.frame.origin.y, _customNavigationBar.frame.size.width, _customNavigationBar.frame.size.height+20)];

    //navigationBar Setting
    [self.navigationController setNavigationBarHidden:YES];
    
    
    //toolbar Button
//    [_toolbarButton1 setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
//                                   forState:UIControlStateNormal];
    [_toolbarButton1 setAction:@selector(toolbarButton1Action)];

    
    //TapGesture event 설정하기
    UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSingleTap:)];
    [self.scrollView addGestureRecognizer:singleFingerTap];
    
    
    //auto scrolling 초기화
    _motionManager = [[CMMotionManager alloc] init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    UIImage *webtoonImage = [UIImage imageNamed:@"webtoon_sample.jpg"];
    UIImageView *_webToonImageView = [[UIImageView alloc]initWithImage:webtoonImage];
    
    //웹툰의 원본 이미지사이즈 크기를 device에 width에 맞춰 리사이징값 구하기.
    webtoonSize = [self cgrectWithImage:webtoonImage scaledToWidth:screenWidth];
    [_webToonImageView setFrame:CGRectMake(0.f, 0.f, screenWidth,webtoonSize.height)];
    [_webToonImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    //웹툰의 원본 이미지사이즈 크기를 device에 width에 맞춰 리사이징값 구하기.
    [_scrollView setContentSize:webtoonSize];
    [_scrollView addSubview:_webToonImageView];
    [_scrollView setDecelerationRate:0.01];
    [_scrollView setScrollEnabled:YES];
    [_scrollView setDelegate:self];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    naviShow = !naviShow;
    [self showNavigationBar:naviShow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(CGSize)cgrectWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = (sourceImage.size.height * scaleFactor);
    float newWidth = (oldWidth * scaleFactor);

    return CGSizeMake(newWidth, newHeight);
}


#pragma mark - motionScrolling

-(void)autoScrolling{
    autoScroll = (autoScroll == true) ? false : true;
    if(autoScroll){
        [self showNavigationBar:NO];
        _motionManager.accelerometerUpdateInterval = .2;
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    }else{
        [self showNavigationBar:YES];
        [_motionManager stopAccelerometerUpdates];
    }
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
//    NSLog(@" %.2fg",acceleration.y);
//    NSLog(@" %.2f",_scrollView.contentOffset.y);
    NSLog(@"%f",_scrollView.contentOffset.y);
    float gravity = acceleration.y+(35./90.);
    if(gravity <= -0.4) gravity = -0.4;
    
    if (_scrollView.contentOffset.y >= webtoonSize.height - ([[UIScreen mainScreen] bounds].size.height+ (-1 * gravity * 95))){
        [_motionManager stopAccelerometerUpdates];
        autoScroll = false;
    }
    if (_scrollView.contentOffset.y < -_customNavigationBar.frame.size.height-[[UIApplication sharedApplication]statusBarFrame].size.height){
        [_motionManager stopAccelerometerUpdates];
        autoScroll = false;
    }
    
    CGPoint scrollPoint = CGPointMake(_scrollView.frame.origin.x, _scrollView.contentOffset.y + (-1 * gravity * 95));
//    [_scrollView setContentOffset:scrollPoint animated:YES];
    [self scrollToPage:scrollPoint];
}

- (void)scrollToPage:(CGPoint)scrollPoint
{
    CGPoint offset = scrollPoint;
    [UIView animateWithDuration:.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [_scrollView setContentOffset:offset animated:NO];
                     } completion:nil];
}

- (void)showNavigationBar:(BOOL)show
{
//    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    if (show == YES && _customNavigationBar.hidden == YES) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
        
        // Move the frame out of sight
        CGRect frame = _customNavigationBar.frame;
        frame.origin.y = -frame.size.height;
        _customNavigationBar.frame = frame;

        CGRect toolbarFrame = self.customToolbar.frame;
//        toolbarFrame.origin.y = [[UIScreen mainScreen]applicationFrame].size.height+toolbarFrame.size.height;
        self.customToolbar.frame = toolbarFrame;

        
        // Display it nicely
        _customNavigationBar.hidden = NO;
        frame.origin.y = 0.0;
        

        self.customToolbar.hidden = NO;
        toolbarFrame.origin.y = toolbarFrame.origin.y-toolbarFrame.size.height;
        
        [UIView animateWithDuration:MENUOPENDURATION
                         animations:^(void) {
                            _customNavigationBar.frame = frame;
                             self.customToolbar.frame = toolbarFrame;
                         }];
    }
    else if (show == NO && _customNavigationBar.hidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
        
        CGRect frame = _customNavigationBar.frame;
        CGRect toolbarFrame = self.customToolbar.frame;
        
        // Display it nicely
        frame.origin.y = -frame.size.height;
        [self.view bringSubviewToFront:_customNavigationBar];
        
        toolbarFrame.origin.y = toolbarFrame.origin.y+toolbarFrame.size.height;
        
        
        
        [UIView animateWithDuration:MENUCLOSEDURATION
                         animations:^(void) {
                             _customNavigationBar.frame = frame;
                             self.customToolbar.frame = toolbarFrame;
                         }
                         completion:^(BOOL finished) {
                             _customNavigationBar.hidden = YES;
                             self.customToolbar.hidden = YES;
                             
                         }
         ];
    }
}


#pragma mark - scrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    switch (scrollView.scrollDirectionY) {
        case ScrollDirectionDown:
            if(!naviShow){
                naviShow = true;
                [self showNavigationBar:naviShow];
            }
            
            break;
        case ScrollDirectionUp:
            if(naviShow){
                naviShow = false;
                [self showNavigationBar:naviShow];
            }
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if(naviShow){
        naviShow = false;
        [self showNavigationBar:naviShow];
    }
}

#pragma mark - toolbarButtonAction

- (void)toolbarButton1Action{
    NSLog(@"1");
}
@end
