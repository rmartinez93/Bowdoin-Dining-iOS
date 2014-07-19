//
//  LYRObjectControllerProtocol.h
//  LayerKit
//
//  Created by Klemen Verdnik on 22/11/13.
//  Copyright (c) 2013 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYRClient;

@protocol LYRSectionInfoProtocol;
@protocol LYRObjectControllerDelegate;

@protocol LYRObjectControllerProtocol <NSObject>

@required
@property (nonatomic, weak) id<LYRObjectControllerDelegate> delegate;
@property (nonatomic, readonly) LYRClient *layerClient;
@property (nonatomic) NSPredicate *predicate;
@property (nonatomic) NSArray *sortDescriptors;
@property (nonatomic) NSInteger fetchLimit;
@property (nonatomic) NSInteger fetchOffset;
@property (nonatomic) NSInteger fetchBatchSize;
@property (nonatomic, readonly) NSString *sectionNameKeyPath;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly) NSArray *sectionIndexTitles;

@required
- (void)performUpdateWithCompletion:(void(^)(NSError *error))completion;

- (id<LYRSectionInfoProtocol>)sectionAtIndex:(NSUInteger)sectionIndex;

- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName;

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex;

@end

@protocol LYRSectionInfoProtocol

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;

@end