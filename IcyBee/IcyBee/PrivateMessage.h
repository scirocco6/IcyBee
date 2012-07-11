//
//  PrivateMessage.h
//  IcyBee
//
//  Created by Michelle Six on 7/10/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateMessage : UITableViewCell
  @property (nonatomic, strong) IBOutlet UILabel    *nickname; 
  @property (nonatomic, strong) IBOutlet UIWebView  *message; 
  @property (nonatomic, strong) IBOutlet UILabel    *timestamp; 
@end
