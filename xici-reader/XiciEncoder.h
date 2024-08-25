//
//  XiciEncoder.h
//  西祠利器
//
//  Created by Hanning Ni on 11/23/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XiciEncoder : NSObject

-(int) B:(int) n  :(int) c ;
-(int) S:(int) x :(int) y ;
-(int) M:(int) q :(int) a :(int) b :(int) x :(int)  s :(int)  t ;
-(int) F:(int) a :(int) b :(int) c :(int)d :(int) x :(int)s :(int)t;
-(int) G:(int) a :(int)b :(int)c :(int)d :(int)x :(int)s :(int)t ;
-(int) H:(int) a :(int)b :(int)c :(int)d :(int)x :(int)s :(int)t ;
-(int) I:(int) a :(int)b :(int)c :(int)d :(int)x :(int)s :(int)t  ;
-(NSString*)BH:(int[]) b :(int)length;
-(NSString*)C:(int[]) x :(int)xl :(int) l;
-(int*) SB:(NSString*)s  :(int) z;
-(NSString*) H2:(NSString*) s;
-(NSString*)  H2:(NSString*) s :(int) z ;
-(NSString*)  H22:(NSString*) s  :(NSString*) Z;
-(NSString*)  H22:(NSString*) s  :(int )z :(NSString*) S ;
-(NSString*)P:(NSString*) in_str;
-(NSString*)TitleEncode:(NSString*)str;


@end
