//
//  LYRMessage.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/26/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import "LYRAddress.h"
#import "LYRMessageBody.h"
#import "LYRConversation.h"

@class LYRClient;

/**
 Possible `LYRMessage` states.
 */
typedef NS_ENUM(NSInteger, LYRMessageState) {
    /** A newly created message. (set automatically) */
    LYRMessageStateInitial = -1,
    /** A message waiting to be sent. (set automatically) */
    LYRMessageStateUnsent = 0,
    /** A sent message. (set automatically) */
    LYRMessageStateSent = 1,
    /** A message that failed to send. (set automatically) Use checkErrorForMessage: for more info about the failure. */
    LYRMessageStateFailed = 2,
    /** A delivered, unread message. (set automatically when delivered, can be set programmatically - read -> unread) */
    LYRMessageStateDeliveredUnread = 3,
    /** A delivered, read message. (set programmatically - unread -> read) */
    LYRMessageStateDeliveredRead = 4,
};

/**
 Possible `LYRMessageBodiesFetchStatus` states.
 */
typedef NS_ENUM(NSUInteger, LYRMessageBodiesFetchStatus) {
    /** Bodies haven't been fetched yet */
    LYRMessageBodiesFetchStatusNotFetched = 0,
    /** Fetching message body parts in progress */
    LYRMessageBodiesFetchStatusInProgress = 1,
    /** LYRMessage contains all body parts (fetch complete) */
    LYRMessageBodiesFetchStatusFetched = 2,
};

/**
 The `LYRMessage` class defines a message object and stores its information.
 
 @discussion Mutable changes are not reflected in the same object instance. If you're using the `LYRMessageController` to visualise messages, delegate methods will give new instances of `LYRMessage` objects upon changes (changes such as newly inserted messages, updated messages, etc.). Also note that newly received `LYRMessage` objects do not include bodies (found in `bodies` property), you have to manually fetch them for each `LYRMessage` by calling the `fetchBodiesWithCompletion:` asynchronous method.
 */

@interface LYRMessage : NSObject

/**
 @name Properties
 */

/**
 @abstract The message identifier.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 @abstract The identifier of the parent message (if this message was a reply to another message).
 */
@property (nonatomic, readonly) NSString *parentMessageIdentifier;

/**
 @abstract The thread id of the message.
 */
@property (nonatomic, readonly) NSString *threadIdentifier;

/**
 @abstract The date of message.
 */
@property (nonatomic, readonly) NSDate *date;

/**
 @abstract The date of message set by sender.
 */
@property (nonatomic, readonly) NSDate *dateSender;

/**
 @abstract The subject of the message.
 */
@property (nonatomic) NSString *subject;

/**
 @abstract The sender of the message.
 */
@property (nonatomic, readonly) LYRAddress *sender;

/**
 @abstract A set of recipients of the message. Each item is an `LYRAddress` object.
 */
@property (nonatomic, readonly) NSSet *recipients;

/**
 @abstract An set of tags of the message. Each item is a string.
 */
@property (nonatomic, readonly) NSSet *tags;

/**
 @abstract A status that tells if message bodies have been fetched.
 @discussion Newly received `LYRMessage` do not include bodies. To fetch bodies, use method fetchBodiesWithCompletion:
 */
@property (nonatomic, readonly) LYRMessageBodiesFetchStatus bodiesFetchStatus;

/**
 @abstract An array of message bodies. Each item is an `LYRMessageBody` object. A message can have multiple bodies each containing a different type of data. For instance a message could have a rich text body and also a plain text version that is used for optimization purposes.
 */
@property (nonatomic, readonly) NSArray *bodies;

/**
 @abstract Message state reflects user's own recipient state.
 @see LYRMessageState
 */
@property (nonatomic, readonly) LYRMessageState state;

/**
 @abstract The message sequence number.
 @discussion The sequence number represents the order in which the messages were fetched by the client. Useful for sorting messages with a sortDescriptor when using `LYRMessageController` or clients method `fetchMessagesWithPredicate:...`.
 */
@property (nonatomic, readonly) NSInteger sequenceNumber;

/**
 @abstract Delivery and read receipt state of the message for each recipient.
 @see LYRMessageState
 */
