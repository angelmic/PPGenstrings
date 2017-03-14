# PPGenstrings

It is a genstrings alternative solution. 

#### NSLocalizedString  Example:
	NSLocalizedString(@"xxx4.durationWithDayHourMinute", @"剩餘時間: %d 天 %02d 時 %02d 分")
	NSLocalizedString(@"xxx4.durationWithZeroMinute", @"剩餘時間: 少於 01 分鐘")
	NSLocalizedString(@"xxx1H.numberOfStocks", @"商品細節: 庫存數量：%@")
	NSLocalizedString(@"xxx4L.TimeRatingDueForBuyer", @"訂單列表: 請於 %@ 前給評賣家")
	NSLocalizedString(@"Alert.Confirm", @"確定")
	
#### Usage:
	./PPGenstrings yourSourceFolder ~/Desktop/ok.strings
	
#### in ok.strings you will see:
	/* 剩餘時間: %d 天 %02d 時 %02d 分 */
	"xxx4.durationWithDayHourMinute" = "%d 天 %02d 時 %02d 分";
	
	/* 剩餘時間: 少於 01 分鐘 */
	"xxx4.durationWithZeroMinute" = "少於 01 分鐘";
	
	/* 商品細節: 庫存數量：%@ */
	"xxx1H.numberOfStocks" = "庫存數量：%@";
	
	/* 訂單列表: 請於 %@ 前給評賣家 */
	"xxx4L.TimeRatingDueForBuyer" = "請於 %@ 前給評賣家";
	
	/* 確定 */
	"Alert.Confirm" = "確定";

