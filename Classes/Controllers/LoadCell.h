//
//  LoadCell.h
//

#import <UIKit/UIKit.h>

typedef enum {
    MSG_TYPE_LOAD_FROM_WEB,
    MSG_TYPE_LOAD_FROM_DB,
    MSG_TYPE_LOADING,
    MSG_TYPE_REQUEST_SENT
} loadCellType;

@interface LoadCell : UITableViewCell {
    UILabel*                    label;
	UIActivityIndicatorView*    spinner;
    loadCellType                type;
}

@property(nonatomic, readonly) UIActivityIndicatorView* spinner;
@property(nonatomic, assign)   loadCellType type;

- (void)setType:(loadCellType)type;

@end
