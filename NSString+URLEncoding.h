//
//  NSString+URLEncoding.h
//  TrueGrowthSF
//
//  Created by elliott chavis on 2/20/16.
//  Copyright © 2016 Agile Associates. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end