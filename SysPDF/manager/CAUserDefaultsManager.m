//
//  CAUserDefaultsManager.m
//  CWGJCarPark
//
//  Created by mutouren on 9/7/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import "CAUserDefaultsManager.h"
#import "NSString+StringJudge.h"
#import "PDFBookObj.h"

NSString *const kCAUserDefaultsManagerWordInfoName = @"WORD";                           //单词文件夹名称
NSString *const kCAUserDefaultsManagerWordNonTranslationName = @"translationWord";      //未翻译的单词文件名称
NSString *const kCAUserDefaultsManagerPDFInfoName = @"PDFINFO";                         //PDF书信息
NSString *const kCAUserDefaultsManagerPDFFileName = @"PDF";                             //存放PDF文件的文件夹


@interface CAUserDefaultsManager ()

@property (nonatomic, strong) NSUserDefaults *ud;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableArray *wordInitialArray;
@property (nonatomic, copy) NSString *DocumentsPath;

@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end


@implementation CAUserDefaultsManager


//share Instance of ViewManager
+ (CAUserDefaultsManager *)shareInstance
{
    static CAUserDefaultsManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^ { instance = [[CAUserDefaultsManager alloc] init]; });
    return instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.ud = [NSUserDefaults standardUserDefaults];
        self.fileManager = [NSFileManager defaultManager];
        self.wordInitialArray = [NSMutableArray array];
        
        dispatch_sync(self.ioQueue, ^{
            for(char c = 'A';c <= 'Z';c++ )
                [self.wordInitialArray addObject:[NSString stringWithFormat:@"%c",c]];
        });
    }
    return self;
}

#pragma mark 读取bookObj
- (void)reloadBookObj:(PDFBookObj*)obj
{
    PDFBookObj *saveObj = [self.ud objectForKey:obj.bookName];
    if (saveObj) {
        obj.currentPage = saveObj.currentPage;
    }
    
    if (obj.currentPage == 0) {
        obj.currentPage = -1;
    }
}

- (NSString*)wordDirectoryPath
{
    return [[self DocumentsPath] stringByAppendingPathComponent:kCAUserDefaultsManagerWordInfoName];
}

- (NSString*)PDFInfoDirectoryPath
{
    return [[self DocumentsPath] stringByAppendingPathComponent:kCAUserDefaultsManagerPDFInfoName];
}

- (NSString*)PDFDirectoryPath
{
    return [[self DocumentsPath] stringByAppendingPathComponent:kCAUserDefaultsManagerPDFFileName];
}

- (void)wordDictionaryFileLoadCompletion:(managerLoadWordCompletionBlock)completion
{
    dispatch_async(self.ioQueue, ^{
        NSMutableDictionary *resDictionary = [NSMutableDictionary dictionary];
        
        for (NSString *initialWord in self.wordInitialArray) {
            
            NSMutableArray *wordArray = [self getWordArrayWithFileName:initialWord];
            
            [resDictionary setObject:wordArray forKey:initialWord];
        }
        
        if (completion) {
            completion(resDictionary);
        }
    });
}

- (NSMutableArray*)nonTranslationWordArray
{
    return [self getWordArrayWithFileName:kCAUserDefaultsManagerWordNonTranslationName];
}

- (void)movePDFFileToPDFDirectory
{
    NSMutableArray *moveArray = [NSMutableArray array];
    NSDirectoryEnumerator *direnum = [self.fileManager enumeratorAtPath:[self DocumentsPath]];
    NSString *file;
    BOOL isdir;
    
    
    while (file = [direnum nextObject]) {
        NSString *filepath = [[self DocumentsPath] stringByAppendingPathComponent:file];
        NSArray *dirArray = [file componentsSeparatedByString:@"/"];
        if (dirArray.count <= 1) {
            if ([self.fileManager fileExistsAtPath:filepath isDirectory:&isdir] && !isdir) {
                if ([file fileExtensionsName:@"pdf"]) {
                    [moveArray addObject:file];
                }
            }
        }
    }
    
    [self validationDirectoryPath:[self PDFDirectoryPath]];
    
    for (NSString *file in moveArray) {
        NSString *sourcePath = [[self DocumentsPath] stringByAppendingPathComponent:file];
        NSString *path = [[self PDFDirectoryPath] stringByAppendingPathComponent:file];
        [self.fileManager createFileAtPath:path contents:[NSData dataWithContentsOfFile:sourcePath] attributes:nil];
        [self.fileManager removeItemAtPath:sourcePath error:nil];
    }
}

