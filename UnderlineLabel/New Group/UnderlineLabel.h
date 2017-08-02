//
//  UnderlineLabel.h
//  UnderlineLabel
//
//  Created by Эдуард Пятницын on 31.07.17.
//  Copyright © 2017 Эдуард Пятницын. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kUnderlineLabelKey;

@interface UnderlineAttributes : NSObject

+ (UnderlineAttributes *)attributeWithColor:(UIColor *)color
                    shouldDisplayGlyphFrame:(BOOL)glyphFrame;

- (NSDictionary *)dictionaryRepresentation;

@end

@interface UnderlineLabel : UIView

@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic)  NSAttributedString *attributedText;
@property (nonatomic) NSString *text;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIFont *font;

@end
