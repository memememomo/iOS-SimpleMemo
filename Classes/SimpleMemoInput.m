//
//  SimpleMemoText.m
//  SimpleMemo
//
//  Created by Your Name on 11/02/05.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "SimpleMemoInput.h"
#import "SimpleCoreDataFactory.h"


#pragma mark -

@implementation SimpleMemoInput


@synthesize cameraButton = cameraButton_;
@synthesize locationButton = locationButton_;

@synthesize tmpImagePath = tmpImagePath_;



#pragma mark -
#pragma mark Initialize


- (void)dealloc
{
	[self removeImageFile:self.tmpImagePath];
	
	[cameraButton_ release];
	[locationButton_ release];
	[textTrashAlert_ release];
	[saveAlert_ release];
	[tmpImagePath_ release];
	[super dealloc];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	[textView_ becomeFirstResponder];
	
	textTrashAlert_ = [[TextTrashAlert alloc] init];
	textTrashAlert_.delegate = self;
	
	saveAlert_ = [[SaveAlert alloc] init];
	saveAlert_.delegate = self;
	
	self.tmpImagePath = @"";
}



#pragma mark -
#pragma mark TextView Delegates


/*
 * テキスト入力が始まるときに呼ばれる処理
 */

- (void)textViewDidBeginEditing:(UITextView *)textView 
{
	static const CGFloat kKeyboardHeight = 216.0 - 48.0;

	
	
	// カメラボタン
	self.cameraButton = [self createCameraButton:UIBarButtonItemStyleBordered];
	if ([self.tmpImagePath isEqualToString:@""]) {
		self.cameraButton.style = UIBarButtonItemStyleBordered;
	} else {
		self.cameraButton.style = UIBarButtonItemStyleDone;
	}
	
	
	// 位置情報ボタン
	self.locationButton = [[[UIBarButtonItem alloc]
							initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
							target:self
							action:@selector(locationButtonPush:)]
						   autorelease];
	if (!coordinate_.longitude || !coordinate_.latitude) {
		self.locationButton.style = UIBarButtonItemStyleBordered;
	} else {
		self.locationButton.style = UIBarButtonItemStyleDone;
	}
	
	
	// ツールバーへの追加処理
	[self setToolbarItems:[NSArray arrayWithObjects:
						   [self createFlexibleSpace],
						   locationButton_,
						   cameraButton_,
						   nil]];
	
	
	
	// テキスト編集時は、入力終了ボタンを表示する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self
											   action:@selector(doneDidPush)] autorelease];
	
	// 入力キーボードをアニメーションで表示する
	// キーボードに合わせて、テキスト入力領域の大きさを調整する
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	CGRect textViewFrame = textView.frame;
	textViewFrame.size.height = self.view.bounds.size.height - kKeyboardHeight;
	textView.frame = textViewFrame;

	
	// ツールバー
	CGRect toolbarFrame = self.navigationController.toolbar.frame;
	self.navigationController.toolbarHidden = NO;
	toolbarFrame.origin.y = self.view.window.bounds.size.height - toolbarFrame.size.height - kKeyboardHeight - 44.0;
	self.navigationController.toolbar.frame = toolbarFrame;
	
	[UIView commitAnimations];

	
	
	// 編集中は削除ボタンを表示しない
	self.navigationItem.leftBarButtonItem = nil;
}


/*
 * テキスト入力が終わったときに呼ばれる処理
 */

- (void)textViewDidEndEditing:(UITextView *)textView 
{
	// 編集していない場合は、保存ボタンを表示する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self
											   action:@selector(saveDidPush)] autorelease];
	
	// キーボードが非表示になるので、それに合わせてテキスト入力領域の大きさを調整する
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	
	textView.frame = self.view.bounds;
	
	CGRect toolbarFrame = self.navigationController.toolbar.frame;
	toolbarFrame.origin.y = self.view.window.bounds.size.height - toolbarFrame.size.height;
	self.navigationController.toolbar.frame = toolbarFrame;
	[UIView commitAnimations];
	
	
	// 削除ボタンの設定
	UIBarButtonItem *trashButton = [[[UIBarButtonItem alloc] 
									 initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
									 target:self
									 action:@selector(trashButtonDidPush)] autorelease];
	self.navigationItem.leftBarButtonItem = trashButton;
	
	
	// ツールバーを非表示
	self.navigationController.toolbarHidden = YES;
}


/*
 * ボタン作成のヘルパー
 */

- (UIBarButtonItem *)createCameraButton:(NSInteger)style
{
	UIImage *image = [UIImage imageNamed:@"camera"];
	UIBarButtonItem *cameraButton = [[[UIBarButtonItem alloc]
									  initWithImage:image
									  style:style
									  target:self
									  action:@selector(cameraButtonPush:)]
									 autorelease];
	return cameraButton;
}


- (UIBarButtonItem *)createFlexibleSpace
{
	UIBarButtonItem *space = [[[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
							   target:nil
							   action:nil]
							  autorelease];
	return space;
}


#pragma mark -
#pragma mark Button Delegate


/*
 * 編集終了ボタン
 */

- (void)doneDidPush 
{
	[textView_ resignFirstResponder];
}


/*
 * 保存ボタン
 */

- (void)saveDidPush 
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:nil
						  message:NSLocalizedString(@"SAVE_CONFIRM_MESSAGE", @"")
						  delegate:saveAlert_
						  cancelButtonTitle:NSLocalizedString(@"CONFIRM_NO", @"")
						  otherButtonTitles:NSLocalizedString(@"CONFIRM_YES", @""),
						  nil];
	[alert show];
	[alert release];
}


/*
 * 削除ボタン
 */

- (void)trashButtonDidPush 
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:nil
						  message:NSLocalizedString(@"DELETE_CONFIRM_MESSAGE", @"")
						  delegate:textTrashAlert_
						  cancelButtonTitle:NSLocalizedString(@"CONFIRM_NO", @"")
						  otherButtonTitles:NSLocalizedString(@"CONFIRM_YES", @""),
						  nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark Camera


/*
 * 画像選択関係の処理
 */

- (void)cameraButtonPush:(id)sender
{
	UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
	sheet.delegate = self;
	[sheet addButtonWithTitle:NSLocalizedString(@"CAMERA", @"")];
	[sheet addButtonWithTitle:NSLocalizedString(@"ALBUM", @"")];
	[sheet addButtonWithTitle:NSLocalizedString(@"CONFIRM_CANCEL", @"")];
	sheet.cancelButtonIndex = 2;
	[sheet showInView:self.navigationController.toolbar];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	// ボタンインデックスをチェックする
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	
	// ソースタイプを決定する
	UIImagePickerControllerSourceType sourceType = 0;
	switch (buttonIndex) {
		case 0:
			sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		case 1:
			sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
	}
	
	// 使用可能かどうかチェックする
	if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
		//UIAlertViewQuick(@"", @"Not Available", @"OK");
		return;
	}
	
	// イメージピッカーを作る
	UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
	picker.delegate = self;
	picker.sourceType = sourceType;
	
	
	// イメージピッカーを表示する
	[self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// イメージピッカーを隠す
	[self dismissModalViewControllerAnimated:YES];
	
	// オリジナル画像を取得する
	UIImage*    originalImage;
	originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];

	
	// グラフィックスコンテキストを作る
	CGSize  size = { 320, 480 };
	UIGraphicsBeginImageContext(size);
	
	// 画像を縮小して描画する
	CGRect  rect;
	rect.origin = CGPointZero;
	rect.size = size;
	[originalImage drawInRect:rect];
	
	// 描画した画像を取得する
	UIImage*    shrinkedImage;
	shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	
	// 画像を表示する
	self.tmpImagePath = [self createTmpImageFile:shrinkedImage];
	cameraButton_.style = UIBarButtonItemStyleDone;
}


#pragma mark -
#pragma mark Alert Delegate


/*
 * 保存する、テキストが入力されていなかったら保存しない
 */

