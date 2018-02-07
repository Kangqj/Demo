//
// Created by chenxiaoyu on 17/2/21.
// Copyright (c) 2017 baidu. All rights reserved.
//

#import <AipBase/AipTokenManager.h>
#import <AipBase/AipOpenUDID.h>
#import "AipOcrService.h"

static NSString *const URL_GENERAL = @"https://aip.baidubce.com/rest/2.0/ocr/v1/general";
static NSString *const URL_GENERAL_BASIC = @"https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic";
static NSString *const URL_GENERAL_ENHANCED = @"https://aip.baidubce.com/rest/2.0/ocr/v1/general_enhanced";
static NSString *const URL_GENERAL_ACCURATE_BASIC = @"https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic";
static NSString *const URL_GENERAL_ACCURATE = @"https://aip.baidubce.com/rest/2.0/ocr/v1/accurate";
static NSString *const URL_BANKCARD = @"https://aip.baidubce.com/rest/2.0/ocr/v1/bankcard";
static NSString *const URL_IDCARD = @"https://aip.baidubce.com/rest/2.0/ocr/v1/idcard";
static NSString *const URL_WEBIMAGE = @"https://aip.baidubce.com/rest/2.0/ocr/v1/webimage";
static NSString *const URL_DRIVINGLICENSE = @"https://aip.baidubce.com/rest/2.0/ocr/v1/driving_license";
static NSString *const URL_VEHECLELICENSE = @"https://aip.baidubce.com/rest/2.0/ocr/v1/vehicle_license";
static NSString *const URL_PLATELICENSE = @"https://aip.baidubce.com/rest/2.0/ocr/v1/license_plate";
static NSString *const URL_BUSINESSLICENSE = @"https://aip.baidubce.com/rest/2.0/ocr/v1/business_license";
static NSString *const URL_RECEIPT = @"https://aip.baidubce.com/rest/2.0/ocr/v1/receipt";

static NSString* ErrorDomain = @"com.baidu.aipocr";

static NSError * ERR_EMPTY_IMAGE;


@implementation AipOcrService {

    AipTokenManager *_aipTokenManager;

    NSURLSession *_apiSession;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setHTTPAdditionalHeaders:@{
                @"Accept": @"application/json"
        }];
        // 如果网络状况不好，可以在这里修改超时时间
        configuration.timeoutIntervalForRequest = 10;
        configuration.timeoutIntervalForResource = 60;
        _apiSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (void)authWithAK:(NSString *)ak andSK:(NSString *)sk {
    _aipTokenManager = [[AipTokenManager alloc] initWithAK:ak andSK:sk];
}

- (void)authWithLicenseFileData:(NSData *)licenseFileContent {
    _aipTokenManager = [[AipTokenManager alloc] initWithLicenseFileData:licenseFileContent];
}

- (void)getTokenSuccessHandler:(void (^)(NSString *token))successHandler
                    failHandler:(void (^)(NSError *error))failHandler{
    
    [_aipTokenManager getIdcardTokenWithSuccessHandler:^(NSString *token) {
        
        if (successHandler) {
            successHandler(token);
        }
    } failHandler:^(NSError *error) {
        
        if (failHandler) {
            failHandler(error);
        }
    }];
}

- (void)clearCache {
    [_aipTokenManager clearCache];
}


