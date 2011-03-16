// GridView.h
// Kaya Labs, Inc

#import <Foundation/Foundation.h>


@interface GridView : UIView {
	int rows;
	int cols;

	int* rowHeight;
	int* colWidth;
}

- (id) initWithRows: (int) rows_ cols: (int) cols_;

@end
