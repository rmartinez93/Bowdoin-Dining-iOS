//
//  LYRObjectController.h
//  LayerKit
//
//  Created by Klemen Verdnik on 22/11/13.
//  Copyright (c) 2013 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRObjectControllerProtocol.h"
#import <CoreData/CoreData.h>

@class LYRClient;
@class LYRObjectController;

typedef NS_ENUM(NSInteger, LYRObjectControllerChange) {
    LYRObjectControllerChangeInsert = 1,
    LYRObjectControllerChangeDelete = 2,
    LYRObjectControllerChangeMove = 3,
    LYRObjectControllerChangeUpdate = 4,
};

@interface LYRObjectController : NSObject <LYRObjectControllerProtocol, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id<LYRObjectControllerDelegate> delegate;
@property (nonatomic, readonly) LYRClient *layerClient;
@property (nonatomic) NSPredicate *predicate;
@property (nonatomic) NSArray *sortDescriptors;
@property (nonatomic) NSInteger fetchLimit;
@property (nonatomic) NSInteger fetchOffset;
@property (nonatomic) NSInteger fetchBatchSize;
@property (nonatomic, readonly) NSString *sectionNameKeyPath;

@end

@protocol LYRObjectControllerDelegate <NSObject>

@optional
- (void)objectControllerWillChangeContent:(id<LYRObjectControllerProtocol>)controller;

- (void)objectControllerDidChangeContent:(id<LYRObjectControllerProtocol>)controller;

- (void)objectController:(id<LYRObjectControllerProtocol>)objectController
         didChangeObject:(id)object
             atIndexPath:(NSIndexPath*)indexPath
           forChangeType:(LYRObjectControllerChange)changeType
            newIndexPath:(NSIndexPath*)newIndexPath;

- (void)objectController:(id<LYRObjectControllerProtocol>)controller
        didChangeSection:(id<LYRSectionInfoProtocol>)sectionInfo
                 atIndex:(NSUInteger)sectionIndex
           forChangeType:(LYRObjectControllerChange)changeType;

@end

@interface LYRSectionInfo : NSObject <LYRSectionInfoProtocol>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;

@end
