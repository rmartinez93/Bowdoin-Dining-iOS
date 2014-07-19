//
//  LYRMessageController.h
//  LayerKit
//
//  Created by Klemen Verdnik on 22/11/13.
//  Copyright (c) 2013 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRObjectController.h"
#import "LYRMessage.h"
#import "LYRClient.h"

@class LYRMessageController;
@class LYRMessageSectionInfo;

/**
 The `LYRMessageControllerDelegate` protocol provides methods for notifying the adopting delegate that the controller’s fetch results (messages) have been changed due to an add, remove, move, or update operations.
 */
@protocol LYRMessageControllerDelegate <LYRObjectControllerDelegate>

@optional
/**
 @abstract Notifies the delegate that section and message changes are about to be processed and that notifications will be sent. Enables `LYRMessageController` change tracking.
 @param controller The controller instance that noticed the change on its content.
 @discussion Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with `-beginUpdates`.
 */
- (void)objectControllerWillChangeContent:(id<LYRObjectControllerProtocol>)controller;

/**
 @abstract Notifies the delegate that all section and message changes have been sent. Enables `LYRMessageController` change tracking.
 @param controller The controller instance that noticed the change on its content.
 @discussion Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */
- (void)objectControllerDidChangeContent:(id<LYRObjectControllerProtocol>)controller;

/**
 @abstract Notifies the delegate that a fetched message has been changed due to an add, remove, move, or update. Enables `LYRMessageController` change tracking.
 @param objectController The controller instance that noticed the change on its fetched objects.
 @param message An associated `LYRMessage`.
 @param indexPath The indexPath of the changed message (nil for inserts).
 @param changeType Indicates if the change was an insert, delete, move, or update.
 @param newIndexPath The destination path for inserted or moved message, nil otherwise
 @discussion Changes are reported with the following heuristics:

 * On Adds and Removes, only the added/removed message is reported. It's assumed that all messages that come after the affected message are also moved, but these moves are not reported.

 * The Move message is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request. An update of the message is assumed in this case, but no separate update message is sent to the delegate.
 
 * The Update message is reported when an object's state changes, and the changed attributes aren't part of the sort keys.
 */
- (void)objectController:(LYRMessageController*)objectController
         didChangeObject:(LYRMessage*)message
             atIndexPath:(NSIndexPath*)indexPath
           forChangeType:(LYRObjectControllerChange)changeType
            newIndexPath:(NSIndexPath*)newIndexPath;

/**
 @abstract Notifies the delegate about added or removed sections. Enables `LYRMessageController` change tracking.
 @param controller The controller instance that noticed the change on its sections.
 @param sectionInfo The changed section.
 @param sectionIndex The index of the changed section.
 @param changeType Indicates if the change was an insert or delete.
 */
- (void)objectController:(LYRMessageController*)controller
        didChangeSection:(LYRMessageSectionInfo*)sectionInfo
                 atIndex:(NSUInteger)sectionIndex
           forChangeType:(LYRObjectControllerChange)changeType;

@end

/**
 The `LYRMessageController` class provides support of managing your UI controllers based on message changes in LayerKit. It register and notifies your UI based on changes that happen internally in LayerKit: inserts, updates, deletions and index moves.
 */
@interface LYRMessageController : LYRObjectController

/**
 @abstract The object that acts as the delegate of the receiving controller.
 */
@property (nonatomic, weak) id<LYRMessageControllerDelegate> delegate;

/**
 @abstract An instance of the LYRClient for which the controller was created for. 
 */
@property (nonatomic, weak, readonly) LYRClient *layerClient;

/**
 @abstract The predicate against which to evaluate items when displaying them.
 */
@property (nonatomic) NSPredicate *predicate;

/**
 @abstract An array of sort descriptors used for filtering items when displaying them.
 */
@property (nonatomic) NSArray *sortDescriptors;

/**
 @abstract The maximum number of displayed items.
 */
@property (nonatomic) NSInteger fetchLimit;

/**
 @abstract Display starting offset.
 */
@property (nonatomic) NSInteger fetchOffset;

