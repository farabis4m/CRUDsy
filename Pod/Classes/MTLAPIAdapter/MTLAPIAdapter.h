//
//  MTLAPIAdapter.h
//  Pods
//
//  Created by vlad gorbenko on 8/16/15.
//
//

#import <Foundation/Foundation.h>

#import "MTLRouteJSONSerializing.h"

#import "MTLRouteErrors.h"

#import <Mantle/MTLJSONAdapter.h>

@interface MTLAPIAdapter : NSObject

@property (nonatomic, strong, readonly) Class modelClass;

// A cached copy of the return value of +JSONKeyPathsByPropertyKey.
@property (nonatomic, copy, readonly) NSDictionary *JSONKeyPathsByPropertyKey;

// A cached copy of the return value of -valueTransformersForModelClass:
@property (nonatomic, copy, readonly) NSDictionary *valueTransformersByPropertyKey;

// Used to cache the JSON adapters returned by -JSONAdapterForModelClass:error:.
@property (nonatomic, strong, readonly) NSMapTable *JSONAdaptersByModelClass;

// If +classForParsingJSONDictionary: returns a model class different from the
// one this adapter was initialized with, use this method to obtain a cached
// instance of a suitable adapter instead.
//
// modelClass - The class from which to parse the JSON. This class must conform
//              to <MTLJSONSerializing>. This argument must not be nil.
// error -      If not NULL, this may be set to an error that occurs during
//              initializing the adapter.
//
// Returns a JSON adapter for modelClass, creating one of necessary. If no
// adapter could be created, nil is returned.
- (MTLAPIAdapter *)JSONAdapterForModelClass:(Class)modelClass action:(NSString *)action error:(NSError **)error;

// Collect all value transformers needed for a given class.
//
// modelClass - The class from which to parse the JSON. This class must conform
//              to <MTLJSONSerializing>. This argument must not be nil.
//
// Returns a dictionary with the properties of modelClass that need
// transformation as keys and the value transformers as values.
+ (NSDictionary *)valueTransformersForModelClass:(Class)modelClass;

#pragma mark - Lifecycle
- (id)initWithModelClass:(Class)modelClass action:(NSString *)action;

#pragma mark - Transformation template methods
+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError **)error;
+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error;
+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray action:(NSString *)action error:(NSError **)error;
+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray error:(NSError **)error;

+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error;
+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model error:(NSError **)error;
+ (NSArray *)JSONArrayFromModels:(NSArray *)models action:(NSString *)action error:(NSError **)error;
+ (NSArray *)JSONArrayFromModels:(NSArray *)models error:(NSError **)error;

#pragma mark - Transform logic methods
- (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary action:(NSString *)action error:(NSError **)error;
- (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error;
- (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model action:(NSString *)action error:(NSError **)error;
- (NSDictionary *)JSONDictionaryFromModel:(id<MTLRouteJSONSerializing>)model error:(NSError **)error;

- (NSSet *)serializablePropertyKeys:(NSSet *)propertyKeys forModel:(id<MTLRouteJSONSerializing>)model;

+ (NSValueTransformer *)transformerForModelPropertiesOfClass:(Class)modelClass;
+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType;

@end

@interface MTLAPIAdapter (ValueTransformers)

+ (NSValueTransformer<MTLTransformerErrorHandling> *)dictionaryTransformerWithModelClass:(Class)modelClass;

+ (NSValueTransformer<MTLTransformerErrorHandling> *)arrayTransformerWithModelClass:(Class)modelClass;

+ (NSValueTransformer *)NSURLJSONTransformer;

@end