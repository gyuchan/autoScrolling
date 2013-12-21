//
//  ViewController.m
//  autoScrolling
//
//  Created by jeongyuchan on 2013. 12. 10..
//  Copyright (c) 2013년 jeongyuchan. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+UIScrollViewScrollingDirection.h"
#import "MKNumberBadgeView.h"
#import "JDStatusBarNotification.h"

#define MENUOPENDURATION 0.3
#define MENUCLOSEDURATION 0.2

@interface ViewController (){
    BOOL autoScroll;
    BOOL naviShow;
    CGSize webtoonSize;
    
    BOOL audioPlayCheck;
    AudioPlayer* audioPlayer;
    NSURL* audioURL;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet UIToolbar *customToolbar;
@property (weak, nonatomic) IBOutlet UIButton *audioPlayButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *customNavigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *customBarButtonItem;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    naviShow = true;
    autoScroll = false;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    UIBarButtonItem *button1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"musicOff.png"] style:UIBarButtonItemStylePlain target:self action:nil];
//    UIBarButtonItem *button2 = [[UIBarButtonItem alloc]initWithTitle:@"모션스크롤" style:UIBarButtonItemStylePlain target:self action:@selector(autoScrolling)];
//    [_customBarButtonItem setRightBarButtonItems:@[button2,button1]];
    
    //Navigation Bar Custom Button
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 124, 44)];
    _audioPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_audioPlayButton setFrame:CGRectMake(4, 4, 36, 36)];
    [_audioPlayButton setImage:[UIImage imageNamed:@"musicOff.png"] forState:UIControlStateNormal];
    [_audioPlayButton addTarget:self action:@selector(playFromHTTPButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [_audioPlayButton setShowsTouchWhenHighlighted:YES];
    [container addSubview:_audioPlayButton];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(44, 0, 80, 44)];
    [button2 setTitle:@"모션스크롤" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button2 addTarget:self action:@selector(autoScrolling) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button2];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:container];
    
    [_customBarButtonItem setRightBarButtonItem:item];
    [_customNavigationBar setTintColor:[UIColor redColor]];
    
    UIView *navigationLeftContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIButton *leftButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton1 setFrame:CGRectMake(0, 4, 25, 25)];
    [leftButton1 setImage:[UIImage imageNamed:@"backbutton.png"] forState:UIControlStateNormal];
    [leftButton1 addTarget:self action:@selector(Back) forControlEvents:UIControlEventTouchUpInside];
    [navigationLeftContainer addSubview:leftButton1];
    UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithCustomView:leftButton1];
    [_customBarButtonItem setLeftBarButtonItem:item2];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
        [_customNavigationBar setBackgroundColor:[UIColor whiteColor]];
        [_customNavigationBar setTintColor:[UIColor whiteColor]];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)[_customNavigationBar setFrame:CGRectMake(_customNavigationBar.frame.origin.x, _customNavigationBar.frame.origin.y, _customNavigationBar.frame.size.width, _customNavigationBar.frame.size.height+20)];

    //navigationBar Setting
    [self.navigationController setNavigationBarHidden:YES];
    
    
    //toolbar Button
    UIButton *toolBarbutton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBarbutton1 setFrame:CGRectMake(4, 4, 36, 36)];
    [toolBarbutton1 setImage:[UIImage imageNamed:@"collection.png"] forState:UIControlStateNormal];
    [toolBarbutton1 addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *myButton1=[[UIBarButtonItem alloc] initWithCustomView:toolBarbutton1];

    MKNumberBadgeView *isnumber = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(10, -5, 38,20)];
    isnumber.value = 128;
    isnumber.fillColor = [UIColor purpleColor];
    isnumber.hideWhenZero = YES;
    isnumber.shadow = NO;
    isnumber.shine = NO;
    isnumber.alignment = NSTextAlignmentCenter;
    UIButton *toolBarbutton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBarbutton2 setFrame:CGRectMake(44, 4, 36, 36)];
    [toolBarbutton2 setImage:[UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];
    [toolBarbutton2 addTarget:self action:@selector(toolbarButton1Action) forControlEvents:UIControlEventTouchUpInside];
    [toolBarbutton2 addSubview: isnumber];
    UIBarButtonItem *myButton2=[[UIBarButtonItem alloc] initWithCustomView:toolBarbutton2];
    
    UIButton *toolBarbutton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBarbutton3 setFrame:CGRectMake(84, 4, 36, 36)];
    [toolBarbutton3 setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [toolBarbutton3 addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *myButton3=[[UIBarButtonItem alloc] initWithCustomView:toolBarbutton3];
    
    UIButton *toolBarbutton4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBarbutton4 setFrame:CGRectMake(124, 4, 36, 36)];
    [toolBarbutton4 setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [toolBarbutton4 addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *myButton4=[[UIBarButtonItem alloc] initWithCustomView:toolBarbutton4];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [_customToolbar setItems:[NSArray arrayWithObjects:flexibleSpace,myButton1,flexibleSpace,myButton2,flexibleSpace,myButton3,flexibleSpace,myButton4,flexibleSpace, nil] animated:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
        [_customToolbar setBackgroundColor:[UIColor whiteColor]];
        [_customToolbar setTintColor:[UIColor whiteColor]];
    }

    //TapGesture event 설정하기
    UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSingleTap:)];
    [self.scrollView addGestureRecognizer:singleFingerTap];
    
    
    //auto scrolling 초기화
    _motionManager = [[CMMotionManager alloc] init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenheight = screenRect.size.height;
    
    UIImage *webtoonImage = [UIImage imageNamed:@"webtoon_sample.jpg"];
    UIImageView *_webToonImageView = [[UIImageView alloc]initWithImage:webtoonImage];
    
    //웹툰의 원본 이미지사이즈 크기를 device에 width에 맞춰 리사이징값 구하기.
    webtoonSize = [self cgrectWithImage:webtoonImage scaledToWidth:screenWidth];
    [_webToonImageView setFrame:CGRectMake(0.f, 0.f, screenWidth,webtoonSize.height)];
    [_webToonImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    //웹툰의 원본 이미지사이즈 크기를 device에 width에 맞춰 리사이징값 구하기.
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0){
        if([[UIApplication sharedApplication]statusBarFrame].size.height>20){
            NSLog(@"%f",[[UIApplication sharedApplication]statusBarFrame].size.height);
            [_scrollView setFrame:CGRectMake(0.0, 0.0, screenWidth, screenheight-[[UIApplication sharedApplication]statusBarFrame].size.height+20)];
        }else{
           [_scrollView setFrame:CGRectMake(0.0, 0.0, screenWidth, screenheight)];
        }
    }
    else [_scrollView setFrame:CGRectMake(0.0, 0.0, screenWidth, screenheight-20)];
    [_scrollView setContentSize:webtoonSize];
    [_scrollView addSubview:_webToonImageView];
    [_scrollView setDecelerationRate:0.01];
    [_scrollView setScrollEnabled:YES];
    [_scrollView setDelegate:self];
    
    //audioPlayer 초기화하기
    audioPlayer = [[AudioPlayer alloc] init];
    audioPlayer.delegate = self;
    audioPlayer.
    audioPlayCheck = false;
    audioURL = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/125326092/stream?consumer_key=d61f17a08f86bfb1dea28539908bc9bf"];
//    audioURL = [NSURL URLWithString:@"https://blob.baas.io/ceffba5f-3514-11e2-a2c1-02003a570010/d31a99ec-3514-11e2-a2c1-02003a570010/files/2826373f-69ef-11e3-ae3e-06ebb80000ba"];
    
    
    //StatusBarNotification 초기화하기
    [JDStatusBarNotification addStyleNamed:@"style1"
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       style.barColor = [UIColor darkGrayColor];
                                       style.textColor = [UIColor whiteColor];
                                       style.animationType = JDStatusBarAnimationTypeMove;
                                       style.progressBarColor = [UIColor colorWithRed:0.986 green:0.062 blue:0.598 alpha:1.000];
                                       style.progressBarHeight = 3.0;
                                       return style;
                                   }];
    _progress = 0.0;
    
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
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)[[UIApplication sharedApplication] setStatusBarHidden:NO
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
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)[[UIApplication sharedApplication] setStatusBarHidden:YES
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

- (void)Back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - audioPlayer
-(void) playFromHTTPButtonTouched
{
    if(!audioPlayCheck){
        //startPlay
        audioPlayCheck = true;
        [audioPlayer setDataSource:[audioPlayer dataSourceFromURL:audioURL] withQueueItemId:audioURL];
        [_audioPlayButton setImage:[UIImage imageNamed:@"musicOn.png"] forState:UIControlStateNormal];
        [JDStatusBarNotification showWithStatus:@"배경음악 재생중입니다..." styleName:@"style1"];
    }else{
        if (audioPlayer.state == AudioPlayerStatePaused){
            [_audioPlayButton setImage:[UIImage imageNamed:@"musicOn.png"] forState:UIControlStateNormal];
            [audioPlayer resume];
            [JDStatusBarNotification showWithStatus:@"배경음악 재생중입니다..." styleName:@"style1"];
        }
        else {
            [_audioPlayButton setImage:[UIImage imageNamed:@"musicOff.png"] forState:UIControlStateNormal];
            [audioPlayer pause];
            [JDStatusBarNotification dismiss];
        }
    }
    [self progressSetting];
}

- (void)progressSetting
{
    NSLog(@"1_progress : %f",_progress);
    
    if (!audioPlayer || audioPlayer.state == AudioPlayerStatePaused)
	{
        return;
	}
    
    _progress = audioPlayer.progress/audioPlayer.duration;
    
    NSLog(@"2_progress : %f",_progress);

    
    [JDStatusBarNotification showProgress:_progress];
    [self.timer invalidate];
    self.timer = nil;
    if (_progress) {
        CGFloat step = 0.1;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:step target:self
                                                    selector:@selector(progressSetting)
                                                    userInfo:nil repeats:NO];
    } else {
        [self performSelector:@selector(hideProgress)
                   withObject:nil afterDelay:0.5];
    }
}

- (void)hideProgress;
{
    [JDStatusBarNotification showProgress:0.0];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer stateChanged:(AudioPlayerState)state
{
    NSLog(@"이벤트1");
    [self progressSetting];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode
{
	NSLog(@"이벤트2");
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
	NSLog(@"이벤트3");
    [self progressSetting];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
	NSLog(@"이벤트4");
}

-(void) audioPlayer:(AudioPlayer*)_audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    NSLog(@"이벤트5");
//    [audioPlayer seekToTime:0.000000];
//    [_audioPlayButton setImage:[UIImage imageNamed:@"musicOff.png"] forState:UIControlStateNormal];
//	[_audioPlayer pause];
//    [JDStatusBarNotification dismiss];
//    [_audioPlayer setDataSource:[audioPlayer dataSourceFromURL:audioURL] withQueueItemId:audioURL];
    [self progressSetting];
}



@end
