//
//  CFZ_Administrator.h
//  MuPDF
//
//  Created by mutouren on 6/28/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <MuPDF/fitz.h>
#import "CWordObj.h"


#define MAXBOXCOUNT 500


@interface FZWordInfoObj : NSObject


@property (nonatomic) fz_rect rect;
@property (nonatomic,retain) NSString *text;
@property (nonatomic) NSInteger charLength;
@property (nonatomic) NSInteger spanIndex;
@property (nonatomic) NSInteger charIndex;
@end


@interface CFZ_Administrator : NSObject
{
    fz_rect _hit_bbox[MAXBOXCOUNT];
    float _screenScale;
    NSMutableArray *_dataArray;
    NSMutableArray *_unDataArray;
}

@property (nonatomic, readonly) fz_context *ctx;
@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, readonly) fz_document *doc;
@property (nonatomic, readonly) NSMutableArray *dataArray;
@property (nonatomic, readonly) NSMutableArray *unDataArray;
@property (nonatomic) NSInteger curPageIndex;
@property (nonatomic) NSInteger curWordIndex;
@property (nonatomic, readonly) NSInteger curPageWordCount;
@property (nonatomic, copy) NSString *curDocumentFileName;
@property (nonatomic, copy) NSString *curDocumentFilePath;
@property (nonatomic, strong) FZWordInfoObj *searchWordObj;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) NSInteger curSelectWordIndex;

+ (CFZ_Administrator *)shareInstance;
#pragma mark 打开pdf
- (void) openDocument: (NSString*)nsfilename;
#pragma mark 去除多余的字符串
+(NSString*)getNSCharactersetWithNSString:(NSString*)text;
#pragma mark 返回不需要的字符
+(NSString*)getParticularString;
#pragma mark 返回最大页数
-(NSInteger)getMaxPageCount;
#pragma mark 返回某页某个单词0上1左2下3右
-(NSString*)searchWord:(NSInteger)direction;
#pragma mark 返回有数据的单词
-(CWordObj*) getWordFromCommitListWithName:(NSString*)name;
#pragma mark 查找索引的数据
-(NSMutableArray*) selectWordObjFromCommitListWithCount:(NSInteger)count;
#pragma mark 返回没有数据的单词个数
-(NSInteger) getWordCountFromUNCommitList;
#pragma mark 读取未提交的单词到数组中
-(void) getWordsFromUNCommitListToUnDataArray;
#pragma mark 返回没有数据的单词
-(CWordObj*) getWordFromUNCommitListWithName:(NSString*)name;
#pragma mark 加入有数据单词逻辑
-(BOOL) addHasDataWordLogic:(CWordObj*)obj;
#pragma mark 加入没有数据的单词逻辑
-(BOOL) addUnHasDataWordLogic:(CWordObj*)obj;
#pragma mark 删除未提交的数据
-(void)deleteUnCommitWord:(CWordObj*)obj;

-(void)removeDataArrayAllObj;
-(void)removeUnDataArrayAllObj;

@end

@interface MuHitView : UIView
{
	CGSize pageSize;
	int hitCount;
	CGRect hitRects[500];
	int linkPage[500];
	char *linkUrl[500];
	UIColor *color;
}
- (id) initWithSearchResults: (int)n forDocument: (fz_document *)doc;
- (id) initWithSearchRect:(fz_rect*)rect forDocument:(fz_document *)doc;
- (id) initWithLinks: (fz_link*)links forDocument: (fz_document *)doc;
- (void) setPageSize: (CGSize)s;
@end

@interface MuPageView : UIScrollView <UIScrollViewDelegate>
{
	fz_document *doc;
	fz_page *page;
	int number;
	UIActivityIndicatorView *loadingView;
	UIImageView *imageView;
	UIImageView *tileView;
	MuHitView *hitView;
	MuHitView *linkView;
	CGSize pageSize;
	CGRect tileFrame;
	float tileScale;
	BOOL cancel;
}
- (id) initWithFrame: (CGRect)frame document: (fz_document*)aDoc page: (int)aNumber;
- (void) displayImage: (UIImage*)image;
- (void) resizeImage;
- (void) loadPage;
- (void) loadTile;
- (void) willRotate;
- (void) resetZoomAnimated: (BOOL)animated;
- (void) showSearchResults: (int)count;
- (void) showSearchResultsWithRect:(fz_rect)rect;
- (void) clearSearchResults;
- (void) showLinks;
- (void) hideLinks;
- (int) number;
@end
