//
//  MKPolyline+EncodedString.m
//  MKMapSample
//
//  Created by Ziyang Tan on 7/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

#import "MKPolyline+EncodedString.h"

@implementation MKPolyline (EncodedString)

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    NSLog(@"%s", bytes);
    
    double latitude = 0;
    double longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        double deltaLat = ((res & 1) != 0 ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        double deltaLon = ((res & 1) != 0 ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        double finalLat = latitude * 1E-5;
        double finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
        
        NSLog(@"%f, %f", deltaLat, deltaLon);
    }
    
    NSLog(@"%lu", (unsigned long)length);
    NSLog(@"%lu", (unsigned long)count);
    NSLog(@"%lu", (unsigned long)coordIdx);
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
  //  free(coords);
    
    return polyline;
}

@end