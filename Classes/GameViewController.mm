    //
//  GameViewController.mm
//  DGSPhone
//
//  Created by Justin Weiss on 6/5/10.
//  Copyright 2010 Avvo. All rights reserved.
//

#import "GameViewController.h"
#import "Board.h"

@implementation GameViewController

@synthesize game;
@synthesize boardView;
@synthesize scrollView;
@synthesize boardState;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIScrollView *tempScrollView=(UIScrollView *)self.scrollView;
    tempScrollView.contentSize=CGSizeMake(self.boardView.bounds.size.height, self.boardView.bounds.size.width);
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)theScrollView withScale:(float)scale withCenter:(CGPoint)center {
	
    CGRect zoomRect;
	
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = theScrollView.frame.size.height / scale;
    zoomRect.size.width  = theScrollView.frame.size.width  / scale;
	
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
	
    return zoomRect;
}

- (void)handleGoBoardTouch:(UITouch *)touch inView:(GoBoardView *)view {
	
	if ([self boardState] == kBoardStateStoneNotPlaced) {
		CGRect zoomRect = [self zoomRectForScrollView:[self scrollView] withScale:2.0 withCenter:[touch locationInView:view]];
		[[self scrollView] zoomToRect:zoomRect animated:YES];
		[self setBoardState:kBoardStateZoomedIn];
	} else if ([self boardState] == kBoardStateZoomedIn) {
		if ([view playStoneAtPoint:[touch locationInView:view]]) {
			[view setNeedsDisplay];
			CGRect zoomRect = [self zoomRectForScrollView:[self scrollView] withScale:0.5 withCenter:[touch locationInView:view]];
			[[self scrollView] zoomToRect:zoomRect animated:YES];
			[self setBoardState:kBoardStateStonePlaced];
		}
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.boardView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)theScrollView withView:(UIView *)view atScale:(float)scale {
	
	float zoomScale=theScrollView.zoomScale;
	CGSize newContentSize=theScrollView.contentSize;
	CGPoint newContentOffset=theScrollView.contentOffset;
	CGSize oldContentViewSize=[boardView frame].size;
	
	float xMult=newContentSize.width/oldContentViewSize.width;
	float yMult=newContentSize.height/oldContentViewSize.height;
	
	newContentOffset.x *=xMult;
	newContentOffset.y *=yMult;
	
	float currentMinZoom=theScrollView.minimumZoomScale;
	float currentMaxZoom=theScrollView.maximumZoomScale;
	
	float newMinZoom=currentMinZoom/zoomScale;
	float newMaxZoom=currentMaxZoom/zoomScale;
	
	[theScrollView setMinimumZoomScale:1.0];
	[theScrollView setMaximumZoomScale:1.0];
	[theScrollView setZoomScale:1.0 animated:NO];
	
	[boardView setFrame:CGRectMake(0,0,newContentSize.width,newContentSize.height)];
	theScrollView.contentSize=newContentSize;
	[theScrollView setContentOffset:newContentOffset animated:NO];
	
	[theScrollView setMinimumZoomScale:newMinZoom];
	[theScrollView setMaximumZoomScale:newMaxZoom];
	
	[boardView setNeedsDisplay];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setBoardState:kBoardStateStoneNotPlaced];
	Board *board = [[Board alloc] initWithSGFString:[game sgfString] boardSize:19];
	[[self boardView] setBoard:board];
	[board release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.boardView = nil;
	self.game = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end