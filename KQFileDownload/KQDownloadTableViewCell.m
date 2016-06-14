//
//  KQDownloadTableViewCell.m
//  KQFileDownload
//
//  Created by keqi on 16/6/13.
//  Copyright © 2016年 keqi. All rights reserved.
//

#import "KQDownloadTableViewCell.h"
#import "MMFileDownloadVO.h"


@interface KQDownloadTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation KQDownloadTableViewCell

- (void)setModel:(MMFileDownloadVO *)model {
    if (_model != model) {
        _model = model;
    }
    
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", model.progress * 100];
    [self.progressView setProgress:model.progress];
    self.statusLabel.text = model.statusText;
    self.titleLabel.text = model.fileName;
}
@end
