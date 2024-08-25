//
//  DegreeIndicatorView.h
//  西祠利器
//
//  Created by Hanning Ni on 11/29/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DegreeIndicatorView : UIView{
    double degree;
    
}

@property (assign) double  degree;//[0,5]
@property (assign) UIColor* color;

@end
