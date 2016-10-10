//
//  UIViewController+CameraView.m
//  TrueGrowthSF
//
//  Created by elliott chavis on 3/5/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import "CameraView.h"
#import "AFNetworking.h"
#import <AWSS3/AWSS3TransferManager.h>
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface CameraView () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation CameraView

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Put that image onto the screen in our image view
    self.pictureView.image = image;
    
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    
    
    //   http://stackoverflow.com/questions/4314405/how-can-i-get-the-name-of-image-picked-through-photo-library-in-iphone
    // get the ref url
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        NSLog(@"[imageRep filename] : %@", [imageRep filename]);
        NSString *photoName = [imageRep filename];
        
        // Initialize CoreData and save filename
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"UploadedPhoto" inManagedObjectContext:context];
        [newPhoto setValue:photoName forKey:@"name"];

    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    
    


    
}



- (IBAction)addPhotoClicked:(id)sender {
    
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    // If the device has a camera, take a picture, otherwise,
    // just pick from photo library
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:NULL];
    

}

- (IBAction)uploadPhotoClicked:(id)sender {
   // NSUUID *uuid = [[NSUUID alloc] init];
   // NSString *key = [uuid UUIDString];
    
    
    UIImage *image = self.pictureView.image;
    //NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    //convert uiimage to
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
     //NSString *fileName = [fileUrl lastPathComponent];
    
    
    
    // Fetch entity from CoreData
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadedPhoto" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        NSLog(@"%@", result);
    }
    
    
    
    
    // set param variables
    NSManagedObject *photo = (NSManagedObject *)[result objectAtIndex:0];
    NSString *photoName = [photo valueForKey:@"name"];
    NSLog(@"%@", photoName);
    
    NSString *user_id = @"1";
    NSString *url_suffix = photoName;
    
    // Upload to AWS
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"truegrowthsf/photos";
    uploadRequest.key = photoName;
    uploadRequest.body = fileUrl;
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.ACL = AWSS3BucketCannedACLPublicRead;

    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               // The file uploaded successfully.
                                                               
                                                               AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                                                               
                                                               AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
                                                               policy.allowInvalidCertificates = YES;
                                                               manager.securityPolicy = policy;
                                                               
                                                               manager.requestSerializer = [AFJSONRequestSerializer serializer];
                                                               
                                                               [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                                                               
                                                               
                                                               
                                                               NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                                               params[@"user_id"] = user_id;
                                                               params[@"url"] = url_suffix;
                                                               
                                                               [manager POST:@"https://true-growth-api.herokuapp.com/api/photos" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                                                                   
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
                                                           return nil;
                                                       }];
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;


    
    }

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];

}

@end
