//
//  TableSample.m
//  UITable
//
//  Created by Your Name on 11/01/31.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "SimpleMemoTable.h"
#import "SimpleCoreDataFactory.h"
#import "SimpleMemoTableDetail.h"

static int ROWS_IN_PAGE = 50;

@implementation SimpleMemoTable


/*
 * 初期化と後処理
 */

- (void)dealloc 
{
	[segment_ release];
	[simpleCoreData_ release];
	[super dealloc];
}

- (id)init
{
	// テーブルの表示形式を指定する
	if ( (self = [super initWithStyle:UITableViewStylePlain]) ) {
		self.title = @"List";
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationController.toolbarHidden = YES;

	
	// 選択されたセルのハイライトを解除する
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self.tableView reloadData];

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	self.navigationController.toolbarHidden = YES;

	
	[super viewDidAppear:animated];
	
	// テーブルの削除を可能にする
	//[self.tableView setEditing:YES animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	

	// CoreDataの初期化	
	SimpleCoreDataFactory *factory = [SimpleCoreDataFactory sharedCoreData];
	NSFetchRequest *request = [factory createRequest:@"memo"];
	NSDictionary *sort = [[[NSDictionary alloc]
						   initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil]
						   forKeys:[NSArray arrayWithObjects:@"timeStamp", nil]]
						  autorelease];
	[factory setSortDescriptors:request AndSort:sort];
	NSFetchedResultsController *fetchedResultController = [factory fetchedResultsController:request AndSectionNameKeyPath:nil];
	simpleCoreData_ = [factory createSimpleCoreData:fetchedResultController];
	[simpleCoreData_ retain];
	
	
	// ページ移動のスイッチ
	NSArray *items = [NSArray arrayWithObjects:@"<", @">", nil];
	segment_ = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
	segment_.frame = CGRectMake( 0, 0, 40, 30);
	segment_.selectedSegmentIndex = UISegmentedControlNoSegment;
	segment_.segmentedControlStyle = UISegmentedControlStyleBar;
	segment_.momentary = YES;
	[segment_ addTarget:self
				 action:@selector(segmentedControlClicked:)
	   forControlEvents:UIControlEventValueChanged];
	
	UIBarButtonItem *barButton = [[[UIBarButtonItem alloc] 
								   initWithCustomView:segment_]
								  autorelease];
	self.navigationItem.rightBarButtonItem = barButton;
	
	[self updateSegment:segment_];
	
	
	// ページ番号を初期化
	page_ = 0;

	
	// 検索バー
	UISearchBar *searchBar = [[[UISearchBar alloc] init] autorelease];
	searchBar.frame = CGRectMake( 0, 0, self.tableView.bounds.size.width, 0);
	searchBar.delegate = self;
	searchBar.placeholder = @"search";
	[searchBar sizeToFit];
	self.navigationItem.titleView = searchBar;
	
	searching_ = NO;
	letUserSelectRow_ = YES;
}



#pragma mark -
#pragma mark TableView


/*
 * 各セクションの項目数を返す
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// データ数を取得
	id<NSFetchedResultsSectionInfo> sectionInfo = [[simpleCoreData_.fetchedResultsController sections] objectAtIndex:section];
	NSInteger rows = [sectionInfo numberOfObjects];
	
	// セグメント情報を更新
	[self updateSegment:segment_];
	
	// ページに応じて行数を変える
	if (rows >= (page_ + 1) * ROWS_IN_PAGE) {
		return ROWS_IN_PAGE;
	} else {
		return rows - page_ * ROWS_IN_PAGE;
	}	
}


/*
 * セルの内容
 */

- (UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"basis-cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if ( nil == cell ) {
		// 詳細情報なしの場合
		//cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
		//							  reuseIdentifier:identifier];
		
		// 詳細情報ありの場合
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:identifier];
		[cell autorelease];
	}
	
	
	// ページに応じて、indexPathを計算する
	NSInteger row = (page_ * ROWS_IN_PAGE) + indexPath.row;
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];

	
	// indexPathからデータを取得してくる
	NSManagedObject *managedObject = [simpleCoreData_.fetchedResultsController objectAtIndexPath:newIndexPath];

	
	// セクションにある項目の中のrow番目のデータを取得
	NSDate *timeStamp = [managedObject valueForKey:@"timeStamp"];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"YYYY/MM/dd HH:mm"];
	NSString *date = [formatter stringFromDate:timeStamp];
	
	NSString *text = [managedObject valueForKey:@"text"];

	
	// テキストを追加
	cell.textLabel.text = text;
	cell.detailTextLabel.text = date;
	
	// 改行あり
	cell.textLabel.numberOfLines = 0;
	

	return cell;
}


/*
 * セルの幅を調整
 */

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	CGFloat height = 50.0f;
	
	// ページに応じて、indexPathを計算する
	NSInteger row = (page_ * ROWS_IN_PAGE) + indexPath.row;
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];

	
	// 表示する予定のテキスト（改行あり）
	NSManagedObject *managedObject = [simpleCoreData_.fetchedResultsController objectAtIndexPath:newIndexPath];
	NSString *text = [NSString stringWithFormat:@"%@\ndate", [managedObject valueForKey:@"text"]];
	

	// 最大の表示領域CGSize。このCGSize以上は文字列長がこのサイズを超える場合はすべて表示されない
	CGSize bounds = CGSizeMake(300, 10000);
	
	// 文字列描画に使用するフォント
	UIFont *font = [UIFont systemFontOfSize:18];
	
	// 表示に必要なCGSize
	CGSize size = [text sizeWithFont:font constrainedToSize:bounds lineBreakMode:UILineBreakModeTailTruncation];
	
	CGFloat h = size.height - height;
	if ( h > 0 ) {
		height += h;
	}
	
	return height;
}



