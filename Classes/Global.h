//
//  Global.h
//  DoView
//
//  Created by okera on 10/12/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG 
#define LOG(...) NSLog(__VA_ARGS__)
#else
#define LOG(...) 
#endif

@interface Global : NSObject {

}

@end
