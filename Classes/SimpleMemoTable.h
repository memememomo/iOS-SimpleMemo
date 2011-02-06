//
//  TableSample.h
//  UITable
//
//  Created by Your Name on 11/01/31.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleCoreDataFactory.h"


@protocol OverlayViewControllerDelegate
- (void)doneSearch;
@end


@class OverlayViewController;

@interface SimpleMemoTable : UITableViewController<UISearchBarDelegate, OverlayViewControllerDelegate> {
	SimpleCoreData *simpleCoreData_;
	
	UISegmentedControl *segment_;
	NSInteger page_;
	
	OverlayViewController *overlayController_;
	BOOL searching_;
	BOOL letUserSelectRow_;
	
	NSString *searchKeyword_;
	
	BOOL deleteFlag_;
}

- (void)updateSegment:(UISegmentedControl *)segment;
- (void)searchKeyword:(UISearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end



/*
 * 検索キーワードを入力しているときに、覆いかぶさる灰色のレイヤー
 */

@interface OverlayViewController : UIViewController {
	id<OverlayViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<OverlayViewControllerDelegate> delegate;

@end