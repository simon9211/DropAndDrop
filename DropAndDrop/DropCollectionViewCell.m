//
//  DropCollectionViewCell.m
//  DropAndDrop
//
//  Created by xiwang wang on 2017/11/30.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

#import "DropCollectionViewCell.h"
@interface DropCollectionViewCell ()<UIDragInteractionDelegate>

@end
@implementation DropCollectionViewCell

- (void)enableDrag{
    if ([[UIDevice currentDevice].systemVersion hasPrefix:@"11"]) {
        UIDragInteraction *drag = [[UIDragInteraction alloc] initWithDelegate:self];
        self.userInteractionEnabled = true;
    }
}

- (NSArray *)itemsForSession:(id<UIDragSession>)session{
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:nil];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:provider];
    item.localObject = nil;
    return @[item];
}

- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session{
    NSArray *items = [self itemsForSession:session];
    return items;
}

@end
