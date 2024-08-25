//
//  AuthorCell.h
//  西祠利器
//
//  Created by Hanning Ni on 12/2/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AuthorCell : UITableViewCell{
     
}

@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *userImageView;
@property (nonatomic, strong) IBOutlet UIImageView *plusImageView;


@property (nonatomic, strong) User* user;

-(void)setupUser:(User*)user;

-(void)toggleSelection;

@end