- (void)save 
{
	if ([textView_.text isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:nil
							  message:NSLocalizedString(@"NOT_TEXT", @"")
							  delegate:nil
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil]; 
		[alert show];
		[alert release];
		return;
	}
	
	
	// CoreDataの準備
	SimpleCoreDataFactory *factory = [SimpleCoreDataFactory sharedCoreData];
	
	NSFetchRequest *request = [factory createRequest:@"memo"];

	NSDictionary *sort = [[[NSDictionary alloc]
						   initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil]
						   forKeys:[NSArray arrayWithObjects:@"timeStamp", nil]]
						  autorelease];

	[factory setSortDescriptors:request AndSort:sort];

	NSFetchedResultsController *controller = [factory fetchedResultsController:request AndSectionNameKeyPath:nil];

	SimpleCoreData *simpleCoreData = [factory createSimpleCoreData:controller];
	
	
	// 新しいデータを格納していく
	NSManagedObject *newObject = [simpleCoreData newManagedObject];
	[newObject setValue:[NSDate date] forKey:@"timeStamp"];
	[newObject setValue:textView_.text forKey:@"text"];

	
	if (coordinate_.longitude && coordinate_.latitude) {
		[newObject setValue:[NSNumber numberWithDouble:coordinate_.longitude] forKey:@"longitude"];
		[newObject setValue:[NSNumber numberWithDouble:coordinate_.latitude] forKey:@"latitude"];
			
		coordinate_.longitude = 0;
		coordinate_.latitude = 0;
	}
	
	
	if (![tmpImagePath_ isEqualToString:@""]) {
		NSString *imagePath = [self newFilePath];
		[[NSFileManager defaultManager] moveItemAtPath:tmpImagePath_
												toPath:imagePath
												 error:nil];
		
		[newObject setValue:imagePath forKey:@"imagePath"];
	}


	[simpleCoreData saveContext];
	
	[self clearData];
}


- (void)textTrash
{
	[self clearData];
}


/*
 * 一時保存しているデータをクリアする
 */

- (void)clearData
{
	textView_.text = @"";
	
	if (coordinate_.longitude && coordinate_.latitude) {
		coordinate_.longitude = 0.0;
		coordinate_.latitude = 0.0;
	}
	
	if (![tmpImagePath_ isEqualToString:@""]) {
		[[NSFileManager defaultManager] removeItemAtPath:tmpImagePath_
												   error:nil];
		self.tmpImagePath = @"";
	}
}


#pragma mark -
#pragma mark ImageFile


/*
 * ファイルを削除する
 */

- (void)removeImageFile:(NSString *)path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		[fileManager removeItemAtPath:path error:nil];
	}
}


/*
 * 保存するかどうか保留している画像をファイルで出力しておく
 */

- (NSString *)createTmpImageFile:(UIImage *)image
{
	NSString *tempDir = NSTemporaryDirectory();
	NSString *path = [tempDir stringByAppendingPathComponent:@"tmpImage.jpg"];

	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	
	NSData *data = UIImageJPEGRepresentation(image, 0.8);
	[data writeToFile:path atomically:YES];
	
	return path;
}


/*
 * 保存するファイル名をランダムに決める
 */

- (NSString *)newFilePath
{
	// はじめて呼び出されたときは乱数の種を初期化する
	static BOOL sFirst = YES;
	
	if (sFirst) {
		srandomdev();
		sFirst = NO;
	}
	
	// ドキュメントフォルダのパスを取得する
	NSArray *array;
	array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
												NSUserDomainMask,
												YES);
	
	NSString *dir = [array lastObject];
	
	
	// ドキュメントフォルダ内で重複しないファイル名を決定する
	// ファイル名は乱数を文字列化したものとする
	NSString *path = nil;
	
	while (!path) {
		// 乱数を生成
		long l = random();
		
		// 乱数を文字列化してファイル名を作成する
		NSString *fileName;
		fileName = [NSString stringWithFormat:@"%X.jpg", l];
		
		// ファイルパスを作成
		NSString *tempPath;
		tempPath = [dir stringByAppendingPathComponent:fileName];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:tempPath]) {
			// 存在しないので、このファイル名とする
			// [pool release]で解放されないようにするため、「copy」メソッドでコピーする
			path = tempPath;
		}
	}
	
	// ファイルパスを返す
	return path;
}


#pragma mark -
#pragma mark Location


- (void)locationButtonPush:(id)sender
{
	LocationController *location = [LocationController sharedObject];
	location.delegate = self;
	[location yobidashi];
}


- (void)updateCoordinate:(CLLocationCoordinate2D)coordinate
{
	coordinate_ = coordinate;
	LocationController *location = [LocationController sharedObject];
	[location stop];
	self.locationButton.style = UIBarButtonItemStyleDone;
}



@end



#pragma mark -

@implementation TextTrashAlert

@synthesize delegate;

-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	switch (buttonIndex) {
		case 0: // いいえ
			break;
		case 1: //　はい
			[delegate textTrash];
			break;
	}
}


@end




#pragma mark -

@implementation SaveAlert

@synthesize delegate;

-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case 0: // いいえ
			break;
		case 1: { //　はい
			[delegate save];
			break;
		}
	}
}

@end

