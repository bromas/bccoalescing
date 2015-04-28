### BCCoalescing
This is a simple coalescing object that allows multiple observers to recieve callbacks from a single source. It can be used to reproduce behavior you might otherwise get from Notification Center but without the hassle of tightly coupling your code to it.

#### Installation
Using [Carthage](https://github.com/Carthage/Carthage) add

```shell
github "bromas/bccoalescing"
```

to your Cartfile

#### How it works

It's extremely simple and for that reason you might just want to look at the code. However, the one setence explanation is that you funnel callbacks into the coalescer in a 'perform operation' block, the coalescer performs any interpolation that you want to happen on the data, and then the callbacks are performed on each registered observer.

#### When to use it

You can coalesce all kinds of fun things. Think image downloads, disk access, location services, basically anything that is asyncronous and might be requested by multiple objects simultaneously.

#### Examples

Reading the unit tests should provide all of the information you need on using the provided objects, but here is a look at the API. 

```obj-c
__weak typeof(self) *weakself = self;
  [self.imageCoalescer addCallbackWithProgress:^(CGFloat percent) {
  } andCompletion:^(id result, NSURLResponse *response, NSError *error) {
      NSLog(@"completed!");
  } forIdentifier:@"uniqueIdentifier" withRequestPerformanceBlock:^{
      [weakself.session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"path to some image"]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [weakself.imageCoalescer identifier:@"uniqueIdentifier" completedWithData:data response:response andError:error];
    }];
  }];
```

This framework is consumed in a [sample project](https://github.com/bromas/TableSamples/blob/master/Table-ViewModel-Ideas/ANPostRequestManager.swift) available on github.

Initialize:

```swift
let coalesce = BCCoalesce()
var userIDIconMap: [String: UIImage] = [:]
init () {
  coalesce.shouldPerformCallbacksOnMainThread = true
  coalesce.resultsInterpolator = { data in
    let target = data as! NSData
    return UIImage(data: target)
  }
}
```

Add callbacks:

```swift
func imageForUser(forUser: AppNetUser, completion: (UIImage?) -> Void) -> Void {
	self.coalesce.addCallbacksWithProgress({ (_) -> Void in }, andCompletion: { (data, _, error) -> Void in
		self.userIDIconMap[forUser.userID] = data as? UIImage
		completion(self.userIDIconMap[forUser.userID])
	}, forIdentifier: forUser.userID) { () -> Void in
		Alamofire.request(.GET, forUser.avatarUrl).response { (_, _, data, error) -> Void in
			self.coalesce.identifier(forUser.userID, completedWithData: data as? NSData, andError: error)
  		}
  	}
}
```

