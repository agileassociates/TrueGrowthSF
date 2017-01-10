//
//  FavoritesCollectionViewController.m
//  TrueGrowthSF
//
//  Created by Johny Babylon on 1/9/17.
//  Copyright © 2017 Agile Associates. All rights reserved.
//

#import "FavoritesCollectionViewController.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"


@interface FavoritesCollectionViewController ()

@end

@implementation FavoritesCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
        // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int count = 0;
    NSDictionary *favorites = [[NSUserDefaults standardUserDefaults]
                               dictionaryForKey:@"favorites"];
    for(id key in favorites){
        count++;
    }
   
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell
    
    NSDictionary *favorites = [[NSUserDefaults standardUserDefaults]
                           dictionaryForKey:@"favorites"];
    NSLog(@"Favorites: %@", favorites);
    
    int number = 0;
    for(id key in favorites){
        number++;
    };


    
    if (number == 1){
        UILabel *label = (UILabel *)[cell viewWithTag:900];
        label.text = @"No Photos Selected";
        
    } else{
        
        NSArray *dictValues=[favorites allValues];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:200];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^ (void) {
            
            
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictValues[indexPath.row]]];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    imageView.image = image;
                    [cell setNeedsDisplay];
                });
            }
        });
        

        
    }

    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
