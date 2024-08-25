//
//  AFCollectionViewFlowLargeLayout.m
//  UICollectionViewFlowLayoutExample
//
//  Created by Ash Furrow on 2013-02-05.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFCollectionViewFlowLargeLayout.h"

@implementation AFCollectionViewFlowLargeLayout

-(id)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(100, 100);
    self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    self.minimumInteritemSpacing = 2.0f;
    self.minimumLineSpacing = 2.0f;
    
    return self;
}

@end
