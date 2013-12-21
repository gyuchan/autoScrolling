//
//  Root2ViewController.m
//  autoScrolling
//
//  Created by jeongyuchan on 2013. 12. 19..
//  Copyright (c) 2013년 jeongyuchan. All rights reserved.
//

#import "Root2ViewController.h"

@interface Root2ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *customNavigationBar;
@end

@implementation Root2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //navigationBar Setting
    [self.navigationController setNavigationBarHidden:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)[_customNavigationBar setFrame:CGRectMake(_customNavigationBar.frame.origin.x, _customNavigationBar.frame.origin.y, _customNavigationBar.frame.size.width, _customNavigationBar.frame.size.height+20)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
        [_customNavigationBar setBackgroundColor:[UIColor whiteColor]];
        [_customNavigationBar setTintColor:[UIColor whiteColor]];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"entityCell";
    
    UITableViewCell *entityCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    
    if (entityCell == nil) {
        entityCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        //        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 44)];
        //        label.backgroundColor = [UIColor clearColor];
        //        label.tag = 1;
        //        [entityCell addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 44)];
        label2.backgroundColor = [UIColor clearColor];
        label2.tag=2;
        [entityCell addSubview:label2];
    }
    //    UILabel *label = (UILabel*)[entityCell viewWithTag:1];
    UILabel *label2 = (UILabel*)[entityCell viewWithTag:2];
    switch (indexPath.row){
        case 0:
            //            label.text = @"Collection";
            label2.text = @"테스트";
            break;
    }
    
    [entityCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [entityCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return entityCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"contentViewPage" sender:self];
}

@end
