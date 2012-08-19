//
//  TableViewControllerWithLoader.h
//
//  Created by Jonas Hagstedt on 25/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewControllerWithLoader : UITableViewController {
	UIActivityIndicatorView* _loader;
	UIImageView* _loaderBackgroundView;
}
- (void)showLoader;
- (void)hideLoader;
@end
