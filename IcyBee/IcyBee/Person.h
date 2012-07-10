//
//  Person.h
//  IcyBee
//
//  Created by Michelle Six on 7/9/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Person : UITableViewCell
  @property (nonatomic, strong) IBOutlet UILabel *nickname; 
  @property (nonatomic, strong) IBOutlet UILabel *idle; 
  @property (nonatomic, strong) IBOutlet UILabel *signon; 
  @property (nonatomic, strong) IBOutlet UILabel *account;
@end
