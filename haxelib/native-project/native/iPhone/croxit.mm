#ifndef STATIC_LINK
	#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif
#include "croxit_events.h"

#import <UIKit/UIKit.h>
//missing:
//ngap_on_handler

//
//  WebViewController.h
//  Webview
//
//  Created by Edgar Allan Poe on 1/27/12.
//  Copyright 2012 cmt. All rights reserved.
//

@interface WebViewController : UIViewController<UIWebViewDelegate> {
    IBOutlet UIWebView *webview;
	NSString *baseRequest;
}

@property (nonatomic, retain) UIWebView *webview;
@property (nonatomic, retain) NSString *baseRequest;

- (void)loadHome;

- (void)loadUrl:(NSURLRequest *)requestObj;

- (void)loadWithPath:(NSString *)url;

@end


//
//  WebviewAppDelegate.h
//  Webview
//
//  Created by Edgar Allan Poe on 1/27/12.
//  Copyright 2012 cmt. All rights reserved.
//

@interface WebviewAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

extern "C"
{
	typedef struct ngap_request
	{
		NSURLRequest *requestObject;
		NSString *baseRequest;
		char *to_redirect;
		AutoGCRoot *print_contents;
		char *mime;
		char *encoding;
		
		bool skip;
		
	} ngap_request;
	
	ngap_request ngap_context;
	bool ngap_allow_external;
	
	AutoGCRoot *ngap_main_callback;
	AutoGCRoot *ngap_error_callback;
	AutoGCRoot *ngap_autorotate_callback;
	
	AutoGCRoot *ngap_global_event_handler;
	AutoGCRoot *ngap_activate_event_handler;
	
	value ngap_dispatch_event(value name, value args)
	{
		if (ngap_global_event_handler && ngap_global_event_handler->get())
			return val_call2(ngap_global_event_handler->get(), name, args);
		return alloc_null();
	}
	
	bool should_load_web_view;
	
	WebViewController *web_view_controller;
	
	char *value_string_copy(value str)
	{
		const char *_str = val_string(str);
		int len = val_strlen(str);
		char *_new = (char *) (malloc(sizeof(char *) * (len + 1)));
		memcpy(_new, _str, len);
		_new[len] = NULL;
		
		return _new;
	}
	
	ngap_request new_ngap_request(NSURLRequest *requestObject, NSString *baseRequest)
	{
		return (ngap_request){ requestObject, baseRequest, NULL, new AutoGCRoot((value)alloc_buffer_len(0)), NULL, NULL, false };
	}
}

@implementation WebViewController

@synthesize webview;
@synthesize baseRequest;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	if (ngap_global_event_handler && ngap_global_event_handler->get())
		val_call2(ngap_global_event_handler->get(), alloc_string("on_memory_warning"), val_null);
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    contentView.backgroundColor = [UIColor blackColor];
    
	//TODO expose this API
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.view = contentView;
    self.view.autoresizesSubviews = YES;
    
    CGRect webframe = [[UIScreen mainScreen] bounds];
	//space for the header TODO expose this API
    //webframe.origin.y -= 20.0;
    UIWebView *aWebView = [[UIWebView alloc] initWithFrame:webframe];
    self.webview = aWebView;
	 aWebView.allowsInlineMediaPlayback = YES;
	 aWebView.mediaPlaybackRequiresUserAction = NO;
	 aWebView.delegate = self; 
    
    aWebView.autoresizesSubviews = YES;
    aWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    //[aWebView setDelegate:self];
	
    [contentView addSubview:webview];
    
    [aWebView release];
    [contentView release];
    
	//BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:somePath];
	
}

- (void)callJS:(NSMutableArray *)jsObj
{
	NSString *ret = [webview stringByEvaluatingJavaScriptFromString: [jsObj objectAtIndex:0]];
	[jsObj replaceObjectAtIndex:0 withObject:ret];
}

