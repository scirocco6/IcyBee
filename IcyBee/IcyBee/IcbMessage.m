//
//  UrlMessage.m
//  IcyBee
//
//  Created by Michelle Six on 10/3/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "IcbMessage.h"
#import "IcbConnection.h"
#import "BrowserViewController.h"

@implementation IcbMessage
@synthesize icbTableController;

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    // Initialization code
  }
  return(self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  if(![self needsSize])
    return;
  
  CGRect frame = [webView frame];
  
  frame.size.height = 1;
  [webView setFrame: frame];
  
  frame.size = [webView sizeThatFits:CGSizeZero];
  frame.size.height += 1;
  [webView setFrame: frame];
  
  CGRect cellFrame = [self frame];
  cellFrame.size.height = frame.size.height + 1;
  [self setFrame: cellFrame];
  
  NSError *error; // prolly should check this error condition sometime
  ChatMessage *message = (ChatMessage *)[[[IcbConnection sharedInstance] managedObjectContext] existingObjectWithID:[self objectID] error:&error];
  [message setHeight:frame.size.height + 1];
  [message setNeedsSize:NO];
    
  [[[IcbConnection sharedInstance] managedObjectContext] save:&error]; // not fatal if this fails, just inefficient since we will resize again
  [[[IcbConnection sharedInstance] front] performSelector:@selector(reJiggerCells) withObject:nil afterDelay:0.0];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeOther)
    return YES;
  else
    [[self icbTableController] popBrowser];
    [[BrowserViewController sharedInstance] post:request];
    return NO;
}

@end