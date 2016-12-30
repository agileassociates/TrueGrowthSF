//
//  UICollectionViewController+U.h
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/29/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UICollectionViewController
    
@property (nonatomic, strong) NSMutableArray *urlArray;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) NSMutableArray *userProfileArray;
@property (nonatomic, strong) NSMutableArray *numberOfLikesArray;
@property (nonatomic, strong) NSMutableArray *photoIdArray;


@property (nonatomic) BOOL liked;
@property (nonatomic) int numberOfLikes;


-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;

- (IBAction)likeButtonClicked:(id)sender;

@end
