//
//  ViewController.m
//  DropAndDrop
//
//  Created by xiwang wang on 2017/11/30.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

#import "ViewController.h"
#import "DropCollectionViewCell.h"

static NSString *kImageCellIdentifier = @"kImageCellIdentifier";
static NSString *kItemForTypeIdentifier = @"kItemForTypeIdentifier";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSIndexPath *dragIndexPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.dropDelegate = self;
    _collectionView.dragDelegate = self;
    _collectionView.dragInteractionEnabled = true;
    _collectionView.reorderingCadence = UICollectionViewReorderingCadenceImmediate;
    _collectionView.springLoaded = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark - UICollectionViewDragDelegate
- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath{
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.item]];
        [itemProvider registerItemForTypeIdentifier:kItemForTypeIdentifier loadHandler:^(NSItemProviderCompletionHandler  _Null_unspecified completionHandler, Class  _Null_unspecified __unsafe_unretained expectedValueClass, NSDictionary * _Null_unspecified options) {
        NSLog(@"--------%@", options);
    }];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    self.dragIndexPath = indexPath;
    return @[item];
}

- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point{
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.item]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    return @[item];
}

- (UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 80, 80) cornerRadius:5];
    parameters.backgroundColor = [UIColor clearColor];
    return parameters;
}

- (void)collectionView:(UICollectionView *)collectionView dragSessionWillBegin:(id<UIDragSession>)session{
    NSLog(@"drag begin");
}

- (void)collectionView:(UICollectionView *)collectionView dragSessionDidEnd:(id<UIDragSession>)session{
    NSLog(@"drag end");
}

#pragma mark - UICollectionViewDropDelegate
- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator{
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;
    UIDragItem *dragItem = coordinator.items.firstObject.dragItem;
    NSString *imageName = self.dataSource[self.dragIndexPath.row];
    if ([dragItem.itemProvider canLoadObjectOfClass:[NSString class]]) {
        [dragItem.itemProvider loadObjectOfClass:[NSString class] completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
            UIImage *image = (UIImage *)object;
        }];
    }
    
    if (self.dragIndexPath.section == destinationIndexPath.section && self.dragIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    [_collectionView performBatchUpdates:^{
        [self.dataSource removeObjectAtIndex:self.dragIndexPath.item];
        [self.dataSource insertObject:imageName atIndex:destinationIndexPath.row];
    } completion:^(BOOL finished) {
        if (finished) {
            [_collectionView reloadData];
        }
    }];
    
    [coordinator dropItem:dragItem toItemAtIndexPath:destinationIndexPath];
    
}

- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath{
    UICollectionViewDropProposal *dropProposal;
    if (session.localDragSession) {
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }else{
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }
    return dropProposal;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canHandleDropSession:(id<UIDropSession>)session{
//    if (!session.localDragSession) {
//        return NO;
//    }
    return YES;
}

/* 当drop会话进入到 collectionView 的坐标区域内就会调用，
 * 早于- [collectionView dragSessionWillBegin] 调用
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnter:(id<UIDropSession>)session {
    NSLog(@"dropSessionDidEnter --> dropSession进入目标区域");
}

/* 当 dropSession 不在collectionView 目标区域的时候会被调用
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidExit:(id<UIDropSession>)session {
    NSLog(@"dropSessionDidExit --> dropSession 离开目标区域");
}

/* 当dropSession 完成时会被调用，不管结果如何
 * 适合在这个方法里做一些清理的操作
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnd:(id<UIDropSession>)session {
    NSLog(@"dropSessionDidEnd --> dropSession 已完成");
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DropCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.dataSource[indexPath.row]];
    return cell;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (NSInteger i = 0; i <= 33; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"thumb%ld", i]];
            [tempArray addObject:[NSString stringWithFormat:@"thumb%ld", i]];
        }
        _dataSource = tempArray;
    }
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
