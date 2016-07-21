//
//  PDFMuPageView.h
//  SysPDF
//
//  Created by mutouren on 4/12/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFMuPageViewDelegate.h"
#import <MuPDF/fitz.h>


@interface PDFMuPageView : UIScrollView <PDFMuPageViewDelegate, UIScrollViewDelegate>

-(id) initWithFrame:(CGRect)frame document:(fz_document *)doc page:(int)aNumber;

@end
