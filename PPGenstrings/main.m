//
//  main.m
//  PPGenstrings
//
//  Created by richard on 2017/3/2.
//  Copyright © 2017年 richard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPGenstrings.h"

int main(int argc, const char * argv[])
{
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    
    if (arguments.count != 3) {
        printf("Usage: PPGenstrings scanFolder outputFileFullPath\n");
        return 0;
    }
    
    NSString *folder  = arguments[1];
    NSString *outPath = arguments[2];
    
    if (![folder isKindOfClass:[NSString class]]) {
        printf("Usage: PPGenstrings scanFolder outputFileFullPath\n");
        return 0;
    }
    
    if (![outPath isKindOfClass:[NSString class]]) {
        printf("Usage: PPGenstrings scanFolder outputFileFullPath\n");
        return 0;
    }
    
    if (folder.length > 0 && ![[folder substringToIndex:1] isEqualToString:@"/"]) {
        
        if ([[folder substringToIndex:1] isEqualToString:@"."]) {
            NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
            NSString *subPath = [folder componentsSeparatedByString:@"./"][1];
            folder = [currentDirectory stringByAppendingPathComponent:subPath];
        } else if ([[folder substringToIndex:1] isEqualToString:@"~"]) {
            NSString *currentDirectory = NSHomeDirectory();
            NSString *subPath = [folder componentsSeparatedByString:@"~/"][1];
            folder = [currentDirectory stringByAppendingPathComponent:subPath];
        } else {
            NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
            folder = [currentDirectory stringByAppendingPathComponent:folder];
        }
        
    }
    
    if (outPath.length > 0 && ![[outPath substringToIndex:1] isEqualToString:@"/"]) {
        
        if ([[outPath substringToIndex:1] isEqualToString:@"."]) {
            NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
            NSString *subPath = [outPath componentsSeparatedByString:@"./"][1];
            outPath = [currentDirectory stringByAppendingPathComponent:subPath];
        } else if ([[outPath substringToIndex:1] isEqualToString:@"~"]) {
            NSString *currentDirectory = NSHomeDirectory();
            NSString *subPath = [outPath componentsSeparatedByString:@"~/"][1];
            outPath = [currentDirectory stringByAppendingPathComponent:subPath];
        } else {
            NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
            outPath = [currentDirectory stringByAppendingPathComponent:outPath];
        }
        
    }
    
    printf("Generating strings for \n folder: %s\n outPath: %s\n", [folder cStringUsingEncoding:NSUTF8StringEncoding], [outPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    //[FCGenstrings genstringsForDirectory:folder];
    [PPGenstrings genstringsForDirectory:folder WithOutputPath:outPath];
    
    printf("Finished generating strings\n");
    return 0;
}
