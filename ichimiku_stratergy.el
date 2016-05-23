{ Helpful instructions on the use of EasyLanguage, such as this, appear below and are 
  contained within French curly braces {}.  There is no need to erase these 
  instructions when using EasyLanguage in order for it to function properly, because 
  this text will be ignored. }

{ STEP 1 OF 2: Replace <CRITERIA> with the criteria that will cause a Buy limit order 
  to be placed on the next bar. }

inputs:
	int Tenkan_Sen_Length( 18 ), { number of bars to be used in the calculation of
	 the Tenkan line }
	int Kinjun_Sen_Length( 52), { number of bars to be used in the calculation of
	 the Kinjun line } 
	int Senkou_Span_B_Length( 104), { number of bars to be used in the calculation
	 of Senkou_Span_B }
	int Senkou_Span_Offset( 52), { number of bars to the right of the last price
	 bar to plot the current Senkou_Span_A and Senkou_Span_B values, counting the 
	 current bar }
	int Chikou_Offset( 52) { number of bars back to offset the plot of the Chikou forward} ;

{ STEP 2 OF 2: Replace "Entry Name" (leaving the quotes) with a short name for the 
  entry and replace <PRICE> with the desired limit order price level.  The entry name 
  will appear on the chart above/below the trade arrows and in the trade by trade 
  performance report. }

variables:
	double Tenkan_Sen( 0 ),
	double Kinjun_Sen( 0 ),
	double Senkou_Span_A( 0 ),
	double Senkou_Span_B( 0 ) ;

Tenkan_Sen = 0.5 * ( Highest( High, Tenkan_Sen_Length ) + Lowest( Low,
 Tenkan_Sen_Length ) ) ;

Kinjun_Sen = 0.5 * ( Highest( High, Kinjun_Sen_Length ) + Lowest( Low,
 Kinjun_Sen_Length ) ) ;

Senkou_Span_A = 0.5 * ( Tenkan_Sen + Kinjun_Sen ) ;

Senkou_Span_B = 0.5 * ( Highest( High, Senkou_Span_B_Length ) + Lowest( Low,
 Senkou_Span_B_Length ) ) ;

if Tenkan_Sen crosses above Kinjun_Sen and Close > Tenkan_Sen and MarketPosition = 0 then
{ CB > 1 check used to avoid spurious cross confirmation at CB = 1 }
	begin
	Buy ( "BHigherR_Buy" ) next bar at Market ;
	end
else if Close > Tenkan_Sen + 6 then
	begin
	Sell ( "BHigherR_Profit" ) this bar ;
	end
else if close <= Kinjun_Sen - 1 then
	Sell ( "BHigherR_Stop" ) this bar ;

if Tenkan_Sen crosses below Kinjun_Sen and Close < Tenkan_Sen and MarketPosition = 0 then
{ CB > 1 check used to avoid spurious cross confirmation at CB = 1 }
	begin
	SellShort ( "BLowerR_Sell" ) next bar at Market ;
	end
else if Close < Tenkan_Sen - 6 then
	begin
	BuyToCover( "BLowerR_Profit" ) this bar ;
	end
else if close >= Kinjun_Sen + 1 then
	Sell ( "BLowerR_Stop" ) this bar ;
