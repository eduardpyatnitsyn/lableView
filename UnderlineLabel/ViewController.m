//
//  ViewController.m
//  UnderlineLabel
//
//  Created by Эдуард Пятницын on 31.07.17.
//  Copyright © 2017 Эдуард Пятницын. All rights reserved.
//

#import "ViewController.h"
#import "UnderlineLabel.h"


@interface ViewController ()

@property (weak,nonatomic) IBOutlet UnderlineLabel *splitLabel;

@end

@implementation ViewController

- (IBAction)underline:(id)sender {
    self.splitLabel.attributedText = [self string];
}

- (IBAction)setNewText:(id)sender {
    NSString *str =@"Мы ебали медведЯ.МЫ ЕБАЛИ МЕДВЕДЯ.Бля буду, буду бля.БЛЯ БУДУ, БУДУ БЛЯ.Мишка плакал и стонал.МИШКА ПЛАКАЛ И СТОНАЛ.Попу лапой прикрывал.    ПОПУ ЛАПОЙ ПРИКРЫВАЛ.По делом ему теперь.ПО ДЕЛОМУ ЕМУ ТЕПЕРЬ.Во лохматый пидорас.ВО ЛОХМАТЫЙ ПИДОРАС.";

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.maximumLineHeight = 45;
    paragraphStyle.minimumLineHeight = 30;
    paragraphStyle.lineSpacing = 15;
    paragraphStyle.lineHeightMultiple = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    //    @{NSForegroundColorAttributeName:[UIColor blackColor],
//NSFontAttributeName:[UIFont boldSystemFontOfSize:16.],
//NSKernAttributeName:@(5),
    UnderlineAttributes *atrributes = [UnderlineAttributes attributeWithColor:[UIColor blueColor] shouldDisplayGlyphFrame:NO];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str attributes:@{
                                                                                        NSParagraphStyleAttributeName:paragraphStyle,
                                                                                        kUnderlineLabelKey:[atrributes dictionaryRepresentation]
                                                                                              }];
    self.splitLabel.attributedText = attrStr;
}

- (NSAttributedString *)string {
    UIFont *systemFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    // Create a paragraphStyle -
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.maximumLineHeight = 45;
    paragraphStyle.minimumLineHeight = 30;
    paragraphStyle.lineSpacing = 15;
    paragraphStyle.lineHeightMultiple = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UnderlineAttributes *atrributes = [UnderlineAttributes attributeWithColor:[UIColor blueColor] shouldDisplayGlyphFrame:NO];
    // create a dictionary of Attributed -
    NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:systemFont,  NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName, [atrributes dictionaryRepresentation], kUnderlineLabelKey ,nil];
    
    // create a Attributed  string and adding parameters dictionary-
    NSMutableAttributedString *libTitle = [[NSMutableAttributedString alloc] initWithString:@"Hello there, " attributes:fontAttributes];
    
    
    // create second Attributed  string with different font-
    UIFont *subTextFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50.0];
    
    NSDictionary * subTitlefontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:subTextFont, NSFontAttributeName, paragraphStyle,NSParagraphStyleAttributeName, nil];
    
    NSMutableAttributedString *subTitleString = [[NSMutableAttributedString alloc] initWithString:@"MacOS & iOS developments tips" attributes: subTitlefontAttributes];
    
    
    // Append Attributed string and create a single string-
    [libTitle appendAttributedString: subTitleString];
    return [libTitle copy];
}

@end
