//
//  PrivateMessage.m
//  IcyBee
//
//  Created by Michelle Six on 7/10/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "PrivateMessage.h"

@implementation PrivateMessage

@synthesize nickname, message, timestamp;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {

  }
  
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
