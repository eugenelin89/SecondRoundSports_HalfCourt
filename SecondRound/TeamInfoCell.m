//
//  TeamInfoCell.m
//  SecondRound
//
//  Created by Eugene Lin on 13-04-16.
//  Copyright (c) 2013 S5 Software. All rights reserved.
//

#import "TeamInfoCell.h"

@interface TeamInfoCell()<UITextViewDelegate>
@property (nonatomic) BOOL isClean;
@end

@implementation TeamInfoCell

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

-(void)updateCell
{
    [self resetTextView];
    self.teamInfoTextView.delegate = self;
}

#pragma mark - UITextFieldDelegate delegate methods
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    return true;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(!self.isClean && [[self.teamInfoTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        [self resetTextView];
    }
    return true;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if([self.cellType isEqualToString:TEAM_NAME_CELL]){
            [self.delegate nextButtonPressed];
        }else{
            [textView resignFirstResponder];
        }
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }else{
        if(self.isClean){
            self.isClean = NO;
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
        // For any other character return TRUE so that the text gets added to the view
        return TRUE;
    }
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if(self.isClean)
    {
        NSRange beginningRange = NSMakeRange(0, 0);
        NSRange currentRange = [textView selectedRange];
        if(!NSEqualRanges(beginningRange, currentRange))
            [textView setSelectedRange:beginningRange];
    }
}

#pragma mark - Private Helper Methods
-(void)resetTextView
{
    if(self.cellType == TEAM_NAME_CELL){
        self.teamInfoTextView.text = TEAM_NAME_TITLE_TEXT;
        self.teamInfoTextView.returnKeyType = UIReturnKeyNext;
        
    }else{
        self.teamInfoTextView.text = TEAM_DESC_TITLE_TEXT;
        self.teamInfoTextView.returnKeyType = UIReturnKeyDone;
    }
    self.teamInfoTextView.textColor = [UIColor lightGrayColor];
    self.isClean = YES;
}


@end
