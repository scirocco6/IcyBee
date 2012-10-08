//
//  UrlMessage.m
//  IcyBee
//
//  Created by Michelle Six on 10/3/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "UrlMessage.h"
#import "IcbConnection.h"
#import "BrowserViewController.h"

@implementation UrlMessage
@synthesize urlController;

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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeOther)
    return YES;
  else
    [[self urlController] popBrowser];
    [[BrowserViewController sharedInstance] post:request];
    return NO;
}

@end