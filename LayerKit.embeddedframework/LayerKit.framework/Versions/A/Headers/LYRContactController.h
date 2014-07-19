//
//  LYRContactController.h
//  LayerKit
//
//  Created by Klemen Verdnik on 24/11/13.
//  Copyright (c) 2013 Layer Inc. All rights reserved.
//

#import "LYRObjectController.h"
#import "LYRContact.h"

@class LYRClient;
@class LYRContactController;
@class LYRContactSectionInfo;

/**
 The `LYRContactControllerDelegate` protocol provides methods for notifying the adopting delegate that the controller’s fetch results (contacts) have been changed due to an add, remove, move, or update operations.
 */
@protocol LYRContactControllerDelegate <LYRObjectControllerDelegate>

@optional
/**
 @abstract Notifies the delegate that section and contacts changes are about to be processed and that notifications will be sent. Enables `LYRContactController` change tracking.
 @param controller The controller instance that noticed the change on its content.
 @discussion Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with `-beginUpdates`.
 */
- (void)objectControllerWillChangeContent:(LYRContactController*)controller;

/**
 @abstract Notifies the delegate that all section and contacts changes have been sent. Enables `LYRContactController` change tracking.
 @param controller The controller instance that noticed the change on its content.
 @discussion Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */
- (void)objectControllerDidChangeContent:(LYRContactController*)controller;

/**
 @abstract Notifies the delegate that a fetched contacts has been changed due to an add, remove, move, or update. Enables `LYRContactController` change tracking.
 @param objectController The controller instance that noticed the change on its fetched objects.
 @param contact An associated `LYRContact`.
 @param indexPath The indexPath of the changed contact (nil for inserts).
 @param changeType Indicates if the change was an insert, delete, move, or update.
 @param newIndexPath The destination path for inserted or moved contact, nil otherwise
 @discussion Changes are reported with the following heuristics:

 * On Adds and Removes, only the added/removed contact is reported. It's assumed that all contacts that come after the affected contact are also moved, but these moves are not reported.

 * The Move contact is reported when the changed attribute on the contact is one of the sort descriptors used in the fetch request. An update of the contact is assumed in this case, but no separate update message is sent to the delegate.
 
 * The Update contact is reported when an contact's state changes, and the changed attributes aren't part of the sort keys.
 */
- (void)objectController:(LYRContactController*)objectController
         didChangeObject:(LYRContact*)contact
             atIndexPath:(NSIndexPath*)indexPath
           forChangeType:(LYRObjectControllerChange)changeType
            newIndexPath:(NSIndexPath*)newIndexPath;

/**
 @abstract Notifies the delegate about added or removed sections. Enables `LYRContactController` change tracking.
 @param controller The controller instance that noticed the change on its sections.
 @param sectionInfo The changed section.
 @param sectionIndex The index of the changed section.
 @param changeType Indicates if the change was an insert or delete.
 */
- (void)objectController:(LYRContactController*)controller
        didChangeSection:(LYRContactSectionInfo*)sectionInfo
                 atIndex:(NSUInteger)sectionIndex
           forChangeType:(LYRObjectControllerChange)changeType;

@end

/**
 The `LYRContactController` class provides support of managing your UI controllers based on contact changes in LayerKit. It register and notifies your UI based on changes that happen internally in LayerKit: inserts, updates, deletions and index moves.
 */
@interface LYRContactController : LYRObjectController

/**
 @abstract The object that acts as the delegate of the receiving controller.
 */
@property (nonatomic, weak) id<LYRContactControllerDelegate> delegate;

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
 @abstract Number of contacts, that are available through contactAtIndexPath: method.
 */
@property (nonatomic, readonly) NSUInteger numberOfContacts;

/**
 @abstract Number of sections, that are available through sectionAtIndex: method.
 */
@property (nonatomic, readonly) NSUInteger numberOfSections;

/**
 @abstract Number of sections, that are available through sectionAtIndex: method.
 */

/*It's expected that developers call this method when implementing UITableViewDataSource's
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
 */
@property (nonatomic, readonly) NSArray *sectionIndexTitles;

/**
 @abstract Creates and returns an `LYRContactController` initialized using the given arguments.
 @param client Instance of LYRClient for which contacts changes are registered.
 @param predicate The predicate against which to evaluate items.
 @param sortDescriptors An array object containing the sort descriptors used for filtering items.
 @param fetchLimit The maximum number of displayed items.
 @param fetchOffset Display starting offset.
 @param sectionNameKeyPath The keyPath on the fetched objects used to determine the section they belong to.
 @return A `LYRContactController` instance with the specified `predicate`, `sortDescriptors`, `fetchLimit`, `fetchOffset` and `sectionNameKeyPath`.
 @discussion Creates an `LYRContactController` object that can be used for performing fetch requests. Note that `sectionNameKeyPath` cannot be changed once controller is initialized.
 */
- (id)initWithClient:(LYRClient *)client
           predicate:(NSPredicate *)predicate
     sortDescriptors:(NSArray *)sortDescriptors
          fetchLimit:(NSInteger)fetchLimit
         fetchOffset:(NSInteger)fetchOffset
  sectionNameKeyPath:(NSString *)sectionNameKeyPath;

/**
 @abstract Fetches the `LYRContact` object for given path. It is usually called inside tableView:cellForRowAtIndexPath: method, if implementing UITableViewDataSource delegate method.
 @param indexPath An index path with row and sections defined.
 @return A fetched `LYRContact` object for given `indexPath`.
 */
- (LYRContact*)contactAtIndexPath:(NSIndexPath*)indexPath;

/**
 @abstract Returns the index path of a given contact.
 @param contact A `LYRContact` in the controller's fetch results.
 @return The index path of contact in the controller's fetch results, or nil if contact could not be found.
 */
- (NSIndexPath*)indexPathForContact:(LYRContact*)contact;

/**
 @abstract Fetches the `LYRContactSectionInfo` object for given section index.
 @param sectionIndex A section index.
 @return A fetched `LYRContactSectionInfo` object for given `sectionIndex`.
 */
- (LYRContactSectionInfo*)sectionAtIndex:(NSUInteger)sectionIndex;

/**
 @abstract Updates fetched results based on controller's `predicate`, `sortDescriptors`, `fetchLimit`, `fetchOffset` and `sectionNameKeyPath`.
 @param completion Block method which is executed after the action completes. This block has no return value but passes an argument `error` - an `NSError` object containing error information in case the action was not successful. If the action was successful the argument `error` is `nil`.
 */
- (void)performUpdateWithCompletion:(void(^)(NSError *error))completion;

@end

/**
 The `LYRContactSectionInfo` defines the interface for section objects vended by an instance of `LYRContactController`.
 */
@interface LYRContactSectionInfo : LYRSectionInfo

/**
 @abstract The name of the section.
 */
@property (nonatomic, readonly) NSString *name;

/**
 @abstract The title of the section (used when displaying the index).
 */
@property (nonatomic, readonly) NSString *indexTitle;

/**
 @abstract The number of contacts in section.
 */
@property (nonatomic, readonly) NSUInteger numberOfContacts;

/**
 @abstract Fetches the `LYRContact` object for given index.
 @param index The message located at the index.
 @return Returns the `LYRContact` at the specified index of fetched section result.
 */
- (LYRContact*)contactAtIndex:(NSUInteger)index;

@end
