//
//  ReflectionView.h
//
//  Version 1.1
//
//  Created by Nick Lockwood on 19/07/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from either of these locations:
//http://charcoaldesign.co.uk/source/cocoa#reflectionview
//  
//  https://github.com/nicklockwood/ReflectionView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

//
//  ARC Helper
//
//  Version 2.1
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef ah_retain
#if __has_feature(objc_arc)
#define ah_retain self
#define ah_dealloc self
#define release self
#define autorelease self
#else
#define ah_retain retain
#define ah_dealloc dealloc
#define __bridge
#endif
#endif

//  ARC Helper ends


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface ReflectionView : UIView

@property (nonatomic, assign) CGFloat reflectionGap;
@property (nonatomic, assign) CGFloat reflectionScale;
@property (nonatomic, assign) CGFloat reflectionAlpha;
@property (nonatomic, assign) BOOL dynamic;

@property (nonatomic, retain) NSObject* relatedObject;

- (void)update;

@end