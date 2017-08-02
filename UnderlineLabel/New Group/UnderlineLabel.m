//
//  UnderlineLabel.m
//  UnderlineLabel
//
//  Created by Эдуард Пятницын on 31.07.17.
//  Copyright © 2017 Эдуард Пятницын. All rights reserved.
//

#import "UnderlineLabel.h"
@import CoreText;

NSString *const kUnderlineLabelKey = @"UnderlineLabelKey";
NSString *const kUnderlineLabelColor = @"UnderlineLabelColor";
NSString *const kUnderlineLabelShouldDisplayGlyphFrame = @"UnderlineLabelShouldDisplayGlyphFrame";


@interface UnderlineAttributes()

@property (nonatomic) UIColor *color;
@property (nonatomic, assign) BOOL shouldDisplayGlyphFrame;

@end

@implementation UnderlineAttributes

+ (UnderlineAttributes *)attributeWithColor:(UIColor *)color
                    shouldDisplayGlyphFrame:(BOOL)glyphFrame{
    UnderlineAttributes *attributes = [UnderlineAttributes new];
    attributes.color = color;
    attributes.shouldDisplayGlyphFrame = glyphFrame;
    return attributes;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{kUnderlineLabelColor : self.color,
             kUnderlineLabelShouldDisplayGlyphFrame : @(self.shouldDisplayGlyphFrame)};
}

@end

@interface UnderlineLabel () <NSLayoutManagerDelegate>

@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSMutableArray *glyphLayers;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSTextStorage *textStorage;

@end

@implementation UnderlineLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTextKitStack];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupTextKitStack];
}

- (void)setBounds:(CGRect)bounds {
    self.textContainer.size = bounds.size;
    super.bounds = bounds;
}

- (void)setFrame:(CGRect)frame {
    self.textContainer.size = frame.size;
    super.frame = frame;
}

- (void)replaceGlyphAtIndex:(NSUInteger)index withLayer:(CALayer *)layer {
    if (index > self.glyphLayers.count)
        return;
    [self.glyphLayers replaceObjectAtIndex:index withObject:layer];
}

#pragma mark - Text Kit stack

- (void)setupTextKitStack {
    self.glyphLayers = [[NSMutableArray alloc] init];
    
    self.textStorage = [[NSTextStorage alloc] init];
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] initWithSize:self.frame.size];
    
    [self.layoutManager addTextContainer:self.textContainer];
    self.layoutManager.delegate = self;
    [self.textStorage addLayoutManager:self.layoutManager];
    
    [self setText:@""];
}

#pragma mark - UILabel

- (void)setText:(NSString *)text {
    NSRange wordRange = NSMakeRange(0, text.length);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)self.textColor.CGColor range:wordRange];
    [attributedText addAttribute:(NSString *)kCTFontAttributeName value:self.font range:wordRange];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:self.textAlignment];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wordRange];
    [self setAttributedText:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self.textStorage setAttributedString:attributedText];
}

- (void) setUnderlineToRange:(NSRange)range attributes:(NSDictionary *) attributes {
    NSArray *glyphTextLayers = [self glyphLayers];

    for (NSUInteger i = range.location; i < range.length; i++) {
        CALayer *glyphLayer = glyphTextLayers[i];
        if ([glyphLayer isKindOfClass:[CATextLayer class]]){
            CGRect originalFrame = glyphLayer.frame;
            CGRect originalBounds = glyphLayer.bounds;
            
            CALayer *bgLayer = [CALayer layer];
            bgLayer.frame = [self underlineBackgroundRect:originalBounds font:[(CATextLayer *)glyphLayer font]];
            UIColor *bgColor = attributes[kUnderlineLabelColor] ? : [UIColor clearColor];
            bgLayer.backgroundColor = bgColor.CGColor;
            
            BOOL shouldDisplayGlyphFrame = [(NSNumber *)attributes[kUnderlineLabelShouldDisplayGlyphFrame] boolValue];
            if (shouldDisplayGlyphFrame){
                bgLayer.borderColor = [UIColor redColor].CGColor;
                bgLayer.borderWidth = 0.5f;
            }
            glyphLayer.frame = originalBounds;
            
            CALayer *containerLayer = [CALayer layer];
            containerLayer.frame = originalFrame;
            [containerLayer addSublayer:bgLayer];
            [containerLayer addSublayer:glyphLayer];
            
            [self replaceGlyphAtIndex:i withLayer:containerLayer];
        }
    }
}

-(CGRect)underlineBackgroundRect:(CGRect)rect font:(CTFontRef)font{
    CGRect originalRect = rect;
    originalRect.origin.y =  CTFontGetAscent(font) / 2. + CTFontGetXHeight(font) / 2.;
    originalRect.size.height = CTFontGetSize(font) - (CTFontGetAscent(font) / 2. - CTFontGetXHeight(font) / 2. + 2 * CTFontGetDescent(font));
    return originalRect;
}

#pragma mark - UIView (Auto Layout)

- (CGSize)intrinsicContentSize
{
    // If Auto Layout is used to display the label, the intrinsicContentSize has to be slightly larger than the attributed text bounding rectangle
    // Otherwise the last two glyphs are merged together by the NSLayoutManager in a single rectangle
    
    CGRect labelRect = CGRectInset([self.textStorage boundingRectWithSize:CGSizeZero
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                                  context:nil], -self.font.pointSize / 6, 0.0f);
    return labelRect.size;
}

#pragma mark - NSLayoutManagerDelegate

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    [self.glyphLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        [layer removeFromSuperlayer];
    }];
    [self.glyphLayers removeAllObjects];
    
    NSRange textRange = NSMakeRange(0, self.textStorage.string.length);
    
    for (NSUInteger glyphIndex = textRange.location; glyphIndex < textRange.length + textRange.location; glyphIndex += 0) {
        
        NSRange glyphRange = NSMakeRange(glyphIndex, 1);
        
        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
        
        CATextLayer *glyphTextLayer = [CATextLayer layer];
        glyphTextLayer.contentsScale = [[UIScreen mainScreen] scale];
        glyphTextLayer.frame = glyphRect;
        NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
        NSAttributedString *attrString = [self.textStorage attributedSubstringFromRange:characterRange];
        NSRange range;
        NSDictionary *attributes = [attrString attributesAtIndex:0 effectiveRange:&range];
        
        UIFont *fontAttribute = attributes[NSFontAttributeName];
        glyphTextLayer.string = attrString;
        glyphTextLayer.font = (__bridge CFTypeRef _Nullable)(fontAttribute);
        glyphTextLayer.fontSize = fontAttribute.pointSize;
        
        [self.glyphLayers addObject:glyphTextLayer];
        
        glyphIndex += characterRange.length;
    }
    [self parseCustomAttributes:[self.textStorage attributedSubstringFromRange:textRange]];
    [self.glyphLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        [self.layer addSublayer:layer];
    }];
}

- (void)parseCustomAttributes:(NSAttributedString *)attributedString {
    self.textContainer.size = self.frame.size;

    [attributedString enumerateAttribute:kUnderlineLabelKey
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:0
                              usingBlock:^(NSDictionary *value, NSRange range, BOOL * _Nonnull stop) {
                                  if (!value)
                                      return;
                                  [self setUnderlineToRange:range attributes:value];
                                  
    }];
}
@end
