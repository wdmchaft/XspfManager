//
//  XspfManager_AppDelegate.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright masakih 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMWorkerProtocols.h"

@class XSPFMXspfObject;
@protocol UKFileWatcher;

@interface XspfManager : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	id<HMChannel> channel;
}

- (NSString *)applicationSupportFolder;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

- (IBAction)launchXspfQT:(id)sender;

- (id<HMChannel>)channel;


- (BOOL)didRegisteredURL:(NSURL *)url;
- (XSPFMXspfObject *)registerWithURL:(NSURL *)url;
- (void)registerFilePaths:(NSArray *)filePaths;
- (void)registerURLs:(NSArray *)URLs;
- (void)removeObject:(XSPFMXspfObject *)object;

- (void)registerToUKKQueue;
- (void)watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString*)notificationName forPath:(NSString*)filePath;

@end

extern NSString *const XspfManagerDidAddXspfObjectsNotification; // @"XspfManagerAddedXspfObjects"
