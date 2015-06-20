//
//  DescriptionViewController.m
//  The Bat
//
//  Created by Mert Akanay on 5/21/15.
//  Copyright (c) 2015 mertakanay. All rights reserved.
//

#import "DescriptionViewController.h"
#import <MapKit/MapKit.h>
@import GoogleMaps;

@interface DescriptionViewController () <CLLocationManagerDelegate, UITextViewDelegate, GMSMapViewDelegate>

@property CLLocationManager *locationManager;
@property GMSMapView *gMapView;

@end

@implementation DescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];

    self.gMapView.delegate = self;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: self.locationManager.location.coordinate.latitude longitude: self.locationManager.location.coordinate.longitude zoom: 13];
    self.gMapView = [GMSMapView mapWithFrame:CGRectMake(0, 64, 320, 150) camera:camera];
    [self.view addSubview:self.gMapView];

    self.gMapView.settings.compassButton = YES;
    self.gMapView.settings.myLocationButton = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.gMapView.myLocationEnabled = YES;
        [self getCurrentLocation];
    });

}

-(void) getCurrentLocation
{
    GMSPlacesClient *placesClient= [[GMSPlacesClient alloc] init];

    [placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }

        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            NSLog(@"Current Place address %@", place.formattedAddress);
            NSLog(@"Current Place attributions %@", place.attributions);
            NSLog(@"Current PlaceID %@", place.placeID);
        }
        
    }];

}

- (IBAction)pickPlace:(UIBarButtonItem *)sender {

    GMSVisibleRegion visibleRegion = self.gMapView.projection.visibleRegion;
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                         coordinate:visibleRegion.nearRight];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    GMSPlacePicker *placePicker = [[GMSPlacePicker alloc] initWithConfig:config];

    [placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }

        if (place != nil) {

            NSLog(@"Place selected: %@", place.name);

            GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
            marker.title = place.name;
            marker.snippet = place.formattedAddress;
            marker.map = self.gMapView;

        } else {
            NSLog(@"No place selected");
        }
        
    }];
}



@end
