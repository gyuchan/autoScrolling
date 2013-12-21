//
//  ViewController.h
//  autoScrolling
//
//  Created by jeongyuchan on 2013. 12. 10..
//  Copyright (c) 2013년 jeongyuchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "AudioPlayer.h"

@interface ViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate,UIGestureRecognizerDelegate,AudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
