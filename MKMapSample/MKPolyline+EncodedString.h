//
//  MKPolyline+EncodedString.h
//  MKMapSample
//
//  Created by Ziyang Tan on 7/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

@import UIKit;
@import MapKit;

@interface MKPolyline (EncodedString)

+(MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end