@property (nonatomic, readonly) NSArray *recipientStates;

/**
 @abstract Instance of parent message relationship
 */
@property (nonatomic, readonly) LYRMessage *parentMessage;

/**
 @abstract An array of instances of child message relationships
 */
@property (nonatomic, readonly) NSArray *childMessages;

/**
 @abstract An array of conversations.
 @discussion It is more convenient to use the ```conversationForType:``` method to get a conversation of specific type.
 */
@property (nonatomic, readonly) NSArray *conversations;

/**
 @abstract Creates a new `LYRMessage` instance.
 @param client An `LYRClient` instance.
 @return An `LYRMessage` object with the message bodies and recipients set.
 */
- (instancetype)initWithClient:(LYRClient*)client;

/**
 @abstract Creates a new `LYRMessage` object and adds the message bodies and recipients.
 @param bodies An array of message bodies. Each item must be an `LYRMessageBody` object.
 @param recipients A set of recipients of the message. Each item must be an `LYRAddress` object.
 @return An `LYRMessage` object with the message bodies and recipients set.
 */
+ (instancetype)messageWithMessageBodies:(NSArray *)bodies recipients:(NSSet *)recipients;

/**
 @abstract Creates a new `LYRMessage` object and adds the message bodies and recipients.
 @param bodies An array of message bodies. Each item must be an `LYRMessageBody` object.
 @param recipients A set of recipients of the message. Each item must be an `LYRAddress` object.
 @param threadIdentifier The thread id of the message.
 @return An `LYRMessage` object with the message bodies and recipients set.
 */
+ (instancetype)messageWithMessageBodies:(NSArray *)bodies recipients:(NSSet *)recipients threadIdentifier:(NSString *)threadIdentifier;

/**
 @abstract Fetches `LYRMessageBody` objects from the server. Note that method is asynchronous.
 @param progress A progress handler (ranging from 0.0f to 1.0f) which indicates the progress of the message bodies fetch.
 @param completion A completion hander that gets executed when fetching completes successfully or fails.
 @see LYRMessageBody
 */
- (void)fetchBodiesWithProgress:(void(^)(float percent))progress completion:(void(^)(NSError *error))completion;

/**
 @abstract Delivery and read receipt state of the message for a specific recipient.
 @param recipient The recepient for which to fetch the message state.
 @return The state of the message for a specific recipient.
 @see LYRMessageState
 */
- (LYRMessageState)stateForRecipient:(LYRAddress *)recipient;

/**
 @abstract Returns the conversation of which this message is a part of by the given covnersation type.
 @param conversationType Conversation type
 @return An instance of `LYRConversation`.
 @see LYRConversation
 */
- (LYRConversation *)conversationForType:(LYRConversationType)conversationType;

- (BOOL)addMessageBody:(LYRMessageBody *)body error:(NSError **)error;
- (BOOL)addMessageBodies:(NSArray *)bodies error:(NSError **)error;
- (BOOL)removeMessageBody:(LYRMessageBody *)body error:(NSError **)error;
- (BOOL)removeMessageBodies:(NSArray *)bodies error:(NSError **)error;

- (BOOL)addRecipient:(LYRAddress *)recipient error:(NSError **)error;
- (BOOL)addRecipients:(NSSet *)recipients error:(NSError **)error;
- (BOOL)removeRecipient:(LYRAddress *)recipient error:(NSError **)error;
- (BOOL)removeRecipients:(NSSet *)recipients error:(NSError **)error;

- (BOOL)addTag:(NSString *)tag error:(NSError **)error;
- (BOOL)addTags:(NSSet *)tags error:(NSError **)error;
- (BOOL)removeTag:(NSString *)tag error:(NSError **)error;
- (BOOL)removeTags:(NSSet *)tags error:(NSError **)error;

@end

/**
 The `LYRMessageRecipientState` class defines a message state for a specific recipient.
 */

@interface LYRMessageRecipientState : NSObject

/**
 @name Properties
 */

/**
 @abstract The recipient of the message.
 */
@property (nonatomic, readonly) LYRAddress *recipient;

/**
 @abstract The state of the message.
 */
@property (nonatomic) LYRMessageState state;

@end
