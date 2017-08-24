require(quantmod)
require(IKTrading)
require(Quandl)

args<-commandArgs(TRUE)

"ichimoku" <- function(hlcDaily, nFast=9, nMed=26, nSlow=52) {
  HLC <- to.weekly(hlcDaily)
  
  if (nrow(HLC) >= nSlow){
  
  turningLine <- (runMax(Hi(HLC), nFast)+runMin(Lo(HLC), nFast))/2
  baseLine <- (runMax(Hi(HLC), nMed)+runMin(Lo(HLC), nMed))/2
  spanA <- lag((turningLine+baseLine)/2, nMed)
  spanB <- lag((runMax(Hi(HLC), nSlow)+runMin(Lo(HLC), nSlow))/2, nMed)
  # plotSpan <- lag(Cl(HLC), -nMed) #for plotting the original Ichimoku only
  laggingSpan <- lag(Cl(HLC), nMed)
  close <- HLC[,4]
  out <- cbind(close=close, turnLine=turningLine, baseLine=baseLine, spanA=spanA, spanB=spanB)
  colnames(out) <- c("close","turnLine", "baseLine", "spanA", "spanB")
  return (out)
  }
}

"anyGood" <- function(ic, quote, name) {
  
    limit = 4.0
    close = tail(ic, n=1)[,1]
    line1 = tail(ic, n=1)[,2]
    line2 = tail(ic, n=1)[,3]
    spanA = tail(ic, n=1)[,4]
    spanB = tail(ic, n=1)[,5]
    
    if(!is.null(spanB) && is.numeric(spanB)){
    
      lowerBand = if (spanA < spanB) spanA else spanB
      higherBand = if (spanB >= spanA) spanB else spanA
    
      if (abs(close-higherBand)*100/close <= limit) {
        cat(paste(quote,name,"close within" , limit, "percent of higherBand", sep=" "))
        cat("\n")
      }
    }
}

start_date=Sys.Date() - 1150
input = read.csv('india_stock_list.csv', strip.white = TRUE, sep = ",", header = FALSE, stringsAsFactors=FALSE )

#output file
sink("india_stock_list_outfile.txt")
for(i in 1:nrow(input))
{
  quote = input[i,1]
  name = input[i,2]
  tryCatch({
    data=Quandl(quote, api_key="7BS7k1_dnKCP3h2FefxA", trim_start=start_date, type = "xts", frequency= "daily")
    if (mean(tail(data,n=7)[,6]) > 10000){
      if ( length(grep("CHRIS",quote))>0){
        x=as.quantmod.OHLC(data[,1:4],col.names = c("Open", "High","Low", "Close"))
        ic = ichimoku(xts(x[,1:4]),18,52,104)
      } else{
        ic = ichimoku(data[,1:4],18,52,104)
      }
      anyGood(ic,quote,name)
    }
        },error = function(err) {
  })
}

sink()
