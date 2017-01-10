//
//  UICollectionViewController+U.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/29/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "CollectionViewController.h"
#import "UIKit+AFNetworking.h"
#import "PhotoHeaderView.h"
#import <CoreData/CoreData.h>
#import "AFNetworking.h"





@interface CollectionViewController ()


@end

@implementation CollectionViewController



- (void)viewDidLoad{
    
    [super viewDidLoad];
    
  //  self.urlArray = [NSMutableArray arrayWithObjects: @"https://s3-us-west-1.amazonaws.com/truegrowthsf/profiles/tech_chavis.jpeg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/messi.jpeg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/fruit_apple.jpg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/lebronking.jpg",  nil];
    
    _urlArray = [[NSMutableArray alloc] init];
    _userArray = [[NSMutableArray alloc] init];
    _userProfileArray = [[NSMutableArray alloc] init];
    _numberOfLikesArray = [[NSMutableArray alloc] init];
    _photoIdArray = [[NSMutableArray alloc] init];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    policy.allowInvalidCertificates = YES;
    
    manager.securityPolicy = policy;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingMutableContainers];
    
    
    [manager GET:@"https://true-growth-api.herokuapp.com/api/photos" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        // array for responseObject
        NSMutableArray *countArray = [[NSMutableArray alloc] init];
        [countArray addObject:responseObject[@"data"][0][@"attributes"][@"count"]];
        
        //NSMutableArray *coreData = [[NSMutableArray alloc] init];
        
        // convert array to string
        NSString *count = [countArray componentsJoinedByString:@"\n"];
        NSLog(@" count is %@", count);
        
        // log response object
        NSLog(@" response object: %@", responseObject);
        
        //convert string to int
        int j = count.intValue;
        
        NSLog(@" int count is %d", j);
        
        
        // Initialize CoreData...
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *photoURL = [NSEntityDescription insertNewObjectForEntityForName:@"AllPhotos" inManagedObjectContext:context];
        
        // loop through rrsponse which is coverted to string...
        int i = 0;
        for(i=0;i<j;i++){
            
            //NSMutableArray *urlArray = [[NSMutableArray alloc] init];
            //NSString *url = [urlArray componentsJoinedByString:@"\n"];
            // ... which is then inserted into core data
            //[photoURL setValue:url forKey:@"photo_name"];


            
            
            [_urlArray addObject:responseObject[@"data"][i][@"attributes"][@"url"]];
            [_userArray addObject:responseObject[@"data"][i][@"attributes"][@"user_name"]];
            [_userProfileArray addObject:responseObject[@"data"][i][@"attributes"][@"user_profile"]];
            [_numberOfLikesArray addObject:responseObject[@"data"][i][@"attributes"][@"likes"]];
            [_photoIdArray addObject:responseObject[@"data"][i][@"id"]];


            
            
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            
            
            
        }
        
        // ...fetch saved data into array
        //NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
       // NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"AllPhotos"];
       // coreData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
    
        NSLog(@"urlArray: %@", _urlArray);
        NSLog(@"userArray: %@", _userArray);
        NSLog(@"userProfileArray: %@", _userProfileArray);
        NSLog(@"likes: %@", _numberOfLikesArray);
        int countLikes = 0;
       
        NSLog(@"likes[2]: %@", _numberOfLikesArray[2]);

        
        
       [self.collectionView reloadData];

        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"error = %@", error);
        
    }];
    
    //_urlArray = [NSMutableArray arrayWithObjects: @"https://s3-us-west-1.amazonaws.com/truegrowthsf/profiles/tech_chavis.jpeg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/messi.jpeg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/fruit_apple.jpg", @"https://s3-us-west-1.amazonaws.com/truegrowthsf/photos/lebronking.jpg",  nil];



}

- (void)viewWillAppear:(BOOL)animated{
        //[self.collectionView reloadData];
    
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}



#pragma mark <UICollectionViewDataSource>

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PhotoHeaderView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionFooter withReuseIdentifier:@"PhotoHeaderView" forIndexPath:indexPath];
    return footerView;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _urlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = _userArray[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:200];
    
    UIImageView *userProfile = (UIImageView *)[cell viewWithTag:300];
    userProfile.layer.cornerRadius = userProfile.frame.size.height /2;
    userProfile.layer.masksToBounds = YES;
    userProfile.layer.borderWidth = 0;
    
    UILabel *labelNumberOfLikes = (UILabel *)[cell viewWithTag:400];
    
    
    int countLikes = 0;
    for(id key in _numberOfLikesArray[indexPath.row]){
        if([_numberOfLikesArray[indexPath.row][key] isEqual: @"yes"]){
            countLikes++;
        }
    }
    NSString *strx = [NSString stringWithFormat:@"%d", countLikes];

    
    labelNumberOfLikes.text = strx;

    


    
    
    //imageView.image = [UIImage imageNamed:@"FUTURITY.jpg"];
    
    
    //label.text = [array objectAtIndex:indexPath.row];
    
    // Configure the cell
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^ (void) {
        
       
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_urlArray[indexPath.row]]];
                             UIImage* image = [[UIImage alloc] initWithData:imageData];
                             if (image) {
                                 dispatch_async(dispatch_get_main_queue(), ^{

                                         imageView.image = image;
                                         [cell setNeedsDisplay];
                                 });
                             }
    });

    
    


    dispatch_async(queue, ^ {
    
    
    
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_userProfileArray[indexPath.row]]];
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
            
                userProfile.image = image;
                [cell setNeedsDisplay];
            });
        }
    });


return cell;
}