#pragma mark 返回PDF文件名称
- (NSMutableArray*)PDFFileNameArray
{
    NSMutableArray *resArray = [NSMutableArray array];
    
    [self movePDFFileToPDFDirectory];
    
    NSString *path = [self PDFDirectoryPath];
    
    NSDirectoryEnumerator *direnum = [self.fileManager enumeratorAtPath:path];
    NSString *file;
    BOOL isdir;
    
    while (file = [direnum nextObject]) {
        NSString *filePath = [path stringByAppendingPathComponent:file];
        NSArray *dirArray = [file componentsSeparatedByString:@"/"];
        if (dirArray.count <= 1) {
            if ([self.fileManager fileExistsAtPath:filePath isDirectory:&isdir] && !isdir) {
                if ([file fileExtensionsName:@"pdf"]) {
                    PDFBookObj *obj = [PDFBookObj createBookObjWithPath:path name:file];
                    [resArray addObject:obj];
                }
            }
        }
    }
    
    return resArray;
}

#pragma mark 更新未翻译
- (void)updateNonTranslationWordArray:(NSArray*)array
{
    [self updateWordArray:array fileName:[NSString stringWithFormat:@"%@",kCAUserDefaultsManagerWordNonTranslationName]];
}

- (void)updateWordArray:(NSArray *)array fileName:(NSString*)fileName
{
    if (array&&array.count&&fileName.length) {
        dispatch_async(self.ioQueue, ^{
            [self writePListFileForDirectoryPath:[NSString stringWithFormat:@"%@",[self wordDirectoryPath]] fileName:fileName data:[NSKeyedArchiver archivedDataWithRootObject:array] atom:YES];
        });
    }
}

#pragma mark 更新单词表
- (void)updateWordDictionary:(NSDictionary*)dictionary
{
    dispatch_async(self.ioQueue, ^{
        NSArray *keys = [dictionary allKeys];
        for (NSString *key in keys) {
            NSArray *wordArray = [dictionary objectForKey:key];
            [self updateWordArray:wordArray fileName:[NSString stringWithFormat:@"%@",key]];
        }
    });
}

#pragma mark 根据文件名返回单词数组
- (NSMutableArray*)getWordArrayWithFileName:(NSString*)fileName
{
    NSMutableArray *resArray = [NSMutableArray array];
    if (fileName&&fileName.length) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self wordDirectoryPath],fileName];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data.length) {
            id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([obj isKindOfClass:[NSArray class]]) {
                [resArray addObjectsFromArray:obj];
            }
        }
    }
    
    return resArray;
}

#pragma mark 写plist文件,data为NSArray,NSDictionary
-(void) writePListFileForDirectoryPath:(NSString*)path fileName:(NSString*)fileName data:(NSData*)data atom:(BOOL)atom
{
    
    [self validationDirectoryPath:path];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,fileName];
    
    [self.fileManager createFileAtPath:filePath contents:data attributes:nil];
}

#pragma mark 验证路径，创建路径所需要的文件夹
- (void)validationDirectoryPath:(NSString*)path
{
    if (path.length >= [self DocumentsPath].length) {
        NSRange range = [path rangeOfString:[self DocumentsPath]];
        if (range.location != NSNotFound) {
            NSString *p = [path substringFromIndex:[self DocumentsPath].length];
            NSArray *subArray = [p componentsSeparatedByString:@"/"];
            NSMutableString *filePath = [NSMutableString stringWithFormat:@"%@",[self DocumentsPath]];
            if (subArray.count > 1) {
                for (int x = 1; x < subArray.count; x++) {
                    [self createDirectoryAtPath:filePath name:[subArray objectAtIndex:x]];
                    [filePath appendFormat:@"/%@",[subArray objectAtIndex:x]];
                }
            }
        }
    }
}

- (void)createDirectoryAtPath:(NSString*)path name:(NSString*)name
{
    NSDirectoryEnumerator *direnum = [self.fileManager enumeratorAtPath:path];
    NSString *directoryPath = [NSString stringWithFormat:@"%@/%@",path,name];
    NSString *file = nil;
    BOOL isdir;
    
    while (file = [direnum nextObject]) {
        NSString *FPath = [path stringByAppendingPathComponent:file];
        if ([self.fileManager fileExistsAtPath:FPath isDirectory:&isdir]) {
            if ([FPath isEqualToString:directoryPath]) {
                if (!isdir) {
                    [self.fileManager removeItemAtPath:FPath error:nil];
                    break;
                }
                else {
                    return;
                }
            }
        }
    }
    
    [self.fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
}

- (NSString*)DocumentsPath
{
    if (!_DocumentsPath) {
        _DocumentsPath = [NSString stringWithFormat: @"%@/Documents", NSHomeDirectory()];
    }
    
    return _DocumentsPath;
}

- (dispatch_queue_t)ioQueue
{
    if (!_ioQueue) {
        _ioQueue = dispatch_queue_create("sysPDF", DISPATCH_QUEUE_SERIAL);
    }
    
    return _ioQueue;
}

@end
