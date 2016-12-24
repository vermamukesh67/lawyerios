//
//  AppDelegate.m
//  LawyerDiary
//
//  Created by Singulars on 19/04/15.
//  Copyright (c) 2015 Singularsllp. All rights reserved.
//

#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "SubordinateClients.h"
#import "ClientsViewController.h"

static NSString * const kStoryboardName = @"Main";

static NSString * const kLeftDrawerStoryboardID = @"LeftDrawerViewControllerStoryboardID";

static NSString * const kCasesViewControllerStoryboardID = @"CasesTabBar";
static NSString * const kClientsViewControllerStoryboardID = @"ClientsTabBar";
static NSString * const kCourtsViewControllerStoryboardID = @"CourtsTabBar";
static NSString * const kProfileViewControllerStoryboardID = @"ProfileViewVC";
static NSString * const kSubordinatesViewControllerStoryboardID = @"Subordinates";
static NSString * const kSearchViewControllerStoryborrdID=@"Search";

Reachability *hostReach;

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIScreen *screen = [UIScreen mainScreen];
    NSLog(@"Screen width %.0f px, height %.0f px, scale %.1fx",
          (double) screen.bounds.size.width,
          (double) screen.bounds.size.height,
          (double) screen.scale);
    
    NSLog(@"Doc Dir Path => %@", [self applicationDocumentsDirectory]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(handleNetworkChange:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
    hostReach = [Reachability reachabilityForInternetConnection];
    //[Reachability reachabilityWithHostName:REACHABLE_HOST];
    [hostReach startNotifier];
    
    NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
    
    //    NSString *message = @"";
    if(remoteHostStatus == NotReachable)
    {
        NSLog(@"Internet Disconnected");
        //        message = @"Internet Disconnected.!";
        ShareObj.isInternetConnected = NO;  // Internet not Connected
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        //        message = @"Internet Connected via WIFI";
        NSLog(@"Connected via WIFI");
        ShareObj.isInternetConnected = YES; // Connected via WIFI
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        //        message = @"Internet Connected via WWAN";
        NSLog(@"Connected via WWAN");
        ShareObj.isInternetConnected = YES; // Connected via WWAN
    }
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    
    [_window makeKeyAndVisible];
    
    NSLog(@"isRegistered - %hhd", IsRegisteredForRemoteNotifications);
    
    [self getCurrentNotificationSettings];
//        [self registerForUserNotifications];
    
    [self registerForUserNotifications:^(BOOL success) {
        
    }];
    
    //    RemoveLoginUserId;
    
    if (GetLoginUserId) {
        
        [self setLastActiveDateTime];
        
        NSNumber *userId = GetLoginUserId;
        NSLog(@"userId - %@", userId);
        ShareObj.loginuserId = userId;
        ShareObj.userObj = [User fetchUser:ShareObj.loginuserId];
        
        NSLog(@"user => %@", ShareObj.userObj);
        
        [self showHome];
    }
    else {
        [self showLogIn];
    }
   
    if (launchOptions != nil)
    {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil)
        {
            NSString *string = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            
            UI_ALERT(@"Notification Received!", string, nil);
            
            NSLog(@"%@", userInfo);
        }
        else {
            NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
            
//            NSString *string = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
//            
//            UI_ALERT(@"Notification Received!", string, nil);
//            
//            NSLog(@"%@", userInfo);
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    if (GetLoginUserId) {
        NSDate *lastActiveDateTime = GetLastActiveTime;
        if (lastActiveDateTime) {
            if ([[lastActiveDateTime dateByAddingMinutes:10] compare:[NSDate date]] == NSOrderedAscending) {
                SetLastActiveTime([NSDate date]);
            }
        }
        else {
            SetLastActiveTime([NSDate date]);
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if (GetLoginUserId) {
        NSDate *lastActiveDateTime = GetLastActiveTime;
        if (lastActiveDateTime) {
            if ([[lastActiveDateTime dateByAddingMinutes:5] compare:[NSDate date]] == NSOrderedAscending) {
                SetLastActiveTime([NSDate date]);
            }
        }
        else {
            SetLastActiveTime([NSDate date]);
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (GetLoginUserId) { [self setLastActiveDateTime]; }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (GetLoginUserId) {
        [self setLastActiveDateTime];
        
        [ShareObj syncUpdatedCourtRecords];
        
        [ShareObj fetchCourts];
        [ShareObj fetchCourtsForSubordinate];
        
        [ShareObj fetchClients];
        [ShareObj fetchClientsForSubordinates];
        
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    if (GetLoginUserId) {
        NSDate *lastActiveDateTime = GetLastActiveTime;
        if (lastActiveDateTime) {
            if ([[lastActiveDateTime dateByAddingMinutes:5] compare:[NSDate date]] == NSOrderedAscending) {
                SetLastActiveTime([NSDate date]);
            }
        }
        else {
            SetLastActiveTime([NSDate date]);
        }
    }
    
    [self saveContext];
}

#pragma - Register For Remote Notificatios
#pragma - mark
- (void)registerForUserNotifications:(getDeviceTokenCompletionHandler)completionHandler
{
    getDeviceTokenHandler = [completionHandler copy];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
}

#pragma - APNS Metods...
#pragma - mark

#pragma mark - UIApplicationDelegate Callback
#pragma mark -

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Convert the token to a hex string and make sure it's all caps
    NSString *token = [[[deviceToken description]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                       stringByReplacingOccurrencesOfString:@" "
                       withString:@""];
    
    NSLog(@"token - %@",token);
    [ShareObj setDeviceToken:token];
    getDeviceTokenHandler(YES);
    getDeviceTokenHandler = nil;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [ShareObj setDeviceToken:@""];
    NSLog(@"%s ==> %@",__FUNCTION__,error);
    getDeviceTokenHandler(NO);
    getDeviceTokenHandler = nil;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    // user has allowed receiving user notifications of the following types
    UIUserNotificationType allowedTypes = [notificationSettings types];
    NSLog(@"APNS allowed type %u", allowedTypes);
    
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSString *string = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    
    if (application.applicationState == UIApplicationStateActive ||
        application.applicationState == UIApplicationStateBackground||
        application.applicationState == UIApplicationStateInactive) {
        
        UI_ALERT(@"Notification Received!", string, nil);
    }
    
    NSLog(@"%@", userInfo);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive ||
        application.applicationState == UIApplicationStateBackground||
        application.applicationState == UIApplicationStateInactive) {
        
        UI_ALERT(@"Notification Received!", notification.alertBody, nil);
    }
    
    NSLog(@"%@", notification.alertBody);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)getCurrentNotificationSettings
{
    UIUserNotificationSettings *userSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    ShareObj.currentNotificationType = userSettings.types;
    switch (ShareObj.currentNotificationType) {
        case UIUserNotificationTypeNone:
            NSLog(@"current notification type - None");
            break;
        case UIUserNotificationTypeBadge:
            NSLog(@"current notification type - Badge");
            break;
        case UIUserNotificationTypeSound:
            NSLog(@"current notification type - Sound");
            break;
        case UIUserNotificationTypeAlert:
            NSLog(@"current notification type - Alert");
            break;
        default:
            break;
    }
}

#pragma mark - SetLastActiveDateTime
#pragma mark -
- (void)setLastActiveDateTime
{
    NSDate *lastActiveDateTime = GetLastActiveTime;
    if (lastActiveDateTime) {
        if ([[lastActiveDateTime dateByAddingMinutes:5] compare:[NSDate date]] == NSOrderedAscending) {
            SetLastActiveTime([NSDate date]);
            
        }
        else {
        }
    }
    else {
        SetLastActiveTime([NSDate date]);
    }
}

#pragma mark - Show LogIn
#pragma mark -
- (void)showLogIn
{
    if (_registerNavController == nil) {
        _registerNavController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kRegisterNavController];
    }
    
    [UIView transitionWithView:_window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [_window setRootViewController:_registerNavController];
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:^(BOOL finished) {

                    }];
}

#pragma mark - Show Home
#pragma mark -
- (void)showHome
{
    [self configureDrawerViewController];
    
    [UIView transitionWithView:_window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [_window setRootViewController:self.drawerViewController];
                        
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:^(BOOL finished) {
                        if (IS_INTERNET_CONNECTED) {
                            [ShareObj fetchSubordinatesWithCompletionHandler:^(BOOL finished) {
                                
                            }];
                        }
                        
                        [ShareObj fetchCourts];
                        [ShareObj fetchCourtsForSubordinate];
                        
                        [ShareObj fetchClients];
                        [ShareObj fetchClientsForSubordinates];
                    }];
}

#pragma mark - Drawer View Controllers

- (JVFloatingDrawerViewController *)drawerViewController {
    if (!_drawerViewController) {
        _drawerViewController = [[JVFloatingDrawerViewController alloc] init];
        [_drawerViewController setLeftDrawerWidth:300];
    }
    
    return _drawerViewController;
}

- (UIStoryboard *)mainStoryboard {
    if(!_mainStoryboard) {
        _mainStoryboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:nil];
    }
    
    return _mainStoryboard;
}

#pragma mark Sides

+ (AppDelegate *)globalDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (UIViewController *)leftDrawerViewController {
    if (!_leftDrawerViewController) {
        _leftDrawerViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kLeftDrawerStoryboardID];
    }
    
    return _leftDrawerViewController;
}

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    if (!_drawerAnimator) {
        _drawerAnimator = [[JVFloatingDrawerSpringAnimator alloc] init];
        
        [_drawerAnimator setInitialSpringVelocity:1.0];
        [_drawerAnimator setSpringDamping:1.0];
        [_drawerAnimator setAnimationDelay:0.0];
        [_drawerAnimator setAnimationDuration:0.5];
    }
    
    return _drawerAnimator;
}

- (void)configureDrawerViewController {
    self.drawerViewController.leftViewController = self.leftDrawerViewController;
    self.drawerViewController.centerViewController = self.casesTabBar;
    
    self.drawerViewController.animator = self.drawerAnimator;
    
    self.drawerViewController.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
}

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}

#pragma mark Cent
- (CasesTabBar *)casesTabBar {
//    if (!_casesTabBar) {
//        _casesTabBar = [self.mainStoryboard instantiateViewControllerWithIdentifier:kCasesViewControllerStoryboardID];
//    }
    _casesTabBar = [self.mainStoryboard instantiateViewControllerWithIdentifier:kCasesViewControllerStoryboardID];
    
    _casesTabBar.modeType = kTYPE_CASE_LIST;
    return _casesTabBar;
}

- (ClientsTabBar *)clientsTabBar {
    if (!_clientsTabBar) {
        
        
//        _clientsTabBar = [[UITabBarController alloc] init];
//        [_clientsTabBar.tabBar setTintColor:BLACK_COLOR];
//        
//        ClientsViewController *clientsVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"ClientsVC"];
//        SubordinateClients *subordinateClients = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"SClients"];
//        
//        UINavigationController *clientNavController = [[UINavigationController alloc] initWithRootViewController:clientsVC];
//        UINavigationController *sClientNavController = [[UINavigationController alloc] initWithRootViewController:subordinateClients];
//        
//        [_clientsTabBar setViewControllers:@[clientNavController, sClientNavController]];
//        
//        UITabBarItem *itemOne = [[_clientsTabBar.tabBar items] objectAtIndex:0];
//        [itemOne setTitle:@"Your"];
//        [itemOne setImage:IMAGE_WITH_NAME(@"icon-tab-profile")];
//        
//        UITabBarItem *itemTwo = [[_clientsTabBar.tabBar items] objectAtIndex:1];
//        [itemTwo setTitle:@"Subordinates"];
//        [itemTwo setImage:IMAGE_WITH_NAME(@"icon-tab-subordinate")];
        
//        _clientsTabBar = [self.mainStoryboard instantiateViewControllerWithIdentifier:kClientsViewControllerStoryboardID];
    }
    _clientsTabBar = [self.mainStoryboard instantiateViewControllerWithIdentifier:kClientsViewControllerStoryboardID];
    
    return _clientsTabBar;
}

- (CourtsTabBar *)courtsTabBar {
    if (!_courtsTabBar) {
//        _courtsTabBar = [self.mainStoryboard instantiateViewControllerWithIdentifier:kCourtsViewControllerStoryboardID];
    }
    _courtsTabBar = [self.mainStoryboard instantiateViewControllerWithIdentifier:kCourtsViewControllerStoryboardID];
    
    return _courtsTabBar;
}

- (Profile *)profileViewController {
//    if (!_profileViewController) {
//        _profileViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kProfileViewControllerStoryboardID];
//    }
    _profileViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kProfileViewControllerStoryboardID];
    
    return _profileViewController;
}

