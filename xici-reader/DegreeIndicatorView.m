//
//  DegreeIndicatorView.m
//  西祠利器
//
//  Created by Hanning Ni on 11/29/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "DegreeIndicatorView.h"

#define kNumBars 5

@interface DegreeIndicatorView()

@property (retain) UIImage* image;

@end


@implementation DegreeIndicatorView

@dynamic degree  ;
@synthesize color = _color;
@synthesize image = _image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(double)degree{
    return degree;
}

-(void)setDegree:(double)_degree{
    degree = _degree;
    self.image =  nil;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if ( !self.image ){
        double max_height = self.bounds.size.height;
        double max_width = self.bounds.size.width;
        
        double min_x_unit =  max_width / 14; // [5 bars with width of 2, and spaced with 1]
        
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(ctx, 1.0);
        
        for ( int i = 0; i < 5; i ++ ){
            double  x1 = min_x_unit *3 * i;
            double  x2 = x1 + min_x_unit * 2;
            double  y1 = max_height * x1 / max_width;
            double y2 = max_height * x2 /max_width;
            
            CGMutablePathRef pPath_0 = CGPathCreateMutable();
            
            CGPathMoveToPoint(pPath_0, nil,  x1 ,  max_height - 0);
            CGPathAddLineToPoint(pPath_0, nil, x1, max_height - y1);
            CGPathAddLineToPoint(pPath_0, nil, x2, max_height - y2);
            CGPathAddLineToPoint(pPath_0, nil, x2, max_height - 0);
            CGPathAddLineToPoint(pPath_0, nil, x1, max_height - 0 );
            CGPathCloseSubpath(pPath_0);
            
            CGContextAddPath(ctx, pPath_0);
            
            CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0.3 green:0.4 blue:0.5 alpha:0.5] CGColor]);
            CGContextDrawPath(ctx, kCGPathFill);
            CGContextFillPath(ctx);
            
            CGContextDrawPath(ctx, kCGPathStroke);
            CGPathRelease(pPath_0);
        }
        if (  degree == 0 )
            return;
        if ( degree > kNumBars )
            degree = kNumBars;
        
        double expected_width = max_width * degree / kNumBars;
        for ( int i = 0; i < 5; i ++ ){
            double  x1 = min_x_unit *3 * i;
            double  x2 = x1 + min_x_unit * 2;
            BOOL isEnd = FALSE;
            if ( x2 > expected_width ){
                isEnd = TRUE;
                x2 = expected_width;
            }
            
            double  y1 = max_height * x1 / max_width;
            double y2 = max_height * x2 /max_width;
            
            CGMutablePathRef pPath_0 = CGPathCreateMutable();
            
            CGPathMoveToPoint(pPath_0, nil,  x1 ,  max_height - 0);
            CGPathAddLineToPoint(pPath_0, nil, x1, max_height - y1);
            CGPathAddLineToPoint(pPath_0, nil, x2,  max_height -y2);
            CGPathAddLineToPoint(pPath_0, nil, x2, max_height - 0);
            CGPathAddLineToPoint(pPath_0, nil, x1, max_height - 0 );
            CGPathCloseSubpath(pPath_0);
            
            CGContextAddPath(ctx, pPath_0);
            
            CGContextSetFillColorWithColor(ctx, [self.color CGColor]);
            CGContextDrawPath(ctx, kCGPathFill);
            CGContextFillPath(ctx);
            
            CGContextDrawPath(ctx, kCGPathStroke);
            CGPathRelease(pPath_0);
            if ( isEnd )
                break;
        }
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        
    } else {
        [self.image drawInRect:rect];
    }
    
}


@end
