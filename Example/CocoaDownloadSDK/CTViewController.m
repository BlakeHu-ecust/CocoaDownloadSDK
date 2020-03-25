//
//  CTViewController.m
//  CocoaDownloadSDK
//
//  Created by 695081933@qq.com on 03/25/2020.
//  Copyright (c) 2020 695081933@qq.com. All rights reserved.
//

#import "CTViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <CocoaDownloadSDK/CTTest.h>

@interface CTViewController ()

@end

@implementation CTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[[CTTest alloc]init] sayHello];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
