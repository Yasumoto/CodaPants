//
//  PantsPlugin.m
//  CodaPants
//
//  Created by Joseph Smith on 8/25/15.
//  Copyright © 2015 bjoli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodaPlugInsController.h"

@interface PantsPlugin : NSObject <CodaPlugIn>

@property (nonatomic, strong) CodaPlugInsController *controller;

@end

@implementation PantsPlugin

@synthesize controller = _controller;

- (NSString *) name {
    return @"Pants";
}

- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject *)plugInBundle {
    [aController registerActionWithTitle:@"Test" underSubmenuWithTitle:@"Python" target:self selector:@selector(python_test) representedObject:self keyEquivalent:@"^T" pluginName:@"Pants"];
    self.controller = aController;
    return self;
}

- (void) python_test {
    NSString *pantsPath = [[self.controller siteLocalPath] stringByAppendingString:@"/pants"];
    NSString *sourceFilePath = [[self.controller focusedTextView] path];
    NSArray *pathChunks = [sourceFilePath componentsSeparatedByString:@"/"];
    NSString *testPath = @"";
    for (NSString *directory in pathChunks) {
        if ([directory isEqualToString:@"src"]) {
            testPath = [testPath stringByAppendingString:@"tests"];
            testPath = [testPath stringByAppendingString:@"/"];
        } else if ([directory containsString:@".py"]) {
            testPath = [testPath stringByAppendingString:@":"];
            testPath = [testPath stringByAppendingString:[[directory componentsSeparatedByString:@".py"] objectAtIndex:0]];
        } else {
            testPath = [testPath stringByAppendingString:directory];
            testPath = [testPath stringByAppendingString:@"/"];
        }
    }

    NSTask *pantsTest = [[NSTask alloc] init];
    [pantsTest setCurrentDirectoryPath:[self.controller siteLocalPath]];
    [pantsTest setLaunchPath:pantsPath];
    [pantsTest setArguments:@[@"test.pytest", testPath]];
    [pantsTest setStandardError:[NSPipe pipe]];
    [pantsTest setStandardOutput:[NSPipe pipe]];
    [pantsTest launch];
    [pantsTest waitUntilExit];

    CodaTextView *pantsOutput = [self.controller makeUntitledDocument];
    [pantsOutput insertText:@"Standard Error: \n"];
    [pantsOutput insertText:[[NSString alloc] initWithData:[[[pantsTest standardError] fileHandleForReading] readDataToEndOfFile] encoding: NSUTF8StringEncoding]];
    [pantsOutput insertText:@"\n"];

    [pantsOutput insertText:@"Standard Output: \n"];
    [pantsOutput insertText:[[NSString alloc] initWithData:[[[pantsTest standardOutput] fileHandleForReading] readDataToEndOfFile] encoding: NSUTF8StringEncoding]];
    [pantsOutput insertText:@"\n"];

}

@end

