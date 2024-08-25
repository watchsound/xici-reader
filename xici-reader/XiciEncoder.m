//
//  XiciEncoder.m
//  西祠利器
//
//  Created by Hanning Ni on 11/23/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "XiciEncoder.h"

@implementation XiciEncoder

-(int)unsignedShiftBy:(int) value  :(int) shift{
    BOOL  isnegative = value < 0;
    int _value = value >>1;
    if ( isnegative ){
        _value &= ((1 << 31 ) -1);
    }
    if ( shift > 1 ){
        _value = _value >> (shift -1);
    }
    return _value;
}

-(int) B:(int) n  :(int) c {
    return (n << c) | [self unsignedShiftBy:n  :(32 - c )];
}

-(int) S:(int) x :(int) y  {
    int l = (x & 0xFFFF) + (y & 0xFFFF);
    int  w = (x >> 16) + (y >> 16) + (l >> 16);
    return (w << 16) | (l & 0xFFFF);
}

-(int) M:(int) q :(int) a :(int) b :(int) x :(int)  s :(int)  t {
    return  [self S:[self B:[self S :[self S:a :q] :[self S:x :t] ]  : s] :b];
}

-(int) F:(int) a :(int) b :(int) c :(int)d :(int) x :(int)s :(int)t{
    return    [self M: (b & c) | ((~b) & d)  :a  :b :x :s :t];
}

-(int) G:(int) a :(int)b :(int)c :(int)d :(int)x :(int)s :(int)t {
    return [self M:(b & d) | (c & (~d)) :a :b  :x  :s  :t];
}

-(int) H:(int) a :(int)b :(int)c :(int)d :(int)x :(int)s :(int)t {
    return [self M:b ^ c ^ d  :a :b :x :s :t];
}

-(int) I:(int) a :(int)b :(int)c :(int)d :(int)x :(int)s :(int)t  {
    return [self M:c ^ (b | (~d)) :a :b  :x :s :t];
}



-(NSString*)BH:(int[]) b :(int)length{
    NSString* h = @"0123456789ABCDEF";
    NSMutableString* sb = [[NSMutableString alloc] init];
    for ( int i = 0; i < length * 4; i++) {
        int pos = (b[i >> 2] >> ((i % 4) * 8 + 4)) & 0xF ;
        unichar c = [h characterAtIndex:pos ];
        [sb  appendString: [NSString stringWithCharacters:&c length:1]  ];
        pos = (b[i >> 2] >> ((i % 4) * 8)) & 0xF;
         c = [h characterAtIndex:pos ];
        [sb  appendString: [NSString stringWithCharacters:&c length:1]  ];
    }
    NSLog(@"BH =  %@", sb);
    return sb ;
}

