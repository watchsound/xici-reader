//
//  XiciCategory.m
//  西祠利器
//
//  Created by Hanning Ni on 11/25/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "XiciCategory.h"

@implementation XiciCategory

@synthesize  categoryName;
@synthesize  categoryServerId;
@synthesize  defaultImageUid;


-(id)initWithName:(NSString*)name sid:(NSString*)serverId  image:(NSString*)imageUid {
    if ( self = [super init ] ){
        self.categoryName = name;
        self.categoryServerId = serverId;
        self.defaultImageUid = imageUid;
        
    }
    return self;
}

+ (NSMutableArray*) getDefaultCategoryList {
    NSMutableArray * list = [[NSMutableArray alloc] init];
    
     [list addObject:[[XiciCategory alloc] initWithName:@"媒体" sid:@"http://www.xici.net/media/" image:@"meiti.png"]];
    //  [list addObject:[[XiciCategory alloc] initWithName:@"花嫁" sid:@"http://huajia.xici.net/" image:@"huajia.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"亲子" sid:@"http://www.xici.net/baby" image:@"qinzi.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"汽车" sid:@"http://www.xici.net/auto/" image:@"qiche.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"旅行" sid:@"http://www.xici.net/travel/" image:@"luyou.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"摄影" sid:@"http://www.xici.net/photo/" image:@"sheyin.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"家居" sid:@"http://www.xici.net/owner/" image:@"jiaju.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"美食" sid:@"http://www.xici.net/food/" image:@"meishi.png"]];
     // [list addObject:[[XiciCategory alloc] initWithName:@"购物" sid:@"http://fashion.xici.net/" image:@"gouwu.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"时尚" sid:@"http://fashion.xici.net/" image:@"shishang.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"数码" sid:@"http://www.xici.net/it/" image:@"shuma.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"宠物" sid:@"http://www.xici.net/pet/" image:@"chongwu.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"情感" sid:@"http://www.xici.net/feeling/" image:@"qinggan.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"都市" sid:@"http://www.xici.net/life/" image:@"dushi.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"院校" sid:@"http://www.xici.net/school/" image:@"yuanxiao.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"教育" sid:@"http://www.xici.net/edu/" image:@"jiaoyu.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"人文" sid:@"http://www.xici.net/cul/" image:@"renwen.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"体育" sid:@"http://www.xici.net/sport/" image:@"tiyu.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"文艺" sid:@"http://www.xici.net/art/" image:@"wenyi.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"职场" sid:@"http://www.xici.net/work/" image:@"zhichang.png"]];
      [list addObject:[[XiciCategory alloc] initWithName:@"娱乐" sid:@"http://www.xici.net/ent/" image:@"yule.png"]];
 //   [list addObject:[[XiciCategory alloc] initWithName:@"囧友" sid:@"http://www.xici.net/jiong/" image:@"jiongyou.png"]];
    
    
    return list;
}


@end
