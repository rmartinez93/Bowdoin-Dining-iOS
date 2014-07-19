//
//  LYRClient.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/23/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRSessionInfo.h"
#import "LYRProfileInfo.h"
#import "LYRUserInfo.h"
#import "LYRContact.h"
#import "LYRMessage.h"
#import "LYRDevice.h"

#import "LYRObjectController.h"
#import "LYRContactController.h"
#import "LYRMessageController.h"

#import "LYRCommonError.h"
#import "LYRSessionError.h"
#import "LYRHeraldError.h"
#import "LYRMessageSyncError.h"

@class LYRClient;
@class LYRCall;

/**
 Possible client statuses.
 */

typedef NS_OPTIONS(NSUInteger, LYRClientStatus) {
    /** Initial status, before the client tries to connect. */
    LYRClientStatusInitial          = 1UL << 0,
    /** Session status indicating a session is about to open. */
    LYRClientStatusSessionOpening   = 1UL << 1,
    /** Session status indicating a session is open and running. */
    LYRClientStatusSessionOpen      = 1UL << 2,
    /** Session status indicating a session is closed. Check also StatusFailedAuth and StatusFailedTerminated.*/
    LYRClientStatusSessionClosed    = 1UL << 3,
    
    /** Flag indicating token is available in client. */
    LYRClientStatusTokenAvailable   = 1UL << 4,
    /** Flag indicating token has been refreshed. */
    LYRClientStatusTokenExtended    = 1UL << 5,
    /** Flag indicating session was closed because of authentication failure. */
    LYRClientStatusFailedAuth       = 1UL << 6,
    /** Flag indicating token session was terminated either because token has been revoked or expired beyond refresh (more info in NSError *). */
    LYRClientStatusFailedTerminated = 1UL << 7,

    /** Flag indicating client is in running state (it tries to reconnect upon broken connections). */
    LYRClientStatusRunning          = 1UL << 8,
    /** Flag indicating client is connected to Layer services and ready for communication. */
    LYRClientStatusConnected        = 1UL << 9,
    
    /** Flag indicating device has a connection to the internet. */
    LYRClientStatusWANAvailable     = 1UL << 10,
    /** Flag indicating device has a cellular connection. */
    LYRClientStatusWANAvailableCell = 1UL << 11,
    /** Flag indicating device has a WiFi connection. */
    LYRClientStatusWANAvailableWiFi = 1UL << 12,
};

#pragma mark - Client Delegate

/**
 The `LYRClientDelegate` protocol provides a method for notifying the adopting delegate about information changes.
 */

@protocol LYRClientDelegate <NSObject>

@optional

/**
 @abstract Called when client status changes.
 @param client The client calling the delegate method.
 @param status The new status of the client.
 @param error An `NSError` object that contains error information in case the action was not successful.
 */
- (void)layerClient:(LYRClient *)client didChangeStatus:(LYRClientStatus)status error:(NSError *)error;

/**
 @abstract Called when there's a progress update of the synchronization procedure
 @param client The client calling the delegate method
 @param tag Synchronization task tag (usefull for when you need to track the progress of each syncrhonization task)
 @param progress A `float` number representing the syncrhonization task progress.
 */
- (void)layerClient:(LYRClient *)client didReceiveSyncUpdateWithTag:(NSUInteger)tag progress:(float)progress;

/**
 @abstract Called when user info of the logged in user changes.
 @param client The client calling the delegate method.
 @param error An `NSError` object that contains error information in case the action was not successful.
 */
- (void)layerClient:(LYRClient *)client didChangeUserInfoWithError:(NSError *)error;

/**
 @abstract Called when contacts changed.
 @param client The client calling the delegate method.
 @param error An `NSError` object that contains error information in case the action was not successful.
 */
- (void)layerClient:(LYRClient *)client didChangeContactsWithError:(NSError *)error;

