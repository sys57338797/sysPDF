//
//  PDFMuPageViewDelegate.h
//  SysPDF
//
//  Created by mutouren on 4/12/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#ifndef PDFMuPageViewDelegate_h
#define PDFMuPageViewDelegate_h

@protocol PDFMuPageViewDelegate
@optional

- (void)loadPage;
-(int) number;
-(void) willRotate;
-(void) showLinks;
-(void) hideLinks;
-(void) showSearchResults: (int)count;
-(void) clearSearchResults;
-(void) resetZoomAnimated: (BOOL)animated;
-(void) setScale:(float)scale;
-(void) textSelectModeOn;
-(void) textSelectModeOff;
-(void) deselectAnnotation;
-(void) deleteSelectedAnnotation;
-(void) inkModeOn;
-(void) inkModeOff;
-(void) saveSelectionAsMarkup:(int)type;
-(void) saveInk;
-(void) update;
@end

#endif /* PDFMuPageViewDelegate_h */