/**
 @abstract Breaks the result set into batches of size.
 */
@property (nonatomic) NSInteger fetchBatchSize;

/**
 @abstract The keyPath on the fetched objects used to determine the section they belong to.
 */
@property (nonatomic, readonly) NSString *sectionNameKeyPath;

/**
 @abstract Number of messages, that are available through messageAtIndexPath: method.
 */
@property (nonatomic, readonly) NSUInteger numberOfMessages;

/**
 @abstract Number of sections, that are available through sectionAtIndex: method.
 */
@property (nonatomic, readonly) NSUInteger numberOfSections;

/**
 @abstract The section index titles.
 */
@property (nonatomic, readonly) NSArray *sectionIndexTitles;

/**
 @abstract Creates and returns an `LYRMessageController` initialized using the given arguments.
 @param client Instance of LYRClient for which message changes are registered.
 @param predicate The predicate against which to evaluate items.
 @param sortDescriptors An array object containing the sort descriptors used for filtering items.
 @param fetchLimit The maximum number of displayed items.
 @param fetchOffset Display starting offset.
 @param sectionNameKeyPath The keyPath on the fetched objects used to determine the section they belong to.
 @return A `LYRMessageController` instance with the specified `predicate`, `sortDescriptors`, `fetchLimit`, `fetchOffset` and `sectionNameKeyPath`.
 @discussion Creates an `LYRMessageController` object that can be used for performing fetch requests. Note that `sectionNameKeyPath` cannot be changed once controller is initialized.
 */
- (id)initWithClient:(LYRClient *)client
           predicate:(NSPredicate *)predicate
     sortDescriptors:(NSArray *)sortDescriptors
          fetchLimit:(NSInteger)fetchLimit
         fetchOffset:(NSInteger)fetchOffset
  sectionNameKeyPath:(NSString *)sectionNameKeyPath;


/**
 @abstract Fetches the `LYRMessage` object for given path. It is usually called inside tableView:cellForRowAtIndexPath: method, if implementing UITableViewDataSource delegate method.
 @param indexPath An index path with row and sections defined.
 @return A fetched `LYRMessage` object for given `indexPath`.
 */
- (LYRMessage*)messageAtIndexPath:(NSIndexPath*)indexPath;

/**
 @abstract Returns the index path of a given message.
 @param message A `LYRMessage` in the controller's fetch results.
 @return The index path of message in the controller's fetch results, or nil if message could not be found.
 */
- (NSIndexPath*)indexPathForMessage:(LYRMessage*)message;

/**
 @abstract Fetches the `LYRMessageSectionInfo` object for given section index.
 @param sectionIndex A section index.
 @return A fetched `LYRMessageSectionInfo` object for given `sectionIndex`.
 */
- (LYRMessageSectionInfo*)sectionAtIndex:(NSUInteger)sectionIndex;

/**
 @abstract Updates fetched results based on controller's `predicate`, `sortDescriptors`, `fetchLimit`, `fetchOffset` and `sectionNameKeyPath`.
 @param completion Block method which is executed after the action. This block has no return value but passes an argument `error` - an `NSError` object containing error information in case the action was not successful. If the action was successful the argument `error` is `nil`.
 */
- (void)performUpdateWithCompletion:(void(^)(NSError *error))completion;

@end

/**
 The `LYRMessageSectionInfo` defines the interface for section objects vended by an instance of `LYRMessageController`.
 */
@interface LYRMessageSectionInfo : LYRSectionInfo

/**
 @abstract The name of the section.
 */
@property (nonatomic, readonly) NSString *name;

/**
 @abstract The title of the section (used when displaying the index).
 */
@property (nonatomic, readonly) NSString *indexTitle;

/**
 @abstract The number of messages in section.
 */
@property (nonatomic, readonly) NSUInteger numberOfMessages;

/**
 @abstract Fetches the `LYRMessage` object for given index.
 @param index The message located at the index.
 @return Returns the `LYRMessage` at the specified index of fetched section result.
 */
- (LYRMessage*)messageAtIndex:(NSUInteger)index;

@end