//
//  UICollectionViewController+U.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/29/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "CollectionViewController.h"
#import "UIKit+AFNetworking.h"



@interface CollectionViewController ()


@end

@implementation CollectionViewController





- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.urlArray = [NSMutableArray arrayWithObjects: @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/tech_chavis.jpeg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/messi.jpeg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/fruit_apple.jpg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/lebronking.jpg",  nil];
    



    
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.urlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    //UILabel *label = (UILabel *)[cell viewWithTag:100];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:200];
    
    
    //imageView.image = [UIImage imageNamed:@"FUTURITY.jpg"];
    
    
    //label.text = [array objectAtIndex:indexPath.row];
    
    // Configure the cell
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.urlArray[indexPath.row]]];
        
                             UIImage* image = [[UIImage alloc] initWithData:imageData];
                             if (image) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                         imageView.image = image;
                                         [cell setNeedsLayout];
                                 });
                             }
                             });
    
    
    
    return cell;
}
    




@end