-(NSString*)C:(int[]) x :(int)xl :(int) l{
     NSLog(@" l >> 5=   %i  %i  %i", l >> 5,  x[l >> 5] , 0x80 << ((l) % 32));
    x[l >> 5] |= 0x80 << ((l) % 32);
      NSLog(@" [self unsignedShiftBy:(l + 64)  :9] = %i", [self unsignedShiftBy:(l + 64)  :9]);
      NSLog(@"  ( [self unsignedShiftBy:(l + 64)  :9] << 4) + 14 = %i", ( [self unsignedShiftBy:(l + 64)  :9] << 4) + 14 );
      NSLog(@"   %c", (char)l);
    x[( [self unsignedShiftBy:(l + 64)  :9] << 4) + 14] = l ;//(char)l;
    int a = 1732584193;
    int b = -271733879;
    int c = -1732584194;
    int d = 271733878;
    for(int i = 0 ; i < 30 ; i++){
        NSLog(@"%i", x[i]);
    }
    for ( int i = 0; i < xl - 1000 ; i += 16) {
        int oa = a;
        int ob = b;
        int oc = c;
        int od = d;
        a = [self F:a  :b  :c  :d  :x[i + 0]  :7  :-680876936  ];
          NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self F:d  :a  :b  :c  :x[i + 1]  :12  :-389564586  ];
         NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self F:c  :d  :a  :b  :x[i + 2]  :17  :606105819  ];
         NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self F:b  :c  :d  :a  :x[i + 3]  :22  :-1044525330  ];
         NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self F:a  :b  :c  :d  :x[i + 4]  :7  :-176418897  ];
         NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self F:d  :a  :b  :c  :x[i + 5]  :12  :1200080426  ];
         NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self F:c  :d  :a  :b  :x[i + 6]  :17  :-1473231341  ];
        NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self F:b  :c  :d  :a  :x[i + 7]  :22  :-45705983  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self F:a  :b  :c  :d  :x[i + 8]  :7  :1770035416  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self F:d  :a  :b  :c  :x[i + 9]  :12  :-1958414417  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self F:c  :d  :a  :b  :x[i + 10]  :17  :-42063  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self F:b  :c  :d  :a  :x[i + 11]  :22  :-1990404162  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self F:a  :b  :c  :d  :x[i + 12]  :7  :1804603682  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self F:d  :a  :b  :c  :x[i + 13]  :12  :-40341101  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self F:c  :d  :a  :b  :x[i + 14]  :17  :-1502002290  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self F:b  :c  :d  :a  :x[i + 15]  :22  :1236535329  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self G:a  :b  :c  :d  :x[i + 1]  :5  :-165796510  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self G:d  :a  :b  :c  :x[i + 6]  :9  :-1069501632  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self G:c  :d  :a  :b  :x[i + 11]  :14  :643717713  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self G:b  :c  :d  :a  :x[i + 0]  :20  :-373897302  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self G:a  :b  :c  :d  :x[i + 5]  :5  :-701558691  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self G:d  :a  :b  :c  :x[i + 10]  :9  :38016083  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self G:c  :d  :a  :b  :x[i + 15]  :14  :-660478335  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self G:b  :c  :d  :a  :x[i + 4]  :20  :-405537848  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self G:a  :b  :c  :d  :x[i + 9]  :5  :568446438  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self G:d  :a  :b  :c  :x[i + 14]  :9  :-1019803690  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self G:c  :d  :a  :b  :x[i + 3]  :14  :-187363961  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self G:b  :c  :d  :a  :x[i + 8]  :20  :1163531501  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self G:a  :b  :c  :d  :x[i + 13]  :5  :-1444681467  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self G:d  :a  :b  :c  :x[i + 2]  :9  :-51403784  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self G:c  :d  :a  :b  :x[i + 7]  :14  :1735328473  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self G:b  :c  :d  :a  :x[i + 12]  :20  :-1926607734  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self H:a  :b  :c  :d  :x[i + 5]  :4  :-378558  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self H:d  :a  :b  :c  :x[i + 8]  :11  :-2022574463  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self H:c  :d  :a  :b  :x[i + 11]  :16  :1839030562  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self H:b  :c  :d  :a  :x[i + 14]  :23  :-35309556  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self H:a  :b  :c  :d  :x[i + 1]  :4  :-1530992060  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self H:d  :a  :b  :c  :x[i + 4]  :11  :1272893353  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self H:c  :d  :a  :b  :x[i + 7]  :16  :-155497632  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self H:b  :c  :d  :a  :x[i + 10]  :23  :-1094730640  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self H:a  :b  :c  :d  :x[i + 13]  :4  :681279174  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self H:d  :a  :b  :c  :x[i + 0]  :11  :-358537222  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self H:c  :d  :a  :b  :x[i + 3]  :16  :-722521979  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self H:b  :c  :d  :a  :x[i + 6]  :23  :76029189  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self H:a  :b  :c  :d  :x[i + 9]  :4  :-640364487  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self H:d  :a  :b  :c  :x[i + 12]  :11  :-421815835  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self H:c  :d  :a  :b  :x[i + 15]  :16  :530742520  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self H:b  :c  :d  :a  :x[i + 2]  :23  :-995338651  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self I:a  :b  :c  :d  :x[i + 0]  :6  :-198630844  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self I:d  :a  :b  :c  :x[i + 7]  :10  :1126891415  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self I:c  :d  :a  :b  :x[i + 14]  :15  :-1416354905  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self I:b  :c  :d  :a  :x[i + 5]  :21  :-57434055  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self I:a  :b  :c  :d  :x[i + 12]  :6  :1700485571  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self I:d  :a  :b  :c  :x[i + 3]  :10  :-1894986606  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self I:c  :d  :a  :b  :x[i + 10]  :15  :-1051523  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self I:b  :c  :d  :a  :x[i + 1]  :21  :-2054922799  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self I:a  :b  :c  :d  :x[i + 8]  :6  :1873313359  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self I:d  :a  :b  :c  :x[i + 15]  :10  :-30611744  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self I:c  :d  :a  :b  :x[i + 6]  :15  :-1560198380  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self I:b  :c  :d  :a  :x[i + 13]  :21  :1309151649  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self I:a  :b  :c  :d  :x[i + 4]  :6  :-145523070  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        d = [self I:d  :a  :b  :c  :x[i + 11]  :10  :-1120210379  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        c = [self I:c  :d  :a  :b  :x[i + 2]  :15  :718787259  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        b = [self I:b  :c  :d  :a  :x[i + 9]  :21  :-343485551  ]; NSLog(@"a = %i b= %i c= %i d = %i  x[i]= %i", a,b,c,d, x[i + 0]);
        a = [self S:a  :oa  ];
        b = [self S:b  :ob  ];
        c = [self S:c  :oc  ];
        d = [self S:d  :od  ];
    }
    NSLog(@"a = %i b= %i c= %i d = %i", a,b,c,d);
    int  value[] = {a, b, c, d};
    return [self BH:value :4];
}

