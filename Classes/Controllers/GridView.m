// GridView.m
// Kaya Labs, Inc

#import "GridView.h"


@implementation GridView

- (id) initWithRows: (int) rows_ cols: (int) cols_ {
	self = [super init];
	if (self == nil) return nil;
	rows = rows_;
	cols = cols_;
	rowHeight = malloc(rows * sizeof(int));
	colWidth = malloc(cols * sizeof(int));
	return self;
}

- (void) dealloc {
	free(rowHeight);
	free(colWidth);
	[super dealloc];
}

- (void)addSubview:(UIView *)view {
	int index = [self.subviews count];
	int y = index / cols;
	int x = index - y * cols;
	if (x == 0) rowHeight[y] = view.frame.size.height;
	if (y == 0) colWidth[x] = view.frame.size.width;
	int xOrigin = 0;
	for (int i = 0; i < x; ++i) xOrigin += colWidth[i];
	int yOrigin = 0;
	for (int i = 0; i < y; ++i) yOrigin += rowHeight[i];
	view.frame = CGRectMake(xOrigin, yOrigin,
							view.frame.size.width, view.frame.size.height);
	if (index == (rows * cols - 1)) {
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
								xOrigin + colWidth[cols - 1],
								yOrigin + rowHeight[rows - 1]);
	}
	[super addSubview:view];
}

@end