#pragma mark ocr 接口
- (void)detectTextFromImage:(UIImage *)image
                withOptions:(NSDictionary *)options
             successHandler:(void (^)(id result))successHandler
                failHandler:(void (^)(NSError *err))failHandler {

    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];
    NSData *imageData = [self jpgDataWithImage:image sizeLimit:1024000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];
    [self _apiRequestWithURL:URL_GENERAL
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectTextBasicFromImage:(UIImage *)image
                     withOptions:(NSDictionary *)options
                  successHandler:(void (^)(id result))successHandler
                     failHandler:(void (^)(NSError *err))failHandler {

    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];
    NSData *imageData = [self jpgDataWithImage:image sizeLimit:1024000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];
    [self _apiRequestWithURL:URL_GENERAL_BASIC
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectTextEnhancedFromImage:(UIImage *)image
                        withOptions:(NSDictionary *)options
                     successHandler:(void (^)(id result))successHandler
                        failHandler:(void (^)(NSError *err))failHandler {

    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];
    // 通用文字识别的图片清晰点更合适，满足接口max limit即可
    NSData *imageData = [self jpgDataWithImage:image sizeLimit:1024000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];
    [self _apiRequestWithURL:URL_GENERAL_ENHANCED
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectTextAccurateBasicFromImage:(UIImage *)image
                             withOptions:(NSDictionary *)options
                          successHandler:(void (^)(id result))successHandler
                             failHandler:(void (^)(NSError *err))failHandler {

    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];
    NSData *imageData = [self jpgDataWithImage:image sizeLimit:4096000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];
    [self _apiRequestWithURL:URL_GENERAL_ACCURATE_BASIC
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}


- (void)detectTextAccurateFromImage:(UIImage *)image
                        withOptions:(NSDictionary *)options
                     successHandler:(void (^)(id result))successHandler
                        failHandler:(void (^)(NSError *err))failHandler {

    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];
    // 通用文字识别的图片清晰点更合适，满足接口max limit即可
    NSData *imageData = [self jpgDataWithImage:image sizeLimit:4096000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];
    [self _apiRequestWithURL:URL_GENERAL_ACCURATE
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}


- (void)detectIdCardFromImage:(UIImage *)image withOptions:(NSDictionary *)options successHandler:(void (^)(id result))successHandler failHandler:(void (^)(NSError *err))failHandler {
    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:512000];

    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];
    [self _apiRequestWithURL:URL_IDCARD
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectIdCardFrontFromImage:(UIImage *)image withOptions:(NSDictionary *)options successHandler:(void (^)(id result))successHandler failHandler:(void (^)(NSError *err))failHandler {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:options];
    dictionary[@"id_card_side"] = @"front";
    [self detectIdCardFromImage:image withOptions:dictionary successHandler:successHandler failHandler:failHandler];

}

- (void)detectIdCardBackFromImage:(UIImage *)image withOptions:(NSDictionary *)options successHandler:(void (^)(id result))successHandler failHandler:(void (^)(NSError *err))failHandler {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:options];
    dictionary[@"id_card_side"] = @"back";
    [self detectIdCardFromImage:image withOptions:dictionary successHandler:successHandler failHandler:failHandler];

}


- (void)detectBankCardFromImage:(UIImage *)image successHandler:(void (^)(id))successHandler failHandler:(void (^)(NSError *))failHandler {
    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:512000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];

    [self _apiRequestWithURL:URL_BANKCARD
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}


- (void) detectWebImageFromImage: (UIImage *)image
                     withOptions: (NSDictionary *)options
                  successHandler: (void (^)(id result))successHandler
                     failHandler: (void (^)(NSError* err))failHandler{
    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:512000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];

    [self _apiRequestWithURL:URL_WEBIMAGE
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectDrivingLicenseFromImage:(UIImage *)image
                          withOptions:(NSDictionary *)options
                       successHandler:(void (^)(id result))successHandler
                          failHandler:(void (^)(NSError *err))failHandler {

    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:4096000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];

    [self _apiRequestWithURL:URL_DRIVINGLICENSE
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectVehicleLicenseFromImage:(UIImage *)image withOptions:(NSDictionary *)options successHandler:(void (^)(id result))successHandler failHandler:(void (^)(NSError *err))failHandler {
    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:4096000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];

    [self _apiRequestWithURL:URL_VEHECLELICENSE
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}


- (void)detectPlateNumberFromImage:(UIImage *)image withOptions:(NSDictionary *)options successHandler:(void (^)(id result))successHandler failHandler:(void (^)(NSError *err))failHandler {
    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:4096000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];

    [self _apiRequestWithURL:URL_PLATELICENSE
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectBusinessLicenseFromImage:(UIImage *)image withOptions:(NSDictionary *)options successHandler:(void (^)(id result))successHandler failHandler:(void (^)(NSError *err))failHandler {
    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:4096000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];

    [self _apiRequestWithURL:URL_BUSINESSLICENSE
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}

- (void)detectReceiptFromImage:(UIImage *)image withOptions:(NSDictionary *)options successHandler:(void (^)(id result))successHandler failHandler:(void (^)(NSError *err))failHandler {
    if(!image){
        if (failHandler) failHandler(ERR_EMPTY_IMAGE);
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:options];

    NSData *imageData = [self jpgDataWithImage:image sizeLimit:4096000];
    dict[@"image"] = [imageData base64EncodedStringWithOptions:0];

    [self _apiRequestWithURL:URL_RECEIPT
                     options:dict
              successHandler:successHandler
                 failHandler:failHandler];
}


/**
 * 通用的请求API服务的方法
 */
- (void)_apiRequestWithURL:(NSString *)URL
                   options:(NSDictionary *)options
            successHandler:(void (^)(id result))successHandler
               failHandler:(void (^)(NSError *err))failHandler {

    [_aipTokenManager getTokenWithSuccessHandler:^(NSString *token) {
         NSLog(@"requesting: %@", URL);
         // 成功获得token
         NSString *version = [[NSBundle bundleForClass:[AipTokenManager class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

         NSDictionary *getParams = @{
                 @"access_token": token,
                 @"aipSdk": @"iOS",
                 @"aipSdkVersion": [version stringByReplacingOccurrencesOfString:@"." withString:@"_"],
                 @"aipDevid": [OpenUDID value]
         };
         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", URL, [AipOcrService wwwFormWithDictionary:getParams]]];
         NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
         [request setHTTPMethod:@"POST"];
         [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
         [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

         NSString *formData = [AipOcrService wwwFormWithDictionary:options];
         [request setHTTPBody:[formData dataUsingEncoding:NSUTF8StringEncoding]];

         [[_apiSession dataTaskWithRequest:request
                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                             if (error) {
                                 if (failHandler) failHandler([AipOcrService aipApiServerConnectErrorWithMessage:[error localizedDescription]]);
                                 return;
                             }
                             NSError *serializedErr = nil;
                             id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializedErr];
                             if (serializedErr) {
                                 if (failHandler) failHandler([AipOcrService aipApiServerIllegalResponseError]);
                                 return;
                             }
                             if (obj[@"error_code"]){
                                 if ([obj[@"error_code"] intValue] == 110) {
                                     // 理论上不会走到这里，特殊情况，清空缓存。下次重试即可。
                                     [self clearCache];
                                 }
                                 if (failHandler) failHandler([AipOcrService aipErrorWithCode:[obj[@"error_code"] integerValue] andMessage:obj[@"error_msg"]]);
                                 return;
                             }
                             if (successHandler) successHandler(obj);
                         }] resume];
     }
                          failHandler:^(NSError *error) {
                              // 获得token失败
                              if (failHandler) failHandler(error);
                          }];

}

- (NSData *)jpgDataWithImage:(UIImage *)image sizeLimit:(NSUInteger)maxSize {
    CGFloat compressionQuality = 1.0;
    NSData *imageData = nil;

    int i = 0;
    do{
        imageData = UIImageJPEGRepresentation(image, compressionQuality);
        compressionQuality -= 0.1;
        i += 1;
    }while(i < 3 && imageData.length > maxSize);
    return imageData;
}

+ (NSString *)base64Escape:(NSString *)string {
    NSCharacterSet *URLBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"/+=\n"] invertedSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:URLBase64CharacterSet];
}

+ (NSString *)wwwFormWithDictionary:(NSDictionary *)dict {
    NSMutableString *result = [[NSMutableString alloc] init];
    if (dict != nil) {
        for (NSString *key in dict) {
            if (result.length)
                [result appendString:@"&"];
            [result appendString:[self base64Escape:key]];
            [result appendString:@"="];
            [result appendString:[self base64Escape:dict[key]]];
        }
    }
    return result;
}


#pragma errors

+ (NSError *)aipErrorWithCode:(NSInteger)code andMessage:(NSString *)message {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
    return [NSError errorWithDomain:ErrorDomain code:code userInfo:userInfo];
}

+ (NSError *)aipApiServerConnectErrorWithMessage:(NSString *)message {
    NSString *err = [NSString stringWithFormat:@"%@(%@)", @"Fail to connect to api server", message];
    return [AipOcrService aipErrorWithCode:283504 andMessage:err];
}

+ (NSError *)aipApiServerIllegalResponseError {
    return [AipOcrService aipErrorWithCode:283505 andMessage:@"Internal error. Api server responsing illegal data"];
}


+ (instancetype)shardService {
    static AipOcrService *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    ERR_EMPTY_IMAGE = [AipOcrService aipErrorWithCode:283507 andMessage:@"Empty image. 图片为空"];
    return sharedService;
}

@end