-(int*) SB:(NSString*)s  :(int) z{
    int *b;   //add 16, arrays are different in java
    b = malloc(sizeof(int)*(s.length * z));
    for ( int i = 0; i < s.length * z; i ++)
        b[i] = 0;
    NSLog(@" size of int = %lu", sizeof(int) );
    int m = (1 << z) - 1;
    int max = 0;
    for ( int i = 0; i < s.length * z; i += z){
        int ii = i >> 5;
         NSLog(@"  = %i  = %i = %i = %i = %i", [self codePointAt:s    : (  i / z) ],
             [self codePointAt:s    : (  i / z) ] & m ,  i % 32 ,  (   [self codePointAt:s    : (  i / z) ] & m)    << (i % 32) , b[ii] );
        b[ii] |= (   [self codePointAt:s    : (  i / z) ] & m)    << (i % 32);
        NSLog(@"  = %i", b[ii]);
        if ( ii > max )
            max = ii;
    }
    NSLog(@"max = %i", max);
    int *bb; //add 16, arrays are different in java
     bb = malloc(sizeof(int)*(max + 1000));
    for( int i = 0; i < max + 1000; i++ ){
        if ( i < s.length * z )
            bb[i] = b[i];
        else
            bb[i] = 0;
    }
    free( b );
  //  for ( int i = 0; i < s.length * z; i ++)
     //   NSLog(@"%i", bb[i]);
    return bb;
}

-(int ) SB_Length:(NSString*)s  :(int) z{
    int *b;   //add 16, arrays are different in java
    b = malloc(sizeof(int)*(s.length * z));
    for ( int i = 0; i < s.length * z; i ++)
        b[i] = 0;
    
    int m = (1 << z) - 1;
    int max = 0;
    for ( int i = 0; i < s.length * z; i += z){
        int ii = i >> 5;
        b[ii] |= (   [self codePointAt:s  : (  i / z) ] & m)    << (i % 32);
        if ( ii > max )
            max = ii;
    }
    free( b );
    return max + 1000;
}

-(NSString*) H2:(NSString*) s{
    return [self H2:s  :16];
}

-(NSString*)  H2:(NSString*) s :(int) z {
    int* t  = [self SB:s :z] ;
    NSString* r =  [self C:t :[self SB_Length:s :z]  : s.length * z];
    free (t );
    return r;
}

-(NSString*)  H22:(NSString*) s  :(NSString*) Z{
    return [self H22:s :16 :Z];
}

-(NSString*)  H22:(NSString*) s  :(int )z :(NSString*) S {
    int* t  = [self SB:s :z] ;
    NSString* Z =  [NSString stringWithFormat:@"%@-%@", [self C:t :[self SB_Length:s :z]   :s.length * z], S];
    free (t);
    t = [self SB:Z :z];
    NSString* r =  [self C:t  :[self SB_Length:s :z]   :Z.length * z];
    free ( t );
    return r;
}