/**
 @abstract Called when a message has been received.
 @param client The client calling the delegate method.
 @param messages An array of received `LYRMessage` objects.
 */
- (void)layerClient:(LYRClient *)client didReceiveMessages:(NSArray *)messages;

/**
 @abstract Called when a message has been sent.
 @param client The client calling the delegate method.
 @param messages An NSArray of sent `LYRMessage` objects.
 */
- (void)layerClient:(LYRClient *)client didSendMessages:(NSArray *)messages;

/**
 @abstract Called when a call has been received.
 @param client The client calling the delegate method.
 @param call The received `LYRCall` object.
 */
- (void)layerClient:(LYRClient *)client didReceiveCall:(LYRCall *)call;

@end


#pragma mark - Client

/**
 The Layer client runs as a singleton inside the application and is accessible through the `sharedClient` method. All the methods are accessible as methods on the `sharedClient` object.
 Before starting the `sharedClient`, make sure you specify your app key. If you don't have an app key yet you can create one on Layer's administration pages http://layer.com/admin.
 */

@interface LYRClient : NSObject

/**
 @name Client
 */

/**
 @abstract The object that acts as the delegate of the receiving client.
 */
@property (nonatomic, weak) id <LYRClientDelegate> delegate;

/**
 @abstract The app key.
 @discussion Every time a new app key is set, the `sharedClient` needs to be restarted for the new app key to be used.
 */
@property (nonatomic) NSString *appKey;

/**
 @abstract A reference to the `LYRClient` singleton.
 */
+ (instancetype)sharedClient;

/**
 @abstract Signals the receiver to establish a network connection and sync all the data.
 */
- (void)start;

/**
 @abstract Signals the receiver to end the established network connection.
 */
- (void)stop;

/**
 @abstract Signals the LYRClient that a push notification arrived that indicates there is data to be fetched.
 @param completion This will get executed upon successful or failed background fetch. It includes an array of newly fetched messages `messagesFetched`, an array of updated messages `messagesUpdated` (recipients' states and/or message tags) and a stopHandler() which returns an appropriate UIBackgroundFetchResult and stops the ```LYRClient```. If background fetch failed, an instance of `NSError` describes the problem.
 @discussion Should be called from application:didReceiveRemoteNotification:fetchCompletionHandler: `UIApplicationDelegate` method to signal and forward all the arguments to the LYRClient instance. Also keep in mind that newly fetched messages do not include `LYRMessageBody` instances in `bodies` property.
 @see LYRMessage on how to fetch message bodies.
 */
- (void)performBackgroundFetchWithCompletion:(void (^)(NSArray *messagesFetched, NSArray *messagesUpdated, NSError *error, UIBackgroundFetchResult(^stopHandler)()))completion;

#pragma mark - Session

/**
 @name Session
 @discussion Methods for user authentication and session handling.
 */

/**
 @abstract The session info object provided by Layer after a successful authentication.
 @return The `LYRSessionInfo` object representing the current session.
 */
@property (nonatomic, readonly) LYRSessionInfo *sessionInfo;

/**
 @abstract The client status.
 */
@property (nonatomic, readonly) LYRClientStatus status;


/**
 @name User Authentication
 */

/**
 @abstract Check if user is authenticated.
 @return A Boolean value that determines whether a user is authenticated.
 */
- (BOOL)isUserAuthenticated;

/**
 @abstract Authenticates a user.
 @param username A string containing the user's username.
 @param password A string containing the user's password.
 @param completion Block method which is executed after the action. This block has no return value and takes the argument `error` - an `NSError` object containing error information in case the action was not successful. If the action was successful the argument `error` is `nil`. Note that `LYRClient` has to have a fully established connection in order to execute this method. You can check against `LYRClientStatusConnected` flag inside `status` property of `LYRClient`.
 */
- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password
                      completion:(void(^)(NSError *error))completion;