- (void)loadHome
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:[baseRequest stringByAppendingPathComponent:@"index.html"]])
	{
		[self loadWithPath:@"index.html"];
	} else if ([[NSFileManager defaultManager] fileExistsAtPath:[baseRequest stringByAppendingPathComponent:@"index.html"]])
	{
		[self loadWithPath:@"index.htm"];
	} else {
		//NSLog(@"calling the base request %@", baseRequest);
		[self loadUrl:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:baseRequest]]];
	}
}

- (void)loadUrl:(NSURLRequest *)requestObj
{
	[webview loadRequest:requestObj];
}

- (void)loadWithPath:(NSString *)url
{
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url relativeToURL:[NSURL fileURLWithPath: baseRequest]]];
	[self loadUrl:req];
} 

#pragma mark - UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSString *errorString = [error localizedDescription];
	NSLog(@"ERROR; %@", errorString);
	if (!ngap_error_callback || !ngap_error_callback->get())
	{
		NSString *errorTitle = [NSString stringWithFormat:@"Error"];

		UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:errorTitle message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[errorView show];
		[errorView autorelease];
	} else {
		val_call2(ngap_error_callback->get(), 0, alloc_string([errorString UTF8String]));
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSURL *url = [request URL];
	NSString *baseReq = baseRequest;
	NSString *baseReqPrefix = [baseReq substringToIndex:([baseReq length] - 1)];
	
	
	if ([url isFileURL] && [[url path] hasPrefix:baseReqPrefix]) { //test if it's a local request and if it is inside www sandbox
		//NSLog(@"local request");
		
		//test first if it is a named anchor
		/*if ([url fragment] != nil && [[url path] isEqual:baseReqPrefix])
		{
			[pool release];
			return NO;
		}*/
		//if it is, test if file exists
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDir] && !isDir)
		{
			//if it exists, return yes
			//NSLog(@"local request exists");
			[pool release];
			return YES;
		} else {
			if (ngap_context.skip)
			{
				//NSLog(@"Skipping");
				ngap_context.skip = false;
				[pool release];
				return YES;
			}
				
			
			//if it doesn't exist, call our hxcpp handler
			//NSLog(@"file doesn't exist");
			ngap_request req = new_ngap_request(request, baseRequest);
			ngap_request last_request = ngap_context;
			ngap_context = req;
			//call hxcpp handler
			
			if (!ngap_main_callback || !ngap_main_callback->get())
			{
				NSLog(@"No request handler defined!");
				//TODO show error page
				val_throw(alloc_string("No request handler defined!"));
			}
			
			val_call0(ngap_main_callback->get());
			
			value buffer_str = buffer_to_string((buffer)ngap_context.print_contents->get());
			
			const char * mime = ngap_context.mime;
			const char * encoding = ngap_context.encoding;
			
			if (!mime)
			{
				mime = "text/html";
			}
			
			if (!encoding)
			{
				encoding = "utf-8";
			}
			
			//render content to screen
			if (!ngap_context.to_redirect)
			{
				//NSLog(@"buffer contents: %s", val_string(buffer_str));
				ngap_context.skip = true;
				last_request.skip = true;
				
				[webview loadData:[NSData dataWithBytes:val_string(buffer_str) length:val_strlen(buffer_str)] MIMEType:[NSString stringWithUTF8String:mime] textEncodingName:[NSString stringWithUTF8String:encoding] baseURL:[NSURL fileURLWithPath: baseReq]];
			} else {
				char *to_redir = ngap_context.to_redirect;
				
				char *to_redir_s = to_redir;
				//NSLog(@"redirecting... %s", to_redir_s);
				if ('/' == (*to_redir))
				{
					to_redir_s++;
				}
				ngap_context.to_redirect = NULL; //avoid infinite loop

				[self loadWithPath:[NSString stringWithUTF8String:to_redir_s]];
				free(to_redir);
			}
			
			//release all ngap_request info
			
			if (ngap_context.mime)
			{
				free(ngap_context.mime);
			}
			
			if (ngap_context.encoding)
			{
				free(ngap_context.encoding);
			}
			
			delete ngap_context.print_contents;
			
			//set back the last request in stack
			ngap_context = last_request;
			
			[pool release];
			return NO;
		}
	} else if ([url.scheme isEqual:@"cxlog"]) {
		//handle logging
		NSString *requestString = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		NSString* logString = [[requestString componentsSeparatedByString:@":#-1#"] objectAtIndex:1];
		NSLog(@"[UIWebView console] %@", logString);
		
		[pool release];
		return NO;
	} else if ([url.scheme isEqual:@"cxconnect"]) {
		//handle remoting connection
		NSString *requestString = [url absoluteString];
		
		if (ngap_global_event_handler && ngap_global_event_handler->get())
		{
			value arr = alloc_array(1);
			val_array_set_i(arr, 0, alloc_string([requestString UTF8String]));
			
			val_call2(ngap_global_event_handler->get(), alloc_string("cxconnect"), arr);
		}
		
		[pool release];
		return NO;
	}
	
	[pool release];
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//add communication handler
	[webView stringByEvaluatingJavaScriptFromString:@"if (typeof croxit == 'undefined') croxit = new Object();"];
	[webView stringByEvaluatingJavaScriptFromString:@"if (typeof croxit.js == 'undefined') croxit.js = new Object();"];
	[webView stringByEvaluatingJavaScriptFromString:@"if (typeof croxit.js.Client == 'undefined') croxit.js.Client = new Object();"];
	[webView stringByEvaluatingJavaScriptFromString:@"croxit.callbacks = [];"];
	[webView stringByEvaluatingJavaScriptFromString:
	@"croxit.js.Client.send = function(protocol, msg, callback) {"
		"var protocol = protocol.split(':').join('_');"
		"var idx = (callback == null) ? -1 : (croxit.callbacks.push(callback) - 1);"
		"var iframe = document.createElement('IFRAME');"
		"iframe.setAttribute('src', protocol + ':#' + idx + '#' + msg);"
		"document.documentElement.appendChild(iframe);"
		"iframe.parentNode.removeChild(iframe);"
		"iframe = null;"
	"}"];
	[webView stringByEvaluatingJavaScriptFromString:
	@"croxit.js.Client.doCall = function(idx, val) {"
		"var cback = croxit.callbacks[idx];"
		"if (cback == null) { console.error('ERROR: No callback found at index ' + idx); return; }"
		"delete croxit.callbacks[idx];"
		"cback(val);"
	"}"];
	
	//croxit.js.Client.baseDir
	NSString *script = @"croxit.js.Client.baseDir = '";
	script = [script stringByAppendingString:baseRequest];
	script = [script stringByAppendingString:@"';"];
	[webView stringByEvaluatingJavaScriptFromString:script];
	
	//croxit.js.Client.writableDir
	script = @"croxit.js.Client.writableDir = '";
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	success = [fileManager fileExistsAtPath:documentsDirectory];
	
	if (success) 
	{
		script = [script stringByAppendingString:documentsDirectory];
		script = [script stringByAppendingString:@"/';"];
		[webView stringByEvaluatingJavaScriptFromString:script];
	}
	
	//add console.log() handler
	[webView stringByEvaluatingJavaScriptFromString:@"if (typeof console == 'undefined') console = new Object();"];
	[webView stringByEvaluatingJavaScriptFromString:
	@"console.log = function(log) {"
		"croxit.js.Client.send('cxlog', log);"
	"}"];
	[webView stringByEvaluatingJavaScriptFromString:
	@"console.error = function(log) {"
		"croxit.js.Client.send('cxlog', 'ERROR: ' + log);"
	"}"];
	[webView stringByEvaluatingJavaScriptFromString:@"console.warn = function(log) { croxit.js.Client.send('cxlog', 'WARNING: ' + log); }"];
	[webView stringByEvaluatingJavaScriptFromString:@"console.debug = console.log;"];
	[webView stringByEvaluatingJavaScriptFromString:@"console.info = console.log;"];
	
	//call deviceready
	
	//calling dispatchEvent for compatibility with PhoneGap
	[webView stringByEvaluatingJavaScriptFromString:@"var evt = document.createEvent('Event');"];
	[webView stringByEvaluatingJavaScriptFromString:@"evt.initEvent('deviceready', true, true);"];
	[webView stringByEvaluatingJavaScriptFromString:@"document.dispatchEvent(evt);"];
	
	if (ngap_global_event_handler && ngap_global_event_handler->get())
		val_call2(ngap_global_event_handler->get(), alloc_string("web_finish_load"), val_null);
	
	[pool release];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if (ngap_global_event_handler && ngap_global_event_handler->get())
		val_call2(ngap_global_event_handler->get(), alloc_string("web_start_load"), val_null);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (!ngap_autorotate_callback || !ngap_autorotate_callback->get())
	{
		return YES;
	} else {
		value ret = val_call1(ngap_autorotate_callback->get(), alloc_int((int)interfaceOrientation));
		val_check(ret, bool);
		bool ret_b = val_bool(ret);
		if (ret_b)
		{
			return YES;
		} else {
			return NO;
		}
	}
    // Return YES for supported orientations
    return YES;
}

