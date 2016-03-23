require(quantmod)
require(IKTrading)
require(Quandl)

args<-commandArgs(TRUE)

"ichimoku" <- function(HLC, nFast=9, nMed=26, nSlow=52) {
  turningLine <- (runMax(Hi(HLC), nFast)+runMin(Lo(HLC), nFast))/2
  baseLine <- (runMax(Hi(HLC), nMed)+runMin(Lo(HLC), nMed))/2
  spanA <- lag((turningLine+baseLine)/2, nMed)
  spanB <- lag((runMax(Hi(HLC), nSlow)+runMin(Lo(HLC), nSlow))/2, nMed)
  plotSpan <- lag(Cl(HLC), -nMed) #for plotting the original Ichimoku only
  laggingSpan <- lag(Cl(HLC), nMed)
  close <- HLC[,4]
  out <- cbind(close=close, turnLine=turningLine, baseLine=baseLine, spanA=spanA, spanB=spanB)
  colnames(out) <- c("close","turnLine", "baseLine", "spanA", "spanB")
  return (out)
}

"anyGood" <- function(ic, quote, name, imp) {
  
  limit = 1.0
  if (imp == 1){
    limit = 3.0
  }
  
  close = tail(ic, n=1)[,1]
  line1 = tail(ic, n=1)[,2]
  line2 = tail(ic, n=1)[,3]
  spanA = tail(ic, n=1)[,4]
  spanB = tail(ic, n=1)[,5]
  
  lowerBand = if (spanA < spanB) spanA else spanB
  higherBand = if (spanB >= spanA) spanB else spanA
  
 if (abs(spanA-spanB)*100/spanA > limit) {
    vec = sort(as.vector(c(spanA,line1,line2, close)))
    if (abs(vec[4]-vec[1])*100/vec[1] <= limit ){
      cat(paste(quote,name,"spanA and moving averages within", limit, "percent.", sep=" "))
      cat("\n")
    }
  } 
  if (abs(close-lowerBand)*100/close <= limit) {
    cat(paste(quote,name,"close within" , limit, "percent of lowerBand", sep=" "))
    cat("\n")
  }
  else if (abs(close-higherBand)*100/close <= limit) {
    cat(paste(quote,name,"close within" , limit, "percent of higherBand", sep=" "))
    cat("\n")
  }
}

start_date=Sys.Date() - 365
input = read.csv('input.txt', strip.white = TRUE, sep = ",", header = FALSE, stringsAsFactors=FALSE )

#output file
sink("outfile.txt")
for(i in 1:nrow(input))
{
  importance = input[i,1]
  quote = input[i,2]
  name = input[i,3]
  tryCatch({
  data=Quandl(quote, api_key="7BS7k1_dnKCP3h2FefxA", trim_start=start_date, type = "xts")
  if ( length(grep("CHRIS",quote))>0){
    x=as.quantmod.OHLC(data[,1:4],col.names = c("Open", "High","Low", "Close"))
    ic = ichimoku(xts(x[,1:4]),18,52,104)
  } else{
  ic = ichimoku(data[,1:4],18,52,104)
  }
  anyGood(ic,quote,name, importance)},error = function(err) {
  })
}

sink()