/**
 @abstract Opens a session with a token received from a server.
 @param accessToken A string containing the access token.
 @param completion Block method which is executed after the action. This block has no return value and takes the argument `error` - an `NSError` object containing error information in case the action was not successful. If the action was successful the argument `error` is `nil`. Note that `LYRClient` has to have a fully established connection in order to execute this method. You can check against `LYRClientStatusConnected` flag inside `status` property of `LYRClient`.
 */
- (void)openSessionWithToken:(NSString *)accessToken
                  completion:(void(^)(NSError *error))completion;

/**
 @abstract Unauthenticates a user.
 @param completion Block method which is executed after the action. This block has no return value and takes the argument `error` - an `NSError` object containing error information in case the action was not successful. If the action was successful the argument `error` is `nil`.
 @discussion Unauthentication process may take a while, because internal database gets pruned.
 */
- (void)logoutWithCompletion:(void(^)(NSError *error))completion;

#pragma mark - User

/**
 @name User
 @discussion Methods for user management, such as creation of a new user, updating the user information, removing the user and getting general user information.
 */

/**
 @abstract An `LYRUserInfo` object containing information about the autheticated user.
 */
@property (nonatomic, readonly) LYRUserInfo *userInfo;

/**
 @abstract Creates a new user with the provided information and if the user creation was successful it automatically establishes a session.
 @param username The user's username (required).
 @param password The user's password (required).
 @param firstName The user's firstName (optional).
 @param lastName The user's lastName (optional).
 @param emailAddress The user's emailAddress (optional).
 @param phoneNumber The user's phoneNumber (optional).
 @param completion Block method which is executed after the action. This block has no return value and takes the argument `error` - an `NSError` object containing error information in case the action was not successful. If the action was successful the argument `error` is `nil`. Note that `LYRClient` has to have a fully established connection in order to execute this method. You can check against `LYRClientStatusConnected` flag inside `status` property of `LYRClient`.
 */
- (void)signupWithUsername:(NSString *)username
                  password:(NSString *)password
                 firstName:(NSString *)firstName
                  lastName:(NSString *)lastName
              emailAddress:(NSString *)emailAddress
               phoneNumber:(NSString *)phoneNumber
                completion:(void(^)(NSError *error))completion;

/**
 @abstract Triggers the user information update action.
 @param userInfo An `LYRUserInfo` object containing the user's information.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion Local changes are reflected instantly and are synced with Layer cloud automatically depending on the network conditions.
 */
- (BOOL)updateUserInfo:(LYRUserInfo *)userInfo error:(NSError **)error;

/**
 @abstract Triggers the device token update action.
 @param deviceToken An `NSData` object containing the device token.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion The device token is expected to be an `NSData` object returned by the method application:didRegisterForRemoteNotificationsWithDeviceToken:. The device token is cached locally and is sent to Layer cloud automatically when the connection is established.
 */
- (BOOL)updateDeviceToken:(NSData *)deviceToken error:(NSError **)error;

/**
 @abstract An `LYRDevice` object containing information about the curent device.
 */
@property (nonatomic, readonly) LYRDevice *currentDevice;

#pragma mark - Contacts

/**
 @name Contacts
 @discussion Methods for adding or removing contacts, importing contacts from device and filtering contacts with custom predicates and sort descriptors.
 */

/**
 @name Adding and Removing Contacts
 */

/**
 @abstract Adds the given contact to the contact collection.
 @param contact The contact to be added.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion Local changes are reflected instantly and are synced with Layer cloud automatically depending on the current network conditions.
 */
- (BOOL)addContact:(LYRContact *)contact error:(NSError **)error;

/**
 @abstract Updates the given contact.
 @param contact The contact to be updated.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion Local changes are reflected instantly and are synced with Layer cloud automatically depending on the current network conditions.
 */
- (BOOL)updateContact:(LYRContact *)contact error:(NSError **)error;

