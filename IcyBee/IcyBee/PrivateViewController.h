//
//  PrivateViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate> {
  NSMutableArray *privateArray;
}

@property (nonatomic, strong) IBOutlet  UITableView     *privateTableView;
@property (nonatomic, retain)           NSMutableArray  *privateArray;  

- (void) updateView;
- (void) fetchRecords;
@end