/*
 * セル選択時のアクション
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// ページに応じて、indexPathを計算する
	NSInteger row = (page_ * ROWS_IN_PAGE) + indexPath.row;
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
	
	
	// データの詳細情報を表示するページへ
	SimpleMemoTableDetail *detail = [[[SimpleMemoTableDetail alloc]
									  initWithNibName:@"SimpleMemoTableDetail"
									  bundle:nil]
									 autorelease];
	detail.indexPath = newIndexPath;
	detail.simpleCoreData = simpleCoreData_;
	detail.hidesBottomBarWhenPushed = YES;
	
	[self.navigationController pushViewController:detail animated:YES];
}


/*
 * 編集
 */

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// データ削除
	if ( UITableViewCellEditingStyleDelete == editingStyle ) {
		// ページに応じて、indexPathを計算する
		NSInteger row = (page_ * ROWS_IN_PAGE) + indexPath.row;
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
		

		// 画像ファイル削除
		NSManagedObject *managedObject = [simpleCoreData_.fetchedResultsController objectAtIndexPath:newIndexPath];
		NSString *imagePath = [managedObject valueForKey:@"imagePath"];
		
		if ( imagePath != nil && ![imagePath isEqualToString:@""] &&
			[[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
		{
			[[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
		}

		
		// CoreData削除
		[simpleCoreData_ deleteObjectWithIndexPath:newIndexPath];
		

		// UIのアップデート
		[self updateSegment:segment_];
		[tableView reloadData];
	}
}


#pragma mark -
#pragma mark SegmentedControl Delegate


/*
 * セグメントがタップされたときに呼び出される
 */

- (void)segmentedControlClicked:(id)sender 
{
	UISegmentedControl *segment = sender;
	NSInteger selected = segment.selectedSegmentIndex;
	
	if (selected == 0) {
		if (page_ > 0) {
			page_--;
		}
	} else if (selected == 1) {
		page_++;
	}
	
	[self updateSegment:segment];
	
	[self.tableView reloadData];
}


/*
 * セグメントの選択不可などの設定を更新する
 */

- (void)updateSegment:(UISegmentedControl*)segment
{
	if (page_ == 0) {
		[segment setEnabled:NO forSegmentAtIndex:0];
	} else {
		[segment setEnabled:YES forSegmentAtIndex:0];
	}
	
	
	NSInteger rows = [simpleCoreData_ countObjects];
	
	if (rows <= (page_+1) * ROWS_IN_PAGE) {
		[segment setEnabled:NO forSegmentAtIndex:1];
	} else {
		[segment setEnabled:YES forSegmentAtIndex:1];
	}
}


#pragma mark -
#pragma mark SearBarDelegate


/*
 * 検索キーワードを入力し始める
 */

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	searching_ = YES;
	letUserSelectRow_ = NO;
	self.tableView.scrollEnabled = NO;
	
	if (overlayController_ == nil) {
		overlayController_ = [[OverlayViewController alloc] init];
	}
	
	// オーバーレイヤーの高さを計算
	CGFloat height = self.tableView.contentSize.height;
	if ( height < self.view.frame.size.height ) {
		height = self.view.frame.size.height;
	}
	CGFloat yaxis = self.tableView.frame.origin.y;
	CGFloat width = self.tableView.frame.size.width;
	
	
	// オーバーレイヤ作成
	CGRect frame = CGRectMake( 0, yaxis, width, height );
	overlayController_.view.frame = frame;
	overlayController_.view.backgroundColor = [UIColor grayColor];
	overlayController_.view.alpha = 0.8;
	overlayController_.delegate = self;
	
	page_ = 0;
	
	[self.tableView insertSubview:overlayController_.view aboveSubview:self.view];
}


/*
 * キーボードの「検索」が押されたとき
 */

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self searchKeyword:searchBar];
}


/*
 * オーバーレイヤのビューがタップされたとき
 */

- (void)doneSearch
{
	[self searchKeyword:(UISearchBar *)self.navigationItem.titleView];
}


/*
 * 検索、現在はキーボードの「検索」が押されたときと、オーバーレイヤのビューがタップされたときに呼び出される
 */

- (void)searchKeyword:(UISearchBar*)searchBar 
{
	searching_ = NO;
	letUserSelectRow_ = YES;
	self.tableView.scrollEnabled = YES;
	
	[overlayController_.view removeFromSuperview];
	[searchBar resignFirstResponder];
	
	
	// 検索キーワードから正規表現を作成
	NSPredicate *predicate = nil;
	if (![searchBar.text isEqualToString:@""]) {
		// 入力されていなかったら、必ずマッチさせる
		predicate = [NSPredicate predicateWithFormat:@"text CONTAINS[cd] %@", searchBar.text];
	}
	[[SimpleCoreDataFactory sharedCoreData] 
	 setPredicate:simpleCoreData_.fetchedResultsController.fetchRequest WithPredicate:predicate];
	[simpleCoreData_ performFetch];
	
	[self.tableView reloadData];
}


@end



#pragma mark -

@implementation OverlayViewController

@synthesize delegate;


/*
 * オーバーレイヤがタップされたとき
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate doneSearch];
}


/*
 * メモリの容量が少ない時に呼び出される
 */

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


@end
