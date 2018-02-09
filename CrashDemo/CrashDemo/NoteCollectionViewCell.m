//
//  NoteCollectionViewCell.m
//  CrashDemo
//
//  Created by kangqijun on 2018/2/9.
//  Copyright © 2018年 康起军. All rights reserved.
//

#import "NoteCollectionViewCell.h"

@implementation NoteCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
        bgView.backgroundColor = [UIColor clearColor];
        bgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bgView.layer.shadowColor = [UIColor grayColor].CGColor;
        bgView.layer.shadowOffset = CGSizeMake(5, 5);
        bgView.layer.cornerRadius = 8;
        [self addSubview:bgView];
        bgView.clipsToBounds = YES;
        
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height-40)];
        [bgView addSubview:bgImageView];
        
        nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height-40, bgView.frame.size.width, 40)];
        nameLab.textColor = [UIColor whiteColor];
        nameLab.backgroundColor = [UIColor brownColor];
        nameLab.font = [UIFont systemFontOfSize:14];
        nameLab.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:nameLab];
    }
    
    return self;
}

- (void)loadData:(NoteModel *)note
{
    nameLab.text = note.name;
    bgImageView.image = [UIImage imageWithContentsOfFile:note.imagePath];
}


@end
