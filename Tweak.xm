#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

@interface WASharedAppData : NSObject
{
}


+ (void)endIgnoringInteractionEventsInExtension;
+ (void)beginIgnoringInteractionEventsInExtension;
+ (void)endIgnoringInteractionEvents;
+ (void)beginIgnoringInteractionEvents;
@end

@interface ChatManager : NSObject
+ (id)sharedManager;
- (void)endWebClientSessionWithCompletionHandler:(id)arg1;
- (void)beginWebClientSessionWithQRCode:(id)arg1 completion:(id)arg2;
- (BOOL)hasSavedWebClientSession;
- (BOOL)isWebClientConnected;
- (BOOL)isWebClientAvailable;
- (id)allSavedWebClientSessions;
- (BOOL)isWebClientSupported;
@end

@interface WASettingsViewController : UITableViewController
- (void)showWebClientSettings;
@end

@interface WAWebClientSettingsViewController : UITableViewController
- (void)qrCodeScannerViewControllerDidCancel:(id)arg1;
- (void)reallyBeginWebClientSessionWithQRCode:(id)arg1;
- (void)qrCodeScannerViewController:(id)arg1 didFinishWithCode:(id)arg2;
- (BOOL)qrCodeScannerViewController:(id)arg1 shouldAcceptCode:(id)arg2;
- (void)scanQRCode;
- (void)endWebClientSessionWithCompletionHandler:(id)arg1;
- (void)signOut;
- (void)setupTableView;
- (id)initWithStyle:(int)arg1;
@end

@interface WAWebClient : NSObject
+ (BOOL)isQRCodeWellFormed:(id)arg1;
+ (void)showSignInErrorMessage;
+ (void)showNoConnectionErrorMessage;
+ (BOOL)isSupported;
@property(nonatomic) unsigned int sessionState; // @synthesize sessionState=_sessionState;
- (void)batteryLevelOrStateDidChange:(id)arg1;
- (id)hashWithSharedSecret:(id)arg1;
- (void)handleChallengeResponse:(id)arg1;
- (void)sendChallengeToServerWithWebReference:(id)arg1;
- (void)acceptServerResume;
- (void)rejectServerLoginWithWebRef:(id)arg1 reason:(unsigned int)arg2;
- (void)acceptServerLoginWithWebRef:(id)arg1 clientToken:(id)arg2 browserID:(id)arg3;
- (void)reportMediaResponseCode:(unsigned int)arg1 mediaURL:(id)arg2 forRequestID:(id)arg3;
- (void)notifyAddedContacts:(id)arg1 removedJIDs:(id)arg2 removeMissingJIDs:(BOOL)arg3;
- (void)endSessionWithCompletionHandler:(id)arg1;
- (void)beginSessionWithQRCode:(id)arg1 completion:(id)arg2;
- (void)terminateAllSessionsWithCompletionHandler:(id)arg1;
- (void)beginNewSessionWithQRCode:(id)arg1 completion:(id)arg2;
@end


%hook WAServerProperties
+ (BOOL)isWebClientEnabled {
		return YES;
}
%end

%hook WAWebClient
+ (BOOL)isSupported {
		return YES;
}
- (_Bool)available {
	return YES;
}
- (_Bool)isAvailable {
	return YES;
}
%end

%hook UIApplication
- (void)wa_showLocalNotificationForJailbrokenPhoneAndTerminate {
	return;
}
%end

%hook WAWebClientSettingsViewController
- (void)viewDidAppear:(BOOL)arg1 {
	// i'm writing it manually :P ( i don't like WhatsApp impelemntaion )
	ChatManager *chatManger = [objc_getClass("ChatManager") sharedManager];
	NSArray *chSession = [chatManger allSavedWebClientSessions];
	if ([chSession count] == 0) {

	}
}
- (void)qrCodeScannerViewController:(id)arg1 didFinishWithCode:(id)arg2 {
		[%c(WASharedAppData) beginIgnoringInteractionEvents];
		ChatManager *chatManger = [objc_getClass("ChatManager") sharedManager];
		WAWebClient *webClient = MSHookIvar<WAWebClient *>(chatManger, "_webClient");
		[webClient beginNewSessionWithQRCode:arg2 completion:^{
			[%c(WASharedAppData) endIgnoringInteractionEvents];
			[self.navigationController popToViewController:self animated:0x1];
		}];
}
- (void)reallyBeginWebClientSessionWithQRCode:(id)arg1 {
		%orig;
		[%c(WASharedAppData) endIgnoringInteractionEvents];
}
%end

%hook WASettingsViewController
- (void)qrCodeScannerViewController:(id)arg1 didFinishWithCode:(id)arg2 {
	// i'm writing it manually :P ( i don't like WhatsApp impelemntaion )
		[%c(WASharedAppData) beginIgnoringInteractionEvents];
		ChatManager *chatManger = [objc_getClass("ChatManager") sharedManager];
		WAWebClient *webClient = MSHookIvar<WAWebClient *>(chatManger, "_webClient");
		[webClient beginNewSessionWithQRCode:arg2 completion:^{
			[%c(WASharedAppData) endIgnoringInteractionEvents];
			[self.navigationController popToViewController:self animated:0x1];
		}];
}
- (BOOL)qrCodeScannerViewController:(id)arg1 shouldAcceptCode:(id)arg2 {
    return %orig;
}
- (void)setupTableView {
	UIBarButtonItem *qrBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/WhatsAppWebEnabler/qrIcon@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showWebClientSettings)];
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(24, 24), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[qrBarButton setBackgroundImage:blank forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:qrBarButton, nil]];
}
%end
