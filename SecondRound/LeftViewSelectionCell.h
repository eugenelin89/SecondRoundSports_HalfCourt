//
//  LeftViewSelectionCell.h
//  Second Date
//
//  Created by Eugene Lin on 13-04-12.
//  Copyright (c) 2013 Second Date. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftViewSelectionCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UIView *leftCellView;

@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@end