@end


@implementation WebviewAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIWindow *win = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window = win;

	[_window makeKeyAndVisible];
	
	if (ngap_global_event_handler && ngap_global_event_handler->get())
	{
		val_call2(ngap_global_event_handler->get(), alloc_string("application_did_finish_loading"), val_null);
	}
		
	if (should_load_web_view)
	{
		// Override point for customization after application launch.
		WebViewController *c = [[WebViewController alloc] init];
		win.rootViewController = c;
		web_view_controller = c;
		//[c setWebview:[[UIWebView alloc] initWithFrame:[_window frame]]];

		[_window addSubview:[c view]];

		[c setBaseRequest: [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"] stringByAppendingString:@"/"]];
		if (ngap_context.to_redirect)
		{
			char *to_redir = ngap_context.to_redirect;
			ngap_context.to_redirect = NULL; //avoid infinite loop

			[c loadWithPath:[NSString stringWithUTF8String:to_redir]];
			free(to_redir);
		} else {
			[c loadHome];
		}
	}



	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */

	if (ngap_global_event_handler && ngap_global_event_handler->get())
		val_call2(ngap_global_event_handler->get(), alloc_string("application_will_resign_active"), val_null);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
	if (ngap_global_event_handler && ngap_global_event_handler->get())
		val_call2(ngap_global_event_handler->get(), alloc_string("application_did_enter_background"), val_null);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
		if (ngap_global_event_handler && ngap_global_event_handler->get())
			val_call2(ngap_global_event_handler->get(), alloc_string("application_will_enter_foreground"), val_null);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
		if (ngap_global_event_handler && ngap_global_event_handler->get())
			val_call2(ngap_global_event_handler->get(), alloc_string("application_did_become_active"), val_null);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
	if (ngap_global_event_handler && ngap_global_event_handler->get())
		val_call2(ngap_global_event_handler->get(), alloc_string("application_will_terminate"), val_null);
}
/*
- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *) sourceApplication annotation:(id)annotation
{
	if (ngap_global_event_handler && ngap_global_event_handler->get())
	{
		value arr = alloc_array(2);
		val_array_set_i(arr,0,alloc_string([[url absoluteString] UTF8String]));
		val_array_set_i(arr,1,alloc_string([sourceApplication UTF8String]));
		val_call2(ngap_global_event_handler->get(), alloc_string("application_open_url"), arr);
	}
}*/

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end

extern "C" {
	
	value ngap_hide()
	{
		if (web_view_controller)
			[web_view_controller view].hidden = NO;
		else
			return val_false;
		
		return val_true;
	}
	
	DEFINE_PRIM(ngap_hide, 0);
	
	value ngap_show()
	{
		if (web_view_controller)
			[web_view_controller view].hidden = NO;
		else
			return val_false;
		
		return val_true;
	}
	
	DEFINE_PRIM(ngap_show, 0);
	
	value ngap_cache_module(value cback)
	{
		val_check_function(cback, 0);
		if (ngap_main_callback)
		{
			delete ngap_main_callback;
			ngap_main_callback = NULL;
		}
		
		ngap_main_callback = new AutoGCRoot(cback);
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_cache_module, 1);
	
	value ngap_start(value home, value reqHandler)
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		ngap_cache_module(reqHandler);
		if (!web_view_controller)
		{
			WebViewController *c = [[WebViewController alloc] init];
			web_view_controller = c;
			//get current app delegate
			//id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
			[c setBaseRequest: [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"] stringByAppendingString:@"/"]];
			[[[UIApplication sharedApplication] keyWindow] addSubview:[c view]];
		}
		
		if (val_is_null(home))
		{
			[web_view_controller loadHome];
		} else {
			val_check(home, string);
			NSString *ns_home = [[NSString alloc] stringWithUTF8String:val_string(home)];
			
			[web_view_controller loadWithPath:ns_home];
		}
		
		[pool release];
		return val_null;
	}
	
	DEFINE_PRIM(ngap_start, 2);
	
	value ngap_init_and_start(value home, value reqHandler)
	{
		ngap_cache_module(reqHandler);
		if (!val_is_null(home))
		{
			ngap_context.to_redirect = value_string_copy(home);
			NSLog(@"redirecting to %s", ngap_context.to_redirect);
		}
		int argc = 0;// *_NSGetArgc();
		char **argv = 0;// *_NSGetArgv();
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		should_load_web_view = true;
		int retVal = UIApplicationMain(argc, argv, nil, @"WebviewAppDelegate");
		[pool release];
		
		return alloc_int(retVal);
	}
	
	DEFINE_PRIM(ngap_init_and_start, 2);
	
	value ngap_init()
	{
		int argc = 0;// *_NSGetArgc();
		char **argv = 0;// *_NSGetArgv();
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		should_load_web_view = false;
		int retVal = UIApplicationMain(argc, argv, nil, @"WebviewAppDelegate");
		[pool release];
		
		return alloc_int(retVal);
	}
	
	DEFINE_PRIM(ngap_init, 0);
	
	value ngap_stop()
	{
		if (web_view_controller)
		{
			[web_view_controller view].hidden = YES;
			[[web_view_controller view] removeFromSuperview];
			/*
			
			UIView *v = [self.containerView viewWithTag:[n integerValue]];
			v.hidden = YES;
			[self.containerView bringSubviewToFront:v];
			[v removeFromSuperview];
			Another thing I just noticed from the UIView class document - see the last sentence:

			removeFromSuperview Unlinks the receiver from its superview and its window, and removes it from the responder chain.

			(void)removeFromSuperview
			Discussion If the receiver’s superview is not nil, this method releases the receiver. If you plan to reuse the view, be sure to retain it before calling this method and be sure to release it as appropriate when you are done with it or after adding it to another view hierarchy.

			Never invoke this method while displaying.
			
			*/
		}
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_stop, 0);

	value ngap_set_should_autorotate(value cback)
	{
		val_check_function(cback,1);
		
		if (ngap_autorotate_callback && !val_is_null(cback))
		{
			delete ngap_autorotate_callback;
			ngap_autorotate_callback = NULL;
		}
		
		ngap_autorotate_callback = new AutoGCRoot(cback);
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_should_autorotate, 1);
	
	value ngap_set_global_event_handler(value handler)
	{
		val_check_function(handler, 2);
		
		if (ngap_global_event_handler && !val_is_null(ngap_global_event_handler->get()))
		{
			delete ngap_global_event_handler;
			ngap_global_event_handler = NULL;
		}
		
		ngap_global_event_handler = new AutoGCRoot(handler);
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_global_event_handler, 1);
	
	value ngap_set_activate_event_handler(value handler)
	{
		val_check_function(handler, 3);
		
		if (ngap_activate_event_handler && !val_is_null(ngap_activate_event_handler->get()))
		{
			delete ngap_activate_event_handler;
			ngap_activate_event_handler = NULL;
		}
		
		ngap_activate_event_handler = new AutoGCRoot(handler);
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_activate_event_handler, 1);
	
	value ngap_set_error_handler(value cback)
	{
		val_check_function(cback, 1);
		if (ngap_error_callback && !val_is_null(cback))
		{
			delete ngap_error_callback;
			ngap_error_callback = NULL;
		}
		
		ngap_error_callback = new AutoGCRoot(cback);
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_error_handler, 1);
	
	value ngap_method()
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		value ret = alloc_string([[ngap_context.requestObject HTTPMethod] UTF8String]);
		[pool release];
		return ret;
	}
	
	DEFINE_PRIM(ngap_method, 0);
	
	value ngap_get_params()
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		NSString *params = [[ngap_context.requestObject URL] query];
		value ret;
		if ([params length] == 0)
			ret = alloc_string("");
		else
			ret = alloc_string([params UTF8String]);
		
		[pool release];
		return ret;
	}
	
	DEFINE_PRIM(ngap_get_params, 0);
	
	value ngap_post_params()
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		NSData *data = [ngap_context.requestObject HTTPBody];
		NSUInteger size = [data length] / sizeof(unsigned char);
		char* array = (char*) [data bytes];
		
		value ret = alloc_string_len(array, size);
		[pool release];
		return ret;
	}
	
	DEFINE_PRIM(ngap_post_params, 0);
	
	value ngap_uri()
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		NSString *baseReq = ngap_context.baseRequest;
		baseReq = [baseReq substringToIndex:([baseReq length] - 1)];
		
		value ret = alloc_string([ [[[ngap_context.requestObject URL] path] stringByReplacingOccurrencesOfString:baseReq withString:@""] UTF8String ]);
		[pool release];
		
		return ret;
	}
	
	DEFINE_PRIM(ngap_uri, 0);
	
	value ngap_redirect(value to)
	{
		val_check(to, string);
		ngap_context.to_redirect = value_string_copy(to);
		NSLog(@"redirecting to %s", ngap_context.to_redirect);
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_redirect, 1);
	
	value ngap_set_allow_external(value val)
	{
		ngap_allow_external = val_bool(val);
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_allow_external, 1);
	
	value ngap_print(value content)
	{
		val_buffer((buffer)ngap_context.print_contents->get(), content);
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_print, 1);
	
	value ngap_set_mime(value mime)
	{
		val_check(mime, string);
		ngap_context.mime = value_string_copy(mime);
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_mime, 1);
	
	value ngap_set_encoding(value enc)
	{
		val_check(enc, string);
		ngap_context.encoding = value_string_copy(enc);
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_encoding, 1);
	
	value ngap_get_cwd()
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		value ret = alloc_string([ [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"] stringByAppendingString:@"/"] UTF8String]);
		[pool release];
		
		return ret;
	}
	
	DEFINE_PRIM(ngap_get_cwd, 0);
	
	value ngap_get_writable_path_or_copy(value rel_path, value info)
	{
		val_check(rel_path, string);
		val_check(info, int);
		
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSString *rpath = [NSString stringWithUTF8String:val_string(rel_path) ];
		
		BOOL success;

		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		NSArray *paths = NULL;
		switch(val_int(info))
		{
			case 0:
			{
				paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				break;
			}
			case 1:
			{
				paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
				break;
			}
			case 2:
			{
				paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
				NSString *cachePath = [paths objectAtIndex:0];
				BOOL isDir = NO;
				NSError *error;
				if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) 
				{
					[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
				}
				break;
			}
			default: 
			{
				[pool release];
				neko_error();
			}
		}
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:rpath];
		success = [fileManager fileExistsAtPath:writableDBPath];
		
		if (success) 
		{
			[pool release];
			return alloc_string([writableDBPath UTF8String]);
		};
		NSString *defaultDBPath = [ngap_context.baseRequest stringByAppendingPathComponent:rpath];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) 
		{
			val_throw(alloc_string([[error localizedDescription] UTF8String]));
		}
	
		value ret = alloc_string([writableDBPath UTF8String]);
		[pool release];
		
		return ret;
	}
	
	DEFINE_PRIM(ngap_get_writable_path_or_copy, 2);
	
	value ngap_get_writable_path(value info)
	{
		val_check(info, int);
		
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NULL;
		switch(val_int(info))
		{
			case 0:
			{
				paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				break;
			}
			case 1:
			{
				paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
				break;
			}
			case 2:
			{
				paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
				NSString *cachePath = [paths objectAtIndex:0];
				BOOL isDir = NO;
				NSError *error;
				if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) 
				{
					[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
				}
				break;
			}
			default: 
			{
				[pool release];
				neko_error();
			}
		}
		NSString *documentsDirectory = [paths objectAtIndex:0];
		
		value ret;
		ret = alloc_string([documentsDirectory UTF8String]);
		
		[pool release];
		return ret;
	}
	
	DEFINE_PRIM(ngap_get_writable_path, 1);
	
	value ngap_allow_zoom(value b)
	{
		val_check(b, bool);
		
		if (val_bool(b))
		{
			web_view_controller.webview.scalesPageToFit = YES;
		} else {
			web_view_controller.webview.scalesPageToFit = NO;
		}
		
		return b;
	}
	
	DEFINE_PRIM(ngap_allow_zoom, 1);
	
	value ngap_inline_media_playback(value b)
	{
		val_check(b, bool);
		
		if (val_bool(b))
		{
			web_view_controller.webview.allowsInlineMediaPlayback = YES;
			web_view_controller.webview.mediaPlaybackRequiresUserAction = NO;
		} else {
			web_view_controller.webview.allowsInlineMediaPlayback = NO;
			web_view_controller.webview.mediaPlaybackRequiresUserAction = YES;
		}
		
		return b;
	}
	
	DEFINE_PRIM(ngap_inline_media_playback, 1);
	
	value ngap_call_js(value s)
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		val_check(s, string);
		
		NSString *js = [NSString stringWithUTF8String:val_string(s) ];
		NSString *resp = nil;
		if (![NSThread isMainThread]) {
			NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:1];
			[arr insertObject:js atIndex:0];
			[web_view_controller performSelectorOnMainThread:@selector(callJS:) withObject:arr waitUntilDone:YES];
			resp = [arr objectAtIndex:0];
			[arr release];
		} else {
			resp = [web_view_controller.webview stringByEvaluatingJavaScriptFromString:js];
		}
		
		if (resp == nil)
		{
			[pool release];
			return alloc_null();
		}
		
		value ret = alloc_string([resp UTF8String]);
		[pool release];
		
		return ret;
	}
	
	DEFINE_PRIM(ngap_call_js, 1);
	
	value ngap_set_bounces(value boolv)
	{
		val_check(boolv, bool);
		BOOL v = val_bool(boolv);
		
		for (id subview in web_view_controller.webview.subviews)
		  if ([[subview class] isSubclassOfClass: [UIScrollView class]])
		    ((UIScrollView *)subview).bounces = v;
		
		if ([web_view_controller.webview respondsToSelector:@selector(scrollView)])
		{
			((UIScrollView *) [web_view_controller.webview scrollView]).bounces = v;
		}
		
		return val_null;
	}
	
	DEFINE_PRIM(ngap_set_bounces, 1);
	
	//void ngap_cache_module
};

extern "C" 
{
	
	
	int croxit_register_prims() { return 0; }
	
}
