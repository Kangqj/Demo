//
//  NoteCollectionViewCell.h
//  CrashDemo
//
//  Created by kangqijun on 2018/2/9.
//  Copyright © 2018年 康起军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteModel.h"

@interface NoteCollectionViewCell : UICollectionViewCell
{
    UILabel *nameLab;
    UIImageView *bgImageView;
    
}

- (void)loadData:(NoteModel *)note;

@end
