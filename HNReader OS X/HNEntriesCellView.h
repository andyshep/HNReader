//
//  HNEntriesCellView.h
//  HNReader
//
//  Created by Andrew Shepard on 11/28/14.
//
//

#import <Cocoa/Cocoa.h>

@interface HNEntriesCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField *siteTitleField;
@property (nonatomic, strong) IBOutlet NSTextField *siteDomainField;
@property (nonatomic, strong) IBOutlet NSTextField *totalPointsField;

@end
