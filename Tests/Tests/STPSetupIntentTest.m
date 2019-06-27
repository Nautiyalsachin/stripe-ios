//
//  STPSetupIntentTest.m
//  StripeiOS Tests
//
//  Created by Yuki Tokuhiro on 6/27/19.
//  Copyright © 2019 Stripe, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "STPSetupIntent.h"
#import "STPFixtures.h"
#import "STPTestUtils.h"

@interface STPSetupIntentTest : XCTestCase

@end

@implementation STPSetupIntentTest

#pragma mark - Description Tests

- (void)testDescription {
    STPSetupIntent *setupIntent = [STPFixtures setupIntent];
    
    XCTAssertNotNil(setupIntent);
    NSString *desc = setupIntent.description;
    XCTAssertTrue([desc containsString:NSStringFromClass([setupIntent class])]);
    XCTAssertGreaterThan(desc.length, 500UL, @"Custom description should be long");
}

#pragma mark - STPAPIResponseDecodable Tests

- (void)testDecodedObjectFromAPIResponseRequiredFields {
    NSDictionary *fullJson = [STPTestUtils jsonNamed:STPTestJSONSetupIntent];
    
    XCTAssertNotNil([STPSetupIntent decodedObjectFromAPIResponse:fullJson], @"can decode with full json");
    
    NSArray<NSString *> *requiredFields = @[
                                            @"id",
                                            @"client_secret",
                                            @"livemode",
                                            @"status",
                                            ];
    
    for (NSString *field in requiredFields) {
        NSMutableDictionary *partialJson = [fullJson mutableCopy];
        
        XCTAssertNotNil(partialJson[field], @"json should contain %@", field);
        [partialJson removeObjectForKey:field];
        
        XCTAssertNil([STPSetupIntent decodedObjectFromAPIResponse:partialJson], @"should not decode without %@", field);
    }
}

- (void)testDecodedObjectFromAPIResponseMapping {
    NSDictionary *response = [STPTestUtils jsonNamed:@"SetupIntent"];
    STPSetupIntent *setupIntent = [STPSetupIntent decodedObjectFromAPIResponse:response];
    
    XCTAssertEqualObjects(setupIntent.stripeId, @"seti_123456789");
    XCTAssertEqualObjects(setupIntent.clientSecret, @"seti_123456789_secret_123456789");
    XCTAssertEqualObjects(setupIntent.created, [NSDate dateWithTimeIntervalSince1970:123456789]);
    XCTAssertEqualObjects(setupIntent.customerId, @"cus_123456");
    XCTAssertEqualObjects(setupIntent.metadata, @{@"user_id": @"guest_1234567"});
    XCTAssertEqualObjects(setupIntent.paymentMethodId, @"pm_123456");
    XCTAssertEqualObjects(setupIntent.stripeDescription, @"My Sample SetupIntent");
    XCTAssertFalse(setupIntent.livemode);
    // nextAction
    XCTAssertNotNil(setupIntent.nextAction);
    XCTAssertEqual(setupIntent.nextAction.type, STPIntentActionTypeRedirectToURL);
    XCTAssertNotNil(setupIntent.nextAction.redirectToURL);
    XCTAssertNotNil(setupIntent.nextAction.redirectToURL.url);
    NSURL *returnURL = setupIntent.nextAction.redirectToURL.returnURL;
    XCTAssertNotNil(returnURL);
    XCTAssertEqualObjects(returnURL, [NSURL URLWithString:@"payments-example://stripe-redirect"]);
    NSURL *url = setupIntent.nextAction.redirectToURL.url;
    XCTAssertNotNil(url);
    
    XCTAssertEqualObjects(url, [NSURL URLWithString:@"https://hooks.stripe.com/redirect/authenticate/src_1Cl1AeIl4IdHmuTb1L7x083A?client_secret=src_client_secret_DBNwUe9qHteqJ8qQBwNWiigk"]);
    XCTAssertEqualObjects(setupIntent.paymentMethodId, @"pm_123456");
    XCTAssertEqual(setupIntent.status, STPSetupIntentStatusRequiresAction);
    
    XCTAssertEqualObjects(setupIntent.paymentMethodTypes, @[@(STPPaymentMethodTypeCard)]);
    
    XCTAssertNotEqual(setupIntent.allResponseFields, response, @"should have own copy of fields");
}


@end