// Accelermeter with Hipass filter
//


#import "AccelerometerFilter.h"

// Implementation of the basic filter. All it does is mirror input to output.

@implementation AccelerometerFilter

@synthesize x, y, z, adaptive;

-(void)addAcceleration:(UIAcceleration*)accel
{
	x = accel.x;
	y = accel.y;
	z = accel.z;
}

@end

#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0

double Norm(double x, double y, double z)
{
	return sqrt(x * x + y * y + z * z);
}

double Clamp(double v, double min, double max)
{
	if(v > max)
		return max;
	else if(v < min)
		return min;
	else
		return v;
}

@implementation HighpassFilter

-(id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	self = [super init];
	if(self != nil)
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = RC / (dt + RC);
	}
	return self;
}

-(void)addAcceleration:(UIAcceleration*)accel
{
	double alpha = filterConstant;
	
	if(adaptive)
	{
		double d = Clamp(fabs(Norm(x, y, z) - Norm(accel.x, accel.y, accel.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = d * filterConstant / kAccelerometerNoiseAttenuation + (1.0 - d) * filterConstant;
	}
	
	x = alpha * (x + accel.x - lastX);
	y = alpha * (y + accel.y - lastY);
	z = alpha * (z + accel.z - lastZ);
	
	lastX = accel.x;
	lastY = accel.y;
	lastZ = accel.z;
}

@end