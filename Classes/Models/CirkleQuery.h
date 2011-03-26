#import <UIKit/UIkit.h>
#import "Cirkle.h"
#import "QueryProtocol.h"

@interface CirkleQuery : QueryBase
{
}
- (id)recordClass;
- (id)trimData:(id)obj;
@end