- (CasesTabBar *)casesRecycleBin {
    //    if (!_profileViewController) {
    //        _profileViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kProfileViewControllerStoryboardID];
    //    }
    _casesRecycleBin = [self.mainStoryboard instantiateViewControllerWithIdentifier:kCasesViewControllerStoryboardID];
    _casesRecycleBin.modeType = kTYPE_CASE_RECYCLE_BIN;
    return _casesRecycleBin;
}

- (CasesTabBar *)casesHistory {
    //    if (!_profileViewController) {
    //        _profileViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kProfileViewControllerStoryboardID];
    //    }
    _casesHistory = [self.mainStoryboard instantiateViewControllerWithIdentifier:kCasesViewControllerStoryboardID];
    _casesHistory.modeType = kTYPE_CASE_HISTORY;
    return _casesHistory;
}

- (Subordinates *)subordinatesViewController {
//    if (!_subordinatesViewController) {
//        _subordinatesViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kSubordinatesViewControllerStoryboardID];
//    }
    _subordinatesViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kSubordinatesViewControllerStoryboardID];
    
    return _subordinatesViewController;
}

- (Search *)searchViewController {
//    if (!_searchViewController) {
//        _searchViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kSearchViewControllerStoryborrdID];
//    }
    _searchViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:kSearchViewControllerStoryborrdID];
    
    return _searchViewController;
}

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDataModel withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"REDBOOK.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Reachability Change Notification
#pragma mark -

- (void)handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        NSLog(@"Internet Disconnected");
        ShareObj.isInternetConnected = NO;  // Internet not Connected
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        //        message = @"Internet Connected via WIFI";
        NSLog(@"Connected via WIFI");
        ShareObj.isInternetConnected = YES; // Connected via WIFI
        
        if (GetLoginUserId) {
            [ShareObj syncUpdatedCourtRecords];
            
            [ShareObj fetchSubordinatesWithCompletionHandler:^(BOOL finished) {
                
            }];
        }
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        NSLog(@"Connected via WWAN");
        ShareObj.isInternetConnected = YES; // Connected via WWAN
        
        if (GetLoginUserId) {
            [ShareObj syncUpdatedCourtRecords];
            
            [ShareObj fetchSubordinatesWithCompletionHandler:^(BOOL finished) {
                
            }];
        }
    }
}
@end