/**
 @abstract Removes the given contact.
 @param contact The contact to be removed.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion Local changes are reflected instantly and are synced with Layer cloud automatically depending on the current network conditions.
 */
- (BOOL)removeContact:(LYRContact *)contact error:(NSError **)error;

/**
 @name Importing Contacts
 */

/**
 @abstract Imports contacts from the device.
 @param progress Block method with information about the import progress. This block has no return value and takes a single argument, a `float` number representing the import progress.
 @param completion Block method which is executed after the import has finished. This block has no return value and takes the argument `error` - an `NSError` object containing error information in case the import was not successful. If the import is successful the argument `error` is `nil`.
 */
- (void)importContactsWithProgress:(void(^)(float percent))progress
                        completion:(void(^)(NSError *error))completion;

/**
 @name Contacts Filtering
 */

/**
 @abstract An array containing all contacts. Each item is an `LYRContact` object.
 */
@property (nonatomic, readonly) NSArray *contacts;

/**
 @abstract Returns an `LYRContact` object with the corresponding address.
 @param address An `LYRAddress` object that is used for finding the matching contact.
 @return An `LYRContact` object with the corresponding address.
 @discussion The method might need some time to execute, depending on the number of contacts a user has.
 */
- (LYRContact *)contactForAddress:(LYRAddress *)address;

/**
 @abstract Fetch contacts with the given predicate and sort descriptor.
 @param predicate The predicate against which to evaluate contacts.
 @param sortDescriptors The sort descriptors used for fetching contacts.
 @param limit The maximum number of fetched contacts.
 @param offset The starting offset of fetched contacts.
 @param completion Block method which is executed when the filtering has finished. This block has no return value and takes two arguments, `contacts` - an array object containing the filtered contacts and `error` - an `NSError` object containing error information in case the filtering was not successful. If the filtering is successful the argument `error` is `nil`.
 */
- (void)fetchContactsWithPredicate:(NSPredicate *)predicate
                   sortDescriptors:(NSArray *)sortDescriptors
                             limit:(NSInteger)limit
                            offset:(NSInteger)offset
                        completion:(void(^)(NSArray *contacts, NSError *error))completion;

#pragma mark - Messages

/**
 @name Messages
 @discussion Method for sending, removing and filtering messages by custom predicates and sort descriptors.
 */

/**
 @name Sending Messages
 */

/**
 @abstract Sends a message.
 @param message The message to be sent.
 @param completion This will get executed upon successful or failed "send message" operation. If operation failed, an instance of `NSError` describes the problem.
 @discussion This method may also be called in an offline state (when `LYRClientStatusConnected` flag in `status` property is `false`), but user has to be authenticated (when `LYRClientStatusTokenAvailable` flag in `status` property is `true`). Note that local changes are reflected instantly and are synchronized with Layer cloud automatically depending on the network conditions.
 */
- (void)sendMessage:(LYRMessage *)message completion:(void(^)(NSError *error))completion;

/**
 @abstract Reply to a message.
 @param message The parent message of the new message.
 @param newMessage The message that is going to be sent.
 @param completion This will get executed upon successful or failed "reply to message" operation. If operation failed, an instance of `NSError` describes the problem.
 @discussion This method may also be called in an offline state (when `LYRClientStatusConnected` flag in `status` property is `false`), but user has to be authenticated (when `LYRClientStatusTokenAvailable` flag in `status` property is `true`). Note that local changes are reflected instantly and are synchronized with Layer cloud automatically depending on the network conditions. Also note when replying to a `message`, `newMessage` instance must include a list of recipients, they are not copied from the `message` object, meaning user has to define them manually.
 */
- (void)replyToMessage:(LYRMessage *)message withMessage:(LYRMessage *)newMessage completion:(void(^)(NSError *error))completion;

