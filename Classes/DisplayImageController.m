//
//  DisplayImageController.m
//  SimpleMemo
//
//  Created by Your Name on 11/02/05.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "DisplayImageController.h"


@implementation DisplayImageController

@synthesize imagePath = imagePath_;


- (void)dealloc
{
	[imagePath_ release];
	[super dealloc];
}


- (id)initWithImagePath:(NSString *)imagePath
{
	if ( self = [super init] ) {
		self.imagePath = imagePath;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
	imageView_.image = image;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
