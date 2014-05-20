//
//  UIImage+DrawInitialsOnImage.m
//  
//
//  Created by johnrhickey on 4/23/14.
//
//

#import "UIImage+DrawInitialsOnImage.h"
#import "CALayer+circleLayer.h"
#import "UIColor+customColors.h"

@implementation UIImage (DrawInitialsOnImage)

+ (UIImage *)imageByDrawingInitialsOnImage:(UIImage *)image withInitials:(NSString *)initials withFontSize:(int)fontSize
{
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    UIGraphicsGetCurrentContext();
    
    NSArray *separatedNames = [initials componentsSeparatedByString:@" "];
    
    NSMutableString *combinedInitials;
    // First name
    if ([separatedNames count] > 0) {
        // Use the first letter of the first name if the name length is > 1
        if ([separatedNames[0] length] > 1) {
            combinedInitials = [[NSMutableString alloc] initWithString:[separatedNames[0] substringToIndex:1]];
        }
        // Use the entire first name if the length is 1
        else {
            combinedInitials = [[NSMutableString alloc] initWithString:separatedNames[0]];
        }

        // Last name
        if ([separatedNames count] > 1) {
            // Use the first letter of the last name if the name length is > 1
            if ([separatedNames[1] length] > 1) {
                [combinedInitials appendString:[separatedNames[1] substringToIndex:1]];
            }
            // Use the entire first name if the length is 1
            else {
                [combinedInitials appendString:separatedNames[1]]; 
            }
        }
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentCenter;
        UIFont *textFont = [UIFont systemFontOfSize:fontSize];
        
        NSDictionary *attributes = @{NSFontAttributeName: textFont};
        
        // Create the CGRect to the size of the text box
        CGSize size = [combinedInitials sizeWithAttributes:attributes];
        if (size.width < image.size.width)
        {
            CGRect textRect = CGRectMake(0,
                                         (image.size.height - size.height)/2,
                                         image.size.width,
                                         (image.size.height - size.height));
            
            [combinedInitials drawInRect:textRect withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];
        }
    }
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (UIImage *)imageByDrawingMovieNameOnImage:(UIImage *)image withMovieName:(NSString *)movieName withFontSize:(int)fontSize
{
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    UIGraphicsGetCurrentContext();
        
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
        UIFont *textFont = [UIFont systemFontOfSize:fontSize];
    
    NSDictionary *attributes = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName: textStyle};
    
    // For setting the max length of the text
    CGFloat singleLineHeight = [movieName sizeWithAttributes:attributes].height;
    
    // Create the CGRect to the size of the text box
    CGRect bound = [movieName boundingRectWithSize:CGSizeMake(image.size.width-20, image.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGRect textRect = CGRectMake(10, (image.size.height - (bound.size.height))/2, image.size.width-20, (image.size.height - bound.size.height));

    // If the title is longer than 3 rows, trim it
    while ((singleLineHeight * 3) < bound.size.height) {
        // Trim the last word off the movie name and add an ellipsis
        NSRange range = [movieName rangeOfString: @" " options: NSBackwardsSearch];
        NSString *trimString = [movieName substringToIndex: range.location];
        movieName = [trimString stringByAppendingString:@"..."];
        
        // Set the rect
        bound = [movieName boundingRectWithSize:CGSizeMake(image.size.width-20, image.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        textRect = CGRectMake(10, (image.size.height - (bound.size.height))/2, image.size.width-20, (image.size.height - bound.size.height));
    }
    
    // Draw the text on the image
    [movieName drawInRect:textRect withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}


@end