-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    }

- (IBAction)likeButtonClicked:(id)sender {
    UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    UILabel *labelNumberOfLikes = (UILabel *)[cell viewWithTag:400];
    
    NSString *user_id=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    int liked =0;
    
    NSMutableDictionary *numberOfLikesDict = [[NSMutableDictionary alloc] init];
    numberOfLikesDict = _numberOfLikesArray[indexPath.row];

    
    for(id key in numberOfLikesDict){
        if(key == user_id){
            liked = 1;
        }
    }


    int number = 0;
    if (liked == 1){
        number = labelNumberOfLikes.text.integerValue;
        number--;
        NSString *numberToText = [NSString stringWithFormat:@"%d", number];
        labelNumberOfLikes.text = numberToText;
        [numberOfLikesDict removeObjectForKey:user_id];

        
        // send post request to server
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES;
        manager.securityPolicy = policy;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"user_id"] = user_id;
        params[@"photo_id"] = _photoIdArray[indexPath.row];
        
        
        
        [manager POST:@"https://true-growth-api.herokuapp.com/api/photos/hated" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            if ( responseObject[@"errors"] == NULL){
                
                
                //NSLog(@"%@", responseObject[@"data"][@"attributes"][@"auth_token"]);
                NSLog(@"%@", responseObject);
                
            } else {
                
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Info"
                                              message:responseObject[@"errors"]
                                              preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
                
                [alert addAction:ok];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                NSLog(@"JSON: %@", responseObject[@"errors"]);
                
                
            }
            
            
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
            NSLog(@"error = %@", error);
            
        }];
        
        
        
        
        
    }else{
        number = labelNumberOfLikes.text.integerValue;
        number++;
        NSString *numberToText = [NSString stringWithFormat:@"%d", number];
        labelNumberOfLikes.text = numberToText;
        [numberOfLikesDict setObject:@"yes" forKey:user_id];
        
        
        
        
        // send post request to server
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES;
        manager.securityPolicy = policy;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"user_id"] = user_id;
        params[@"photo_id"] = _photoIdArray[indexPath.row];
        
        
        
        [manager POST:@"https://true-growth-api.herokuapp.com/api/photos/liked" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            if ( responseObject[@"errors"] == NULL){
                
                
                //NSLog(@"%@", responseObject[@"data"][@"attributes"][@"auth_token"]);
                NSLog(@"%@", responseObject);
                
            } else {
                
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Info"
                                              message:responseObject[@"errors"]
                                              preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
                
                [alert addAction:ok];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                NSLog(@"JSON: %@", responseObject[@"errors"]);
                
                
            }
            
            
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
            NSLog(@"error = %@", error);
            
        }];

        
    }

    
    

}

- (IBAction)favoritesButtonClicked:(id)sender {
    
    UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSString *photo_id = _photoIdArray[indexPath.row];
    
    NSDictionary *favorites = [[NSUserDefaults standardUserDefaults]
                               dictionaryForKey:@"favorites"];
    NSLog(@"Favorites: %@", favorites);
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    
    for(id key in favorites){
        if(key == photo_id){
            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            
            AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            policy.allowInvalidCertificates = YES;
            manager.securityPolicy = policy;
            
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
            
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            params[@"user_id"] = user_id;
            params[@"photo_id"] = _photoIdArray[indexPath.row];
            
            
            
            [manager POST:@"https://true-growth-api.herokuapp.com/api/users/unfavor" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ( responseObject[@"errors"] == NULL){
                    
                    
                    //NSLog(@"%@", responseObject[@"data"][@"attributes"][@"auth_token"]);
                    NSLog(@"%@", responseObject);
                    
                } else {
                    
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Info"
                                                  message:responseObject[@"errors"]
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                    
                    [alert addAction:ok];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    NSLog(@"JSON: %@", responseObject[@"errors"]);
                    
                    
                }
                
                
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                
                NSLog(@"error = %@", error);
                
            }];
            
            NSMutableDictionary *favoritesDictionary = [[NSMutableDictionary alloc] init];
            favoritesDictionary = [favorites mutableCopy];
            [favoritesDictionary removeObjectForKey:photo_id];
            
            [[NSUserDefaults standardUserDefaults] setObject:favoritesDictionary forKey:@"favorites"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            
        } else{
            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            
            AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            policy.allowInvalidCertificates = YES;
            manager.securityPolicy = policy;
            
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
            
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            params[@"user_id"] = user_id;
            params[@"photo_id"] = _photoIdArray[indexPath.row];
            params[@"photo_url"] = _urlArray[indexPath.row];
            
            [manager POST:@"https://true-growth-api.herokuapp.com/api/users/favor" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ( responseObject[@"errors"] == NULL){
                    
                    
                    //NSLog(@"%@", responseObject[@"data"][@"attributes"][@"auth_token"]);
                    NSLog(@"%@", responseObject);
                    
                } else {
                    
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Info"
                                                  message:responseObject[@"errors"]
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                    
                    [alert addAction:ok];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    NSLog(@"JSON: %@", responseObject[@"errors"]);
                    
                    
                }
                
                
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                
                NSLog(@"error = %@", error);
                
            }];

            NSMutableDictionary *favoritesDictionary = [[NSMutableDictionary alloc] init];
            favoritesDictionary = [favorites mutableCopy];
            NSString *url = _urlArray[indexPath.row];
            favoritesDictionary[photo_id] = url;
            
            [[NSUserDefaults standardUserDefaults] setObject:favoritesDictionary forKey:@"favorites"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            

        }
        
    };


    
    
}


@end

