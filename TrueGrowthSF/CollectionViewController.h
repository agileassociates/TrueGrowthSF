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

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;


@end
