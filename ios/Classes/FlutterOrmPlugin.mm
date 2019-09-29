#import "FlutterOrmPlugin.h"
#import <LuakitPod/lua_helpers.h>
#import <LuakitPod/oc_helpers.h>

@implementation FlutterOrmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_orm_plugin"
            binaryMessenger:[registrar messenger]];
    FlutterOrmPlugin* instance = [[FlutterOrmPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    NSString* key = [registrar lookupKeyForAsset:@"packages/flutter_orm_plugin/lua"];
    NSString* path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *luakitPath = [NSString stringWithFormat:@"%@/luakit",documentsDirectory];
    BOOL isDirectory = ([[NSFileManager defaultManager] fileExistsAtPath:luakitPath isDirectory:&isDirectory] && isDirectory);
    if (!isDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:luakitPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self copyFolderWithAllContentsOfPath:path intoPath:luakitPath error:nil];
    const char * pathChar =[luakitPath UTF8String];
    luaSetPackagePath(pathChar);
    startLuakit(0, NULL);
}

+ (void)copyFolderWithAllContentsOfPath:(NSString *)srcDir intoPath:(NSString *)dstDir error:(NSError**)err {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *srcDirEnum = [fm enumeratorAtPath:srcDir];
    NSString *subPath;
    while ((subPath = [srcDirEnum nextObject])) {
        NSString *srcFullPath = [srcDir stringByAppendingPathComponent:subPath];
        NSString *potentialDstPath = [dstDir stringByAppendingPathComponent:subPath];
        BOOL isDirectory = ([[NSFileManager defaultManager] fileExistsAtPath:srcFullPath isDirectory:&isDirectory] && isDirectory);
        if (isDirectory) {
            [fm createDirectoryAtPath:potentialDstPath withIntermediateDirectories:YES attributes:nil error:err];
            if (err && *err) {
                return;
            }
        }
        else {
            if ([fm fileExistsAtPath:potentialDstPath]) {
                [fm removeItemAtPath:potentialDstPath error:err];
                if (err && *err) {
                    return;
                }
            }
            [fm copyItemAtPath:srcFullPath toPath: potentialDstPath  error:err];
            if (err && *err) {
                return;
            }
        }
    }
}

@end
