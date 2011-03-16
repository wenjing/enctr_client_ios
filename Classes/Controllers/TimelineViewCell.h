
// TimelineViewCell.h


#import "BaseTableViewCell.h"
#import "HJManagedImageV.h"
#import "Timeline.h"

@interface TimelineViewCell : BaseTableViewCell 
{
	Timeline	*_timeline ;
	HJManagedImageV *userImage;
	HJManagedImageV *topicImage;
}

@property (nonatomic, assign) Timeline*  _timeline;

@end