-(NSString*)P:(NSString*) in_str {
    //Pattern pattern = Pattern.compile("(<[^>]*>)|([ \f\n\r\t]*)");
    NSString* s = [in_str stringByReplacingOccurrencesOfString: @"(<[^>]*>)|([ \f\n\r\t]*)" withString: @""];
    int i = 0;
    for ( ; i < 32; i++) {
        NSString* t = [NSString stringWithFormat:@"&#%i%@", i,   @";"];
        NSString* r = [NSString stringWithFormat:@"%c", (char) i ];
        s = [s stringByReplacingOccurrencesOfString:t withString: r];
    //s = s.replace(new RegExp('&#' + i + ';', 'g'), String.fromCharCode(i));
    }
    
    NSArray * he = [NSArray arrayWithObjects : @"AElig", 198, @"Aacute", 193, @"Acirc", 194, @"Agrave",
        192, @"Alpha", 913, @"Aring", 197, @"Atilde", 195, @"Auml", 196,
        "Beta", 914, @"Ccedil", 199, @"Chi", 935, @"Dagger", 8225, @"Delta",
        916, @"ETH", 208, @"Eacute", 201, @"Ecirc", 202, @"Egrave", 200,
        "Epsilon", 917, @"Eta", 919, @"Euml", 203, @"Gamma", 915, @"Iacute",
        205, @"Icirc", 206, @"Igrave", 204, @"Iota", 921, @"Iuml", 207,
        "Kappa", 922, @"Lambda", 923, @"Mu", 924, @"Ntilde", 209, @"Nu", 925,
        "OElig", 338, @"Oacute", 211, @"Ocirc", 212, @"Ograve", 210, @"Omega",
        937, @"Omicron", 927, @"Oslash", 216, @"Otilde", 213, @"Ouml", 214,
        "Phi", 934, @"Pi", 928, @"Prime", 8243, @"Psi", 936, @"Rho", 929,
        "Scaron", 352, @"Sigma", 931, @"THORN", 222, @"Tau", 932, @"Theta",
        920, @"Uacute", 218, @"Ucirc", 219, @"Ugrave", 217, @"Upsilon", 933,
        "Uuml", 220, @"Xi", 926, @"Yacute", 221, @"Yuml", 376, @"Zeta", 918,
        "aacute", 225, @"acirc", 226, @"acute", 180, @"aelig", 230, @"agrave",
        224, @"alefsym", 8501, @"alpha", 945, @"and", 8869, @"ang", 8736,
        "aring", 229, @"asymp", 8773, @"atilde", 227, @"auml", 228, @"bdquo",
        8222, @"beta", 946, @"brvbar", 166, @"bull", 8226, @"cap", 8745,
        "ccedil", 231, @"cedil", 184, @"cent", 162, @"chi", 967, @"circ", 710,
        "clubs", 9827, @"cong", 8773, @"copy", 169, @"crarr", 8629, @"cup",
        8746, @"curren", 164, @"dArr", 8659, @"dagger", 8224, @"darr", 8595,
        "deg", 176, @"delta", 948, @"diams", 9830, @"divide", 247, @"eacute",
        233, @"ecirc", 234, @"egrave", 232, @"empty", 8709, @"emsp", 8195,
        "ensp", 8194, @"epsilon", 949, @"equiv", 8801, @"eta", 951, @"eth",
        240, @"euml", 235, @"euro", 8364, @"exist", 8707, @"fnof", 402,
        "forall", 8704, @"frac12", 189, @"frac14", 188, @"frac34", 190,
        "frasl", 8260, @"gamma", 947, @"ge", 8805, @"gt", 62, @"hArr", 8660,
        "harr", 8596, @"hearts", 9829, @"hellip", 8230, @"iacute", 237,
        "icirc", 238, @"iexcl", 161, @"igrave", 236, @"image", 8465, @"infin",
        8734, @"int", 8747, @"iota", 953, @"iquest", 191, @"isin", 8712,
        "iuml", 239, @"kappa", 954, @"lArr", 8656, @"lambda", 955, @"lang",
        9001, @"laquo", 171, @"larr", 8592, @"lceil", 8968, @"ldquo", 8220,
        "le", 8804, @"lfloor", 8970, @"lowast", 8727, @"loz", 9674, @"lrm",
        8206, @"lsaquo", 8249, @"lsquo", 8216, @"lt", 60, @"macr", 175,
        "mdash", 8212, @"micro", 181, @"middot", 183, @"minus", 8722, @"mu",
        956, @"nabla", 8711, @"nbsp", 160, @"ndash", 8211, @"ne", 8800, @"ni",
        8715, @"not", 172, @"notin", 8713, @"nsub", 8836, @"ntilde", 241, @"nu",
        957, @"oacute", 243, @"ocirc", 244, @"oelig", 339, @"ograve", 242,
        "oline", 8254, @"omega", 969, @"omicron", 959, @"oplus", 8853, @"or",
        8870, @"ordf", 170, @"ordm", 186, @"oslash", 248, @"otilde", 245,
        "otimes", 8855, @"ouml", 246, @"para", 182, @"part", 8706, @"permil",
        8240, @"perp", 8869, @"phi", 966, @"pi", 960, @"piv", 982, @"plusmn",
        177, @"pound", 163, @"prime", 8242, @"prod", 8719, @"prop", 8733,
        "psi", 968, @"quot", 34, @"rArr", 8658, @"radic", 8730, @"rang", 9002,
        "raquo", 187, @"rarr", 8594, @"rceil", 8969, @"rdquo", 8221, @"real",
        8476, @"reg", 174, @"rfloor", 8971, @"rho", 961, @"rlm", 8207,
        "rsaquo", 8250, @"rsquo", 8217, @"sbquo", 8218, @"scaron", 353,
        "sdot", 8901, @"sect", 167, @"shy", 173, @"sigma", 963, @"sigmaf", 962,
        "sim", 8764, @"spades", 9824, @"sub", 8834, @"sube", 8838, @"sum",
        8722, @"sup", 8835, @"sup1", 185, @"sup2", 178, @"sup3", 179, @"supe",
        8839, @"szlig", 223, @"tau", 964, @"there4", 8756, @"theta", 952,
        "thetasym", 977, @"thinsp", 8201, @"thorn", 254, @"tilde", 732,
        "times", 215, @"trade", 8482, @"uArr", 8657, @"uacute", 250, @"uarr",
        8593, @"ucirc", 251, @"ugrave", 249, @"uml", 168, @"upsih", 978,
        "upsilon", 965, @"uuml", 252, @"weierp", 8472, @"xi", 958, @"yacute",
        253, @"yen", 165, @"yuml", 255, @"zeta", 950, @"zwj", 8205, @"zwnj",
        8204, @"amp", 38, nil];
    
    for (int i = 0; i < [he count] / 2; i++){
        NSString* text = (NSString*) he[i * 2];
        char value =   (char) [ he[i * 2 + 1]  intValue];
        
        NSString* t = [NSString stringWithFormat:@"&%@;", text];
        NSString* r = [NSString stringWithFormat:@"%c", (char) value ];
        s = [s stringByReplacingOccurrencesOfString:t withString: r];
        
    }
    //	s = s.replace(new RegExp('&' + he[i * 2] + ';', 'g'), String
    //		.fromCharCode(he[i * 2 + 1]));
    s = [s stringByReplacingOccurrencesOfString:@"[^A-Za-z0-9_\u4e00-\u9fa5]" withString:@""];
    //s = s.replace(new RegExp('[^A-Za-z0-9_\u4e00-\u9fa5]', 'g'), '');
    return s;
}

-(NSString*)TitleEncode:(NSString*)str{
    
     str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
     str = [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
     return [str stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
}

-(int)codePointAt:(NSString*)str :(int)position {
    
    int  size = str.length;
    
        // Account for out-of-bounds indices:
    if (position < 0 || position >= size) {
        return 0;
    }
    // Get the first code unit
    int  first = [str characterAtIndex:position];
    int  second;
    if ( // check if it’s the start of a surrogate pair
        first >= 0xD800 && first <= 0xDBFF && // high surrogate
        size > position + 1 // there is a next code unit
        ) {
        second = [str characterAtIndex:position + 1];
        if (second >= 0xDC00 && second <= 0xDFFF) { // low surrogate
            // http://mathiasbynens.be/notes/javascript-encoding#surrogate-formulae
            return (first - 0xD800) * 0x400 + second - 0xDC00 + 0x10000;
        }
    }
    return first;
};

@end
