//
//  PPGenstrings.m
//  PPGenstrings
//
//  Created by richard on 2017/3/2.
//  Copyright © 2017年 richard. All rights reserved.
//

#import "PPGenstrings.h"

@interface PPLocalizedStringEntry : NSObject

@property (nonatomic, copy) NSString *entryKey;

@property (nonatomic, copy) NSString *entryValue;

@property (nonatomic, copy) NSString *entryComment;

@end


@implementation PPLocalizedStringEntry

@end

@implementation PPGenstrings

#pragma mark - Source Filed (.m)
+ (NSArray *)strippedStringsFromSourceString:(NSString *)sourceString
{
    NSRange searchedRange = NSMakeRange(0, [sourceString length]);
    
    // regex for c strings including escape characters
    NSString *pattern = @"\"(\\\\.|[^\"])*\"";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSMutableArray *strippedStrings = [NSMutableArray array];
    
    if (regex) {
        NSArray *matches = [regex matchesInString:sourceString options:0 range:searchedRange];
        NSCharacterSet *trimQuotesCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        
        for (NSTextCheckingResult *match in matches) {
            NSString* matchText = [sourceString substringWithRange:[match range]];
            
            // trim " characters from begin and end
            [strippedStrings addObject:[matchText stringByTrimmingCharactersInSet:trimQuotesCharacterSet]];
        }
    }
    
    return [strippedStrings copy];
}

+ (NSArray *)localizedStringsForSourceFile:(NSString *)sourceFilePath
{
    // use filename as comment if comment is nil
    NSString *fileName = [sourceFilePath lastPathComponent];
    
    NSString *source = [NSString stringWithContentsOfFile:sourceFilePath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *allStringPairs = [NSMutableArray array];
    
    if (source) {
        // first get all regex matches for all possible variants for NSLocalizedString(@"key", @"value")
        NSRange searchedRange = NSMakeRange(0, [source length]);
        
        // org pattern @"NSLocalizedString\\s*\\(\\s*@\"(\\\\.|[^\"])*\"\\s*,\\s*(nil|@\"(\\\\.|[^\"])*\")\\s*\\)"
        
        //NSString *pattern = @"NSLocalizedString\\s*\\(\\s*@\"\\S*\"\\,\\s*\\@\"\\S*\\s*\\S*\"\\)";
        
        NSString *pattern = @"NSLocalizedString\\s*\\(\\s*\\@\".*\"\\,\\s*\\@\".*\"\\)";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSArray *matches = [regex matchesInString:source options:0 range:searchedRange];
        
        for (NSTextCheckingResult *match in matches) {
            // get string from matched range and strip it into key and optional comment pairs
            NSString* matchText = [source substringWithRange:[match range]];
            NSArray *pair = [self strippedStringsFromSourceString:matchText];
            
            if (pair.count == 1) {
                // use filename as comment if comment is nil
                pair = @[pair[0], fileName];
            }
            
            [allStringPairs addObject:pair];
        }
    }
    
    return [allStringPairs copy];
}


#pragma mark - Scan Localized Strings For Directory
+ (NSDictionary *)localizedStringsForDirectory:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *subPaths = [fileManager subpathsOfDirectoryAtPath:directory error:nil];
    NSMutableDictionary *entries = [NSMutableDictionary dictionary];
    
    for (NSString *path in subPaths) {
        NSString *extension = [path pathExtension];
        NSString *fullPath = [directory stringByAppendingPathComponent:path];
        NSArray *pairs = nil;
        
        if ([extension isEqualToString:@"m"] || [extension isEqualToString:@"h"] || [extension isEqualToString:@"mm"]) {
            // good old fashioned NSLocalizedString
            NSLog(@"Processing: %@", [fullPath componentsSeparatedByString:@"/"].lastObject);
            pairs = [self localizedStringsForSourceFile:fullPath];
        }
        
        for (NSArray *pair in pairs) {
            
            for (NSUInteger i=0; i<pair.count; i+=2) {
                PPLocalizedStringEntry *entry = [[PPLocalizedStringEntry alloc] init];
                
                // check duplicated comment
                if (entries[pair[i+0]] != nil) {
                    if (![((PPLocalizedStringEntry *)entries[pair[i+0]]).entryComment isEqualToString:pair[i+1]]) {
                        NSLog(@"%@ duplicated in %@", pair[i+0], [fullPath componentsSeparatedByString:@"/"].lastObject);
                        exit(1);
                    }
                }
                
                entry.entryKey     = pair[i+0];
                entry.entryValue   = @"";
                entry.entryComment = pair[i+1];
                
                entries[entry.entryKey] = entry;
            }
        }
    }
    
    return [entries copy];
}

+ (void)genstringsForDirectory:(NSString *)directory WithOutputPath:(NSString *)outputPath
{
    printf("Scanning directories for localized strings...\n");
    
    // get collected strings from root directory .m
    NSDictionary *collectedStrings = [self localizedStringsForDirectory:directory];
    NSArray *sortedKeys = [[collectedStrings allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    
    [[NSFileManager defaultManager] createFileAtPath:outputPath contents:nil attributes:nil];
    
    NSMutableString *content = [[NSMutableString alloc] init];
    
    [sortedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *comment = [NSString stringWithFormat:@"/* %@ */\n", ((PPLocalizedStringEntry*)collectedStrings[key]).entryComment];
        
        NSString *cmt = @"";
        NSArray *tmp = [((PPLocalizedStringEntry*)collectedStrings[key]).entryComment componentsSeparatedByString:@": "];
        
        if (tmp.count > 1) {
            cmt = tmp[1];
        } else {
            cmt = tmp[0];
        }
        
        
        NSString *line    = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n\n", key, cmt];
        
        [content appendString:comment];
        [content appendString:line];
        
        //NSLog(@"\"%@\" = \"%@\"", key, ((FCLocalizedStringEntry*)collectedStrings[key]).entryComment);
        
    }];
    
    [content writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


@end
