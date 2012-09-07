//
//  ChannelMessage.m
//  IcyBee
//
//  Created by Michelle Six on 7/26/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "ChannelMessage.h"
#import "IcbConnection.h"

@implementation ChannelMessage

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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
  if (navigationType == UIWebViewNavigationTypeOther)
    return YES;
  return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  CGRect frame = [webView frame];
  
  frame.size.height =1;
  [webView setFrame: frame];
  
  frame.size = [webView sizeThatFits:CGSizeZero];
  frame.size.height += 1;
  [webView setFrame: frame];
  
  CGRect cellFrame = [self frame];
  cellFrame.size.height = frame.size.height + 1;
  [self setFrame: cellFrame];
  
  NSError *error;
  ChatMessage *message = (ChatMessage *)[[[IcbConnection sharedInstance] managedObjectContext] existingObjectWithID:[self objectID] error:&error];
  [message setHeight:frame.size.height + 1];
  
  [[[IcbConnection sharedInstance] front] performSelector:@selector(reJiggerCells)];
}

@end
