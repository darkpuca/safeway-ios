//
//  DetailViewController.h
//  safeway
//
//  Created by darkpuca on 2014. 3. 15..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
