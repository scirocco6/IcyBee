//
//  Person.m
//  IcyBee
//
//  Created by Michelle Six on 7/9/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize nickname, idle, signon, account, joinButton, messageButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
