//
//  DisplayImageController.h
//  SimpleMemo
//
//  Created by Your Name on 11/02/05.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DisplayImageController : UIViewController {
	IBOutlet UIImageView *imageView_;
	
	NSString *imagePath_;
}

@property (nonatomic, retain) NSString *imagePath;

- (id)initWithImagePath:(NSString *)imagePath;

@end
