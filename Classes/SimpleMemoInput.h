//
//  SimpleMemoText.h
//  SimpleMemo
//
//  Created by Your Name on 11/02/05.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationController.h"

/*
 * デリゲートプロトコル
 */

@protocol SimpleMemoTextDelegate
- (void)textTrash;
- (void)save;
@end


/*
 * アラート関係のクラス
 */

@interface TextTrashAlert : UIViewController {
	id<SimpleMemoTextDelegate> delegate;
}
@property (nonatomic, assign) id<SimpleMemoTextDelegate> delegate;
@end


@interface SaveAlert : UIViewController {
	id<SimpleMemoTextDelegate> delegate;
}
@property (nonatomic, assign) id<SimpleMemoTextDelegate> delegate;
@end


/*
 * テキスト入力画面のクラス
 */

@interface SimpleMemoInput : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, LocationControllerDelegate, UIImagePickerControllerDelegate, SimpleMemoTextDelegate> {
	IBOutlet UITextView *textView_;
	
	UIBarButtonItem *cameraButton_;
	UIBarButtonItem *locationButton_;
	
	TextTrashAlert *textTrashAlert_;
	SaveAlert *saveAlert_;
	
	NSString *tmpImagePath_;
	CLLocationCoordinate2D coordinate_;
}

@property (nonatomic, retain) UIBarButtonItem *cameraButton;
@property (nonatomic, retain) UIBarButtonItem *locationButton;

@property (nonatomic, retain) NSString *tmpImagePath;

- (UIBarButtonItem *)createCameraButton:(NSInteger)style;
- (UIBarButtonItem *)createFlexibleSpace;
- (NSString *)createTmpImageFile:(UIImage *)image;
- (void)removeImageFile:(NSString *)path;
- (NSString *)newFilePath;
- (void)clearData;

@end



