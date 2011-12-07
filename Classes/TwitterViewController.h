//
//  TwitterViewController.h
//  Cirkle
//
//  Created by Wenjing Chu on 8/26/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>  
#import "SA_OAuthTwitterController.h"  

@class SA_OAuthTwitterEngine;  

@interface TwitterViewController : UIViewController <SA_OAuthTwitterControllerDelegate>   {
    SA_OAuthTwitterEngine    *_engine; 
}

@end
