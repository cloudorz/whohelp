//
//  ProfileManager.m
//  WhoHelp
//
//  Created by cloud on 11-10-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ProfileManager.h"
#import "WhoHelpAppDelegate.h"
static ProfileManager *sharedProfileManager = nil;

@implementation ProfileManager
@synthesize profile=profile_, moc=moc_;


- (id)init
{
  	self = [super init];
	if (self != nil) {

        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
    
            
        // Create request
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        // config the request
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile"  inManagedObjectContext:self.moc];
        [request setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isLogin == YES"]];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[self.moc executeFetchRequest:request error:&error] mutableCopy];
        [request release];
        
        if (error == nil) {
            if ([mutableFetchResults count] > 0) {
                
                self.profile = [mutableFetchResults objectAtIndex:0];
            }
            
        } else {
            // Handle the error FIXME
            NSLog(@"Get by profile error: %@, %@", error, [error userInfo]);
        }
        
        [mutableFetchResults release];
        
	}
	return self;
}

- (void)save
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.moc;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        } 
    }
}

- (void)del
{
    [self.moc deleteObject:self.profile];
    [self save];
    self.profile = nil;
}

- (void)saveUserInfo:(NSMutableDictionary *) data
{
    
    Profile *profile = (Profile *)[self getProfileByPhone:[data objectForKey:@"phone"]];
    
    if (profile == nil){
        profile =  (Profile *)[NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.moc];
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    profile.name = [data objectForKey:@"name"];
    profile.phone = [data objectForKey:@"phone"];
    profile.token = [data objectForKey:@"token"];
    profile.updated = [dateFormatter dateFromString:[data objectForKey:@"updated"]];
    profile.isLogin = [NSNumber numberWithBool:TRUE];
    
    [self save];
    
    self.profile = profile;
    
    [dateFormatter release];
}

- (void)logout
{
    if (nil != self.profile){
        self.profile.isLogin = NO;
        [self save];
    }
}

#pragma mark - database operation
- (NSManagedObject *)getProfileByPhone:(NSNumber *)phone
{
    // Create request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // config the request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile"  inManagedObjectContext:self.moc];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"phone == %@", phone]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.moc executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    
    NSManagedObject *res = nil;
    if (error == nil) {
        if ([mutableFetchResults count] > 0) {
            
            res = [mutableFetchResults objectAtIndex:0];
        }
        
    } else {
        // Handle the error FIXME
        NSLog(@"Get by profile error: %@, %@", error, [error userInfo]);
    }
    
    [mutableFetchResults release];
    return res;
    
}

+ (ProfileManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedProfileManager == nil) {
            [[self alloc] init];
        }
    }
    return sharedProfileManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedProfileManager == nil) {
            sharedProfileManager = [super allocWithZone:zone];
            return sharedProfileManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (void)dealloc
{
    [moc_ release];
    [profile_ release];
    [super dealloc];
    
}

- (id)autorelease
{
    return self;
}

@end
