//
// Created by Quentin Lin on 7/05/2016.
// Copyright (c) 2016 coder9t99. All rights reserved.
//

#import "HighScoreSynchroniser.h"
#import "UNIRest.h"
#import "AppDelegate.h"

@interface HighScoreSynchroniser ()
@property (readonly) NSManagedObjectContext* managedObjectContext;
@property (readonly) NSString* endpoint;
@property (readonly) NSDictionary *defaultHeader;

-(void)getNewData;
-(void)getNewData:(NSNumber *)lastBatchTag skip:(NSInteger)skip;

-(void)uploadLocalData;
-(void)upload:(NSArray*)scores;
@end

@implementation HighScoreSynchroniser

- (instancetype)initWithHighScoreEndpoint:(NSString *)url {
    self = super.init;
    if (self) {
        _defaultHeader = @{
            @"accept":@"application/json",
            @"Content-Type":@"application/json",
        };
        _endpoint = url;
    }
    return self;
}

- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    return context;
}

- (void)sync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getNewData];
    });
}

- (void)getNewData:(NSNumber *)lastBatchTag skip:(NSInteger)skip {
    NSNumber *nextBatchTag = @(lastBatchTag.integerValue + 1);
    NSString *url = [NSString stringWithFormat:@"%@/from_batch/%@/take/%u/skip/%ld", self.endpoint, nextBatchTag, 100, (long)skip];

    [[UNIRest get:^(UNISimpleRequest *request) {
        request.url     = url;
        request.headers = self.defaultHeader;
    }] asJsonAsync:^(UNIHTTPJsonResponse* response, NSError *error) {
        UNIJsonNode *body = response.body;

        NSNumber *totalCount = body.JSONObject[@"message"][@"totalCount"];
        NSNumber *skipped    = body.JSONObject[@"message"][@"skip"];
        NSArray  *scores     = body.JSONObject[@"message"][@"scores"];
        NSInteger positionAfterThisLeg = skipped.integerValue + scores.count;

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Score"
                                                             inManagedObjectContext:self.managedObjectContext];
        for (NSDictionary *score in scores) {
            NSManagedObject *scoreObject = [[NSManagedObject alloc] initWithEntity:entityDescription
                                                    insertIntoManagedObjectContext:self.managedObjectContext];
            [scoreObject setValue:score[@"score"] forKey:@"score"];
            [scoreObject setValue:score[@"name"] forKey:@"name"];
            [scoreObject setValue:score[@"batch_tag"] forKey:@"batch_tag"];
        }

        NSError *err;
        [self.managedObjectContext save:&err];
        if (err) {
            NSLog(@"Unable to sync scores.");
        }

        if (positionAfterThisLeg > 0 && positionAfterThisLeg < totalCount.integerValue) {
            [self getNewData:lastBatchTag skip:skip + 100];
        } else {
            [self uploadLocalData];
            [NSNotificationCenter.defaultCenter postNotificationName:kDataSyncComplete object:self];
        }
    }];
}

- (void)getNewData {
    NSFetchRequest *request = NSFetchRequest.new;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Score"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    request.predicate = [NSPredicate predicateWithFormat:@"batch_tag==max(batch_tag)"];
    request.sortDescriptors = [NSArray array];

    NSError *err = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&err];

    if (err) {
        NSLog(@"unable to find max local batch number.");
        return;
    }

    NSNumber *lastBatchNumber = @(0);
    if (result.count > 0) {
        lastBatchNumber = [result.firstObject valueForKey:@"batch_tag"];
    }

    [self getNewData:lastBatchNumber skip:0];
}

- (void)uploadLocalData {
    NSFetchRequest *request = NSFetchRequest.new;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Score"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    request.predicate = [NSPredicate predicateWithFormat:@"batch_tag==0"];
    request.sortDescriptors = [NSArray array];

    NSError *err = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&err];

    if (err) {
        NSLog(@"unable to find max local batch number.");
        return;
    }

    if (result.count <= 0) {
        return; // no new scores
    }

    [self upload:result];
}

-(void)upload:(NSArray*)scores {
    [[UNIRest get:^(UNISimpleRequest *request) {
        request.url     = [NSString stringWithFormat:@"%@/lock", self.endpoint];
        request.headers = self.defaultHeader;
    }] asJsonAsync:^(UNIHTTPJsonResponse* response, NSError *error) {
        UNIJsonNode *body = response.body;
        NSNumber *lock = body.JSONObject[@"message"][@"lock"];

        NSMutableArray *payload = [NSMutableArray arrayWithCapacity:scores.count];

        NSError *err;
        for (NSManagedObject *score in scores) {
            [score setValue:lock forKey:@"batch_tag"];

            [payload addObject:@{
                @"name"     :[score valueForKey:@"name"],
                @"score"    :[score valueForKey:@"score"],
                @"batch_tag":[score valueForKey:@"batch_tag"]
            }];
        }

        [self.managedObjectContext save:&err];

        if (err) {
            NSLog(@"Unable to sync scores.");
            return;
        }

        NSData *jsonPayload = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&err];
        [[UNIRest postEntity:^(UNIBodyRequest *request) {
            request.url     = self.endpoint;
            request.headers = self.defaultHeader;
            request.body    = jsonPayload;
        }] asJson];

    }];
}

@end
