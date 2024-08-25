//
//  AuthorCell.m
//  西祠利器
//
//  Created by Hanning Ni on 12/2/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "AuthorCell.h"




@implementation AuthorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)toggleSelection{
    self.user.isSelectedInUI = !self.user.isSelectedInUI;
    self.plusImageView.hidden = !self.user.isSelectedInUI;
}

-(void)setupUser:(User*)auser{
    self.user = auser;
     self.plusImageView.hidden = !self.user.isSelectedInUI;
    if ( auser.userIcon )
        self.userImageView.image = [UIImage imageWithData:self.user.userIcon];
    self.userNameLabel.text = auser.userName;
}

@end
