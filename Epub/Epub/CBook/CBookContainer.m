//
//  CBookContainer.m
//  TouchBook
//
//  Created by Jonathan Wight on 02/09/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CBookContainer.h"

#import "TouchXML.h"
#import "CBook.h"
#import "ZipArchive.h"

@implementation CBookContainer

@synthesize URL;

- (id)initWithURL:(NSURL *)inURL
{
    if ((self = [super init]) != NULL)
	{
        URL = [inURL retain];
	}
    return(self);
}

- (NSArray *)books
{
    if (books == NULL)
	{
        NSString *outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        outPath = [outPath
                   stringByAppendingPathComponent:[URL.lastPathComponent stringByDeletingPathExtension]];
        
        NSString *inPath = URL.path;
        
        ZipArchive *za = [[ZipArchive alloc] init];
        
        if([za UnzipOpenFile:inPath]) {
            BOOL ret = [za UnzipFileTo:[outPath stringByAppendingPathComponent:@"ext"] overWrite:YES];
            if(NO == ret) {
                // error handling
            }
            [za UnzipCloseFile];
        }
        [za release];
      	NSURL *theContainerURL = [NSURL fileURLWithPath:[outPath stringByAppendingPathComponent:@"ext/META-INF/container.xml"]];
        
        NSError *theError = NULL;
        CXMLDocument *theDocument = [[[CXMLDocument alloc] initWithContentsOfURL:theContainerURL options:0 error:&theError] autorelease];
        if (theDocument == NULL)
		{
            NSLog(@"%@", theError);
		}
        
        NSDictionary *theMappings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"urn:oasis:names:tc:opendocument:xmlns:container", @"NS",
                                     NULL];
        
        NSArray *theNodes = [theDocument nodesForXPath:@"/NS:container/NS:rootfiles/NS:rootfile" namespaceMappings:theMappings error:&theError];
        
        NSMutableArray *theBooks = [NSMutableArray array];
        
        for (CXMLElement *theElement in theNodes)
		{
            NSString *thePathComponent = [[theElement attributeForName:@"full-path"] stringValue];
            NSURL *theBookURL = [NSURL URLWithString:thePathComponent relativeToURL:[NSURL fileURLWithPath:[outPath stringByAppendingPathComponent:@"ext"]]];
            CBook *theBook = [[[CBook alloc] initWithURL:theBookURL rootURL:[theBookURL URLByDeletingLastPathComponent]] autorelease];
            [theBooks addObject:theBook];
		}
        
        books = [theBooks copy];
	}
    
    return(books);
}

@end
