//
//  UIImage+DrawInitialsOnImage.h
//  
//
//  Created by johnrhickey on 4/23/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (DrawInitialsOnImage)

+ (UIImage *)imageByDrawingInitialsOnImage:(UIImage *)image withInitials:(NSString *)initials withFontSize:(int)fontSize;

+ (UIImage *)imageByDrawingMovieNameOnImage:(UIImage *)image withMovieName:(NSString *)movieName withFontSize:(int)fontSize;

@end