/**
 @abstract Change tags on a message.
 @param tags A set of tags that will be applied to the message. Each tag should be an `NSString` object.
 @param message The message on which to update the tags.
 @param completion This will get executed upon successful or failed "update message tags" operation. If operation failed, an instance of `NSError` describes the problem.
 @discussion This method may also be called in an offline state (when `LYRClientStatusConnected` flag in `status` property is `false`), but user has to be authenticated (when `LYRClientStatusTokenAvailable` flag in `status` property is `true`). Note that local changes are reflected instantly and are synchronized with Layer cloud automatically depending on the network conditions.
 */
- (void)updateTags:(NSSet *)tags forMessage:(LYRMessage *)message completion:(void(^)(NSError *error))completion;

/**
 @abstract Change the state of a message.
 @param state The new state to be set to the message.
 @param message The message on which to change the state.
 @param completion This will get executed upon successful or failed "update message state" operation. If operation failed, an instance of `NSError` describes the problem.
 @discussion This method may also be called in an offline state (when `LYRClientStatusConnected` flag in `status` property is `false`), but user has to be authenticated (when `LYRClientStatusTokenAvailable` flag in `status` property is `true`). Note that local changes are reflected instantly and are synchronized with Layer cloud automatically depending on the network conditions.
 @see LYRMessageState for possible state changes.
 */
- (void)updateState:(LYRMessageState)state forMessage:(LYRMessage *)message completion:(void(^)(NSError *error))completion;

/**
 @name Messages Filtering
 */

/**
 @abstract Fetch messages with the given predicate and sort descriptor.
 @param predicate The predicate against which to evaluate messages.
 @param sortDescriptors The sort descriptors used for fetching messages.
 @param limit The maximum number of fetched messages.
 @param offset The starting offset of fetched messages.
 @param completion Block method which is executed when the filtering has finished. This block has no return value and takes two arguments, `messages` - an array object containing the filtered messages and `error` - an `NSError` object containing error information in case the filtering was not successful. If the filtering is successful the argument `error` is `nil`.
 */
- (void)fetchMessagesWithPredicate:(NSPredicate *)predicate
                   sortDescriptors:(NSArray *)sortDescriptors
                             limit:(NSInteger)limit
                            offset:(NSInteger)offset
                        completion:(void(^)(NSArray *messages, NSError *error))completion;

/**
 @abstract Fetches `LYRMessageBody` objects from the server. Note that method is asynchronous.
 @param messages The array of `LYRMessage` objects for which to fetch message bodies.
 @param progress A progress handler (ranging from 0.0f to 1.0f) which indicates the progress of the message bodies fetch.
 @param completion A completion hander that gets executed when fetching completes successfully or fails.
 @see LYRMessageBody
 */
- (void)fetchMessageBodiesForMessages:(NSArray *)messages progress:(void(^)(float percent))progress completion:(void(^)(NSError *error))completion;

/**
 @abstract Get a `LYRConversation` instance that is associated with messages that match the given thread identifier.
 @param threadIdentifier Thread identifier that is found in messages.
 @return LYRConversation An instance of the `LYRConversation` with a type of `LYRConversationTypeThread`.
 @see LYRConversationType
 */
- (LYRConversation *)conversationWithThreadIdentifier:(NSString *)threadIdentifier;

/**
 @abstract Get a `LYRConversation` instance that is associated with message tree based on the given message.
 @param message A LYRMessage object which is a part of the message.
 @return LYRConversation An instance of the `LYRConversation` with a type of `LYRConversationTypeTree`.
 @see LYRConversationType
 */
- (LYRConversation *)conversationFromMessageTreeWithMessage:(LYRMessage *)message;

/**
 @abstract Get a `LYRConversation` instance that is associated with messages that includes a given set of participants.
 @param participants A set of `LYRAddress` objects.
 @return LYRConversation An instance of the `LYRConversation` with a type of `LYRConversationTypeParticipants`.
 @see LYRConversationType
 */
- (LYRConversation *)conversationWithParticipants:(NSSet *)participants;

@end
