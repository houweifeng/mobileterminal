// Settings.m
// MobileTerminal

#import "Settings.h"

#import "MenuSettings.h"
#import "TerminalSettings.h"

// This file is autogenerated by the build rules
#import "svnversion.h"

@implementation Settings

@synthesize menuSettings;

static NSString* kSettingsKey = @"com.googlecode.mobileterminal.Settings";
static NSString* kVersionKey = @"version";
static NSString* kMenuSettings = @"menuSettings";
static NSString* kTerminalFormatKey = @"terminal%d";

+ (Settings*)sharedInstance
{
  static Settings* settings = nil;
  if (settings == nil) {
    settings = [Settings readSettings];
  }
  return settings;
}

+ (Settings*)readSettings
{
  NSData* data =
      [[NSUserDefaults standardUserDefaults] dataForKey:kSettingsKey];  
  if (data != nil) {
    return (Settings*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
  } else {
    return [[Settings alloc] initWithDefaultValues];
  }
}

+ (void)persistSettings:(Settings*)settings
{
  NSData* data = [NSKeyedArchiver archivedDataWithRootObject:settings];
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:kSettingsKey];
}

- (id) init
{
  return [self initWithCoder:nil];
}

- (id)initWithDefaultValues
{
  self = [self init];
  
  // TODO(allen): Put defaults values in an XML file.  Maybe using an XML file
  // would have been better than using NSUserDefaults.
  [menuSettings addMenuItem:[MenuItem itemWithLabel:@"ls" andCommand:@"ls"]];
  [menuSettings addMenuItem:[MenuItem itemWithLabel:@"ls -l" andCommand:@"ls -l\n"]];  
  [menuSettings addMenuItem:[MenuItem itemWithLabel:@"ssh" andCommand:@"ssh "]];  
  [menuSettings addMenuItem:[MenuItem itemWithLabel:@"locate" andCommand:@"locate"]];  
  [menuSettings addMenuItem:[MenuItem itemWithLabel:@"ping www.google.com" andCommand:@"ping www.google.com\n"]];  
  [menuSettings addMenuItem:[MenuItem itemWithLabel:@"^C" andCommand:@"\x03"]];  
  
  return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super init];
  if (self != nil) {
    if ([decoder containsValueForKey:kVersionKey]) {
      int version = [decoder decodeIntForKey:kVersionKey];
      NSLog(@"Settings previously written by: %d", version);
    }
    if ([decoder containsValueForKey:kMenuSettings]) {
      menuSettings = [[decoder decodeObjectForKey:kMenuSettings] retain];
    } else {
      menuSettings = [[MenuSettings alloc] init];
    }
    for (int i = 0; i < TERMINAL_COUNT; ++i) {
      NSString* key = [NSString stringWithFormat:kTerminalFormatKey, i];    
      if ([decoder containsValueForKey:key]) {
        terminalSettings[i] = [[decoder decodeObjectForKey:key] retain];
      } else {
        terminalSettings[i] = [[TerminalSettings alloc] init];
      }
    }
  }
  return self;
}

- (void) dealloc
{
  for (int i = 0; i < TERMINAL_COUNT; ++i) {
    [terminalSettings[i] release];
  }
  [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
  // include svn revision for future backwards compatibility
  [encoder encodeInt:SVN_VERSION forKey:kVersionKey];
  
  [encoder encodeObject:menuSettings forKey:kMenuSettings];
  for (int i = 0; i < TERMINAL_COUNT; ++i) {
    NSString* key = [NSString stringWithFormat:kTerminalFormatKey, i];    
    [encoder encodeObject:terminalSettings[i] forKey:key];
  }
}

@end
