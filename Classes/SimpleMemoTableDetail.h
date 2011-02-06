//
//  SimpleMemoTableDetail.h
//  SimpleMemo
//
//  Created by Your Name on 11/02/05.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleCoreData.h"

@interface SimpleMemoTableDetail : UIViewController {
	NSIndexPath *indexPath_;
	SimpleCoreData *simpleCoreData_;
	
	IBOutlet UITextView *textView_;
	IBOutlet UIBarButtonItem *camera_;
	IBOutlet UIBarButtonItem *map_;
	
	IBOutlet UIToolbar *toolBar_;
}

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) SimpleCoreData *simpleCoreData;

- (IBAction)displayImage;
- (IBAction)displayMap;

@end
