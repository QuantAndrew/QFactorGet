#' get factor functions
#' @name getfactor
#' @rdname getfactor
#' @param TS a \bold{TS} object
#' @return a \bold{TSF} object
NULL



# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
# =============   get factors through local data base    ===============
# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
#' @rdname getfactor
#' @export
gf.mkt_cap <- function(TS){
  re <- getTech(TS,variables="mkt_cap")
  re <- renameCol(re,"mkt_cap","factorscore")
  return(re)
}
#' @rdname getfactor
#' @export
gf.float_cap <- function(TS){
  re <- getTech(TS,variables="float_cap")
  re <- renameCol(re,"float_cap","factorscore")
  return(re)
}
#' @rdname getfactor
#' @export
gf.ln_mkt_cap <- function(TS){
  re <- gf.mkt_cap(TS)
  re$factorscore <- ifelse(re$factorscore<0.001,NA,log(re$factorscore))
  return(re)
}

#' @rdname getfactor
#' @export
gf.ln_float_cap <- function(TS){
  re <- gf.float_cap(TS)
  re$factorscore <- ifelse(re$factorscore<0.001,NA,log(re$factorscore))
  return(re)
}

#' @rdname getfactor
#' @export
#' @param is1q logic. if TRUE(the default), return the single quarter data, else a cummuliated data.
gf.NP_YOY <- function(TS,is1q=TRUE,filt=10000000,rm_neg=FALSE,src=c("all","fin"),clear_result=TRUE){
  src <- match.arg(src)
  if(src=="fin") {
    src_filt <- "src='fin'"
  } else {
    src_filt <- "1>0"
  }
  check.TS(TS)
  PeriodMark <- ifelse(is1q,2,3)
  TS$date <- rdate2int(TS$date)
  qr <- paste(
    "select b.date, b.stockID, InfoPublDate,EndDate,NP_YOY as 'factorscore', src, NP_LYCP
    from LC_PerformanceGrowth a, yrf_tmp b
    where a.id=(
    select id from LC_PerformanceGrowth
    where stockID=b.stockID and InfoPublDate<=b.date and",src_filt," 
    and PeriodMark=",PeriodMark,"
    order by InfoPublDate desc, EndDate DESC
    limit 1);
    "
  )
  con <- db.local("main")
  dbWriteTable(con,name="yrf_tmp",value=TS[,c("date","stockID")],row.names = FALSE,overwrite = TRUE)
  re <- DBI::dbGetQuery(con,qr)
  DBI::dbDisconnect(con)
  re <- merge.x(TS,re,by=c("date","stockID"))
  re <- transform(re, date=intdate2r(date))

  # -- filtering
  if(rm_neg){
    re[!is.na(re$NP_LYCP) & re$NP_LYCP<filt, "factorscore"] <- NA
  } else{
    re[!is.na(re$NP_LYCP) & abs(re$NP_LYCP)<filt, "factorscore"] <- NA
  }
  
  if(clear_result){# drop cols: InfoPublDate,EndDate, src, NP_LYCP
    return(re[,c(names(TS),"factorscore")])
  } else {
    return(re)
  }
}





# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
# =============   get technical factors through tinysoft ===============
# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============




# -- by getTech_ts
#' @rdname getfactor
#' @export
gf.pct_chg_per <- function(TS,N=60){
  funchar <- paste("StockZf2(",N,")",sep="")
  getTech_ts(TS,funchar,varname="factorscore")
}
#' @rdname getfactor
#' @export
gf.totalshares <- function(TS){
  funchar <- "StockTotalShares3()"
  getTech_ts(TS,funchar,varname="factorscore")
}
#' @rdname getfactor
#' @export
gf.totalmarketvalue <- function(TS){
  funchar <- "StockTotalValue3()"
  getTech_ts(TS,funchar,varname="factorscore")
}

gf.BBIBOLL <- function(TS,p1,p2){
  funchar <- paste('BBIBOLL_v(',p1,',',p2,')',sep='')
  getTech_ts(TS,funchar,varname="factorscore")
}

gf.avgTurnover <- function(TS,N){
  funchar <- paste('StockAveHsl2(',N,')',sep='')
  getTech_ts(TS,funchar,varname="factorscore")
}

gf.avgTurnover_1M3M <- function(TS){
  funchar <- "StockAveHsl2(20)/StockAveHsl2(60)"
  getTech_ts(TS,funchar,varname="factorscore")
}

gf.sumAmount <- function(TS,N){
  funchar <- paste('StockAmountSum2(',N,')',sep='')
  getTech_ts(TS,funchar,varname="factorscore")
}
#' @rdname getfactor
#' @export
gf.floatMarketValue <- function(TS){
  funchar <- "StockMarketValue3()"
  getTech_ts(TS,funchar,varname="factorscore")
}
#' @rdname getfactor
#' @export
gf.PE_lyr <- function(TS,fillna=TRUE){
  funchar <- "StockPE3()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.PE_ttm <- function(TS,fillna=TRUE){
  funchar <- "StockPE3_V()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.ln_PE_ttm <- function(TS){
  re <- gf.PE_ttm(TS)
  re$factorscore <- ifelse(re$factorscore<0.001,NA,log(re$factorscore))
  return(re)
}


#' @rdname getfactor
#' @export
gf.PS_lyr <- function(TS,fillna=TRUE){
  funchar <- "StockPMI3()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.PS_ttm <- function(TS,fillna=TRUE){
  funchar <- "StockPMI3_V()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.PCF_lyr <- function(TS,fillna=TRUE){
  funchar <- "StockPCF3()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.PCF_ttm <- function(TS,fillna=TRUE){
  funchar <- "StockPCF3_V()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.PB_lyr <- function(TS,fillna=TRUE){
  funchar <- "StockPNA3()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.PB_mrq <- function(TS,fillna=TRUE){
  funchar <- "StockPNA3_II()"
  re <- TS.getTech_ts(TS,funchar,varname="factorscore")
  if(fillna){
    re$factorscore <- ifelse(re$factorscore<=0,NA,re$factorscore)
  }
  return(re)
}
#' @rdname getfactor
#' @export
gf.ln_PB_mrq <- function(TS){
  re <- gf.PB_mrq(TS)
  re$factorscore <- ifelse(re$factorscore<0.001,NA,log(re$factorscore))
  return(re)
}


#' @rdname getfactor
#' @export
gf.BP_mrq <- function(TS) {
  TSF <- gf.PB_mrq(TS,fillna = FALSE)
  TSF <- transform(TSF,factorscore=1/factorscore)
  return(TSF)
}


#' @rdname getfactor
#' @export
gf.EP_ttm <- function(TS) {
  TSF <- gf.PE_ttm(TS,fillna = FALSE)
  TSF <- transform(TSF,factorscore=1/factorscore)
  return(TSF)
}
#' @rdname getfactor
#' @export
gf.CFP_ttm <- function(TS){
  TSF <- gf.PCF_ttm(TS,fillna = FALSE)
  TSF <- transform(TSF,factorscore=1/factorscore)
  return(TSF)
}

gf.temp111 <- function (TS,p1,p2) {
  funchar <- paste('BBIBOLL_v(',p1,',',p2,')',sep='')
  TSF <- getTech_ts(TS,funchar,varname="factorscore")
}

# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
# ===================== get financial factors through tinysoft =========
# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============

# -- via getFin_ts -------

gf.tempxxxyyy <- function(TS){
  funchar <- "ReportOfAll(9900416,Rdate)"
  getFin_ts(TS,funchar,varname="factorscore")
}
gf.tempxxxyyyzz <- function(TS){
  funchar <- "StockAveHsl2(20)+reportofall(9900003,Rdate)"
  getFin_ts(TS,funchar,varname="factorscore")
}

gf.G_NP_Q_xx <- function(TS){
  funchar <- "LastQuarterData(Rdate,9900604,0)"
  re <- getFin_ts(TS,funchar,varname="factorscore")  
  return(re)
}





# -- via TS.getFin_by_rptTS -------





#' @export
gf.ROE <- function(TS){
  funchar <-  '"factorscore",reportofall(9900100,Rdate)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  return(re)
}
#' @export
gf.ROE_Q <- function(TS){
  funchar <-  '"factorscore",LastQuarterData(Rdate,9900100,0)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  return(re)
}
#' @export
gf.ROE_ttm <- function(TS){
  funchar <-  '"factorscore",Last12MData(Rdate,9900100)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  return(re)
}

#' ROEKF_Q
#' 
#' @export
gf.ROEKF_Q <- function(TS){
  funchar <-  '"factorscore",LastQuarterData(Rdate,9900101,0)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  return(re)
}

#' PEG
#' 
#' @export
gf.PEG <- function(TS){
  
  TS_core <- TS[,c("date","stockID")]
  mdata1 <- gf.PE_ttm(TS_core)
  mdata1 <- dplyr::rename(mdata1, PE = factorscore)
  mdata2 <- gf.NP_YOY(TS_core, rm_neg = TRUE)
  mdata2 <- dplyr::rename(mdata2, G = factorscore)
  result <- merge.x(mdata1, mdata2, by = c("date","stockID"))
  result$factorscore <- result$G/result$PE
  result$factorscore <- ifelse(is.infinite(result$factorscore),NA,result$factorscore)
  result <- result[,c("date","stockID","factorscore")]
  result <- merge.x(TS, result, by = c("date","stockID"))
  return(result)
}


# -- GrossProfitMargin(MLL)
#' @rdname getfactor
#' @export
gf.G_MLL_Q <- function(TS){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,9900103,0)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  return(re)
}



# -- OCF
#' @rdname getfactor
#' @export
gf.G_OCF_Q <- function(TS, filt=0){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,48018,1),
  "OCF_t0",RefReportValue(@LastQuarterData(DefaultRepID(),48018,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$OCF_t0) & abs(re$OCF_t0)<filt, "factorscore"] <- NA
  return(re)
}
#' @rdname getfactor
#' @export
gf.G_OCF <- function(TS, filt=0){
  funchar <-  '"factorscore",Last12MTBGrowRatio(Rdate,48018,1),
  "OCF_t0",RefReportValue(@Last12MData(DefaultRepID(),48018),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$OCF_t0) & abs(re$OCF_t0)<filt, "factorscore"] <- NA
  return(re)
}


# -- SCF
#' @rdname getfactor
#' @export
gf.G_SCF_Q <- function(TS, filt=0){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,48002,1),
  "SCF_t0",RefReportValue(@LastQuarterData(DefaultRepID(),48002,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$SCF_t0) & abs(re$SCF_t0)<filt, "factorscore"] <- NA
  return(re)
}
#' @rdname getfactor
#' @export
gf.G_SCF <- function(TS, filt=0){
  funchar <-  '"factorscore",last12MTBGrowRatio(Rdate,48002,1),
  "SCF_t0",RefReportValue(@Last12MData(DefaultRepID(),48002),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$SCF_t0) & abs(re$SCF_t0)<filt, "factorscore"] <- NA
  return(re)
}


# -- OCF2OR
#' @rdname getfactor
#' @export
# gf.G_OCF2OR_Q <- function(TS){
#   funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,9900701,0)'
#   re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
#   return(re)
# }



# -- SCF2OR
#' @rdname getfactor
#' @export
# gf.G_SCF2OR_Q <- function(TS){
#   funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,9900700,0)'
#   re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
#   return(re)
# }


# -- ROE
#' @rdname getfactor
#' @export
gf.G_ROE_Q <- function(TS, filt=10000000){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,9900100,0),
  "NP_t0",RefReportValue(@LastQuarterData(DefaultRepID(),46078,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$NP_t0) & abs(re$NP_t0)<filt, "factorscore"] <- NA
  return(re)
}


# -- EPS
#' @rdname getfactor
#' @export
gf.G_EPS_Q <- function(TS, filt=10000000){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,9900000,1),
  "NP_t0",RefReportValue(@LastQuarterData(DefaultRepID(),46078,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$NP_t0) & abs(re$NP_t0)<filt, "factorscore"] <- NA
  return(re)
}



# -- scissor
#' @rdname getfactor
#' @export
gf.G_scissor_Q <- function(TS, filt=10000000){
  funchar <-  '"factorscore",LastQuarterData(Rdate,9900604,0)-LastQuarterData(Rdate,9900600,0),
  "NP_t0",RefReportValue(@LastQuarterData(DefaultRepID(),46078,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$NP_t0) & abs(re$NP_t0)<filt, "factorscore"] <- NA
  return(re)
}



# --- NP --
#' @rdname getfactor
#' @export
gf.G_NP_Q <- function(TS, filt=10000000){
  funchar <-  '"factorscore",LastQuarterData(Rdate,9900604,0),
  "NP_t0",RefReportValue(@LastQuarterData(DefaultRepID(),46078,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$NP_t0) & abs(re$NP_t0)<filt, "factorscore"] <- NA
  return(re)
}
#' @rdname getfactor
#' @export
gf.G_NP_ttm <- function(TS, filt=10000000){
  funchar <-  '"factorscore",Last12MData(Rdate,9900604),
  "NP_t0",RefReportValue(@Last12MData(DefaultRepID(),46078),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$NP_t0) & abs(re$NP_t0)<filt, "factorscore"] <- NA
  return(re)
}
#' @rdname getfactor
#' @export
gf.G_NPcut_Q <- function(TS, filt=10000000){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,42017,1),
  "NP_t0",RefReportValue(@LastQuarterData(DefaultRepID(),42017,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$NP_t0) & abs(re$NP_t0)<filt, "factorscore"] <- NA
  return(re)
}
#' @rdname getfactor
#' @export
gf.GG_NP_Q <- function(TS, filt=10000000){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,9900604,0),
  "NP_t1",RefReportValue(@LastQuarterData(DefaultRepID(),46078,0),Rdate,1),
  "NP_t2",RefReportValue(@LastQuarterData(DefaultRepID(),46078,0),Rdate,2)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[(!is.na(re$NP_t1) & abs(re$NP_t1)<filt) | (!is.na(re$NP_t2) & abs(re$NP_t2)<filt), "factorscore"] <- NA
  return(re)
}


# --- OR --
#' @rdname getfactor
#' @export
gf.G_OR_Q <- function(TS, filt=100000000){
  funchar <-  '"factorscore",LastQuarterData(Rdate,9900600,0),
  "OR_t0",RefReportValue(@LastQuarterData(DefaultRepID(),46002,0),Rdate,1)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[!is.na(re$OR_t0) & abs(re$OR_t0)<filt, "factorscore"] <- NA
  return(re)
}

#' @rdname getfactor
#' @export
gf.GG_OR_Q <- function(TS, filt=100000000){
  funchar <-  '"factorscore",QuarterTBGrowRatio(Rdate,9900600,0),
  "OR_t1",RefReportValue(@LastQuarterData(DefaultRepID(),46002,0),Rdate,1),
  "OR_t2",RefReportValue(@LastQuarterData(DefaultRepID(),46002,0),Rdate,2)'
  re <- TS.getFin_by_rptTS(TS,fun="rptTS.getFin_ts",funchar= funchar)
  # -- filtering
  re[(!is.na(re$OR_t1) & abs(re$OR_t1)<filt) | (!is.na(re$OR_t2) & abs(re$OR_t2)<filt), "factorscore"] <- NA
  return(re)
}

#' @rdname getfactor
#' @export
gf.stable_growth <- function(TS,N=12,freq="q",stat="mean/sd",rm_N=6){
  check.TS(TS)
  funchar <-  '"factorscore",LastQuarterData(Rdate,9900604,0)'
  re <- TS.getFin_by_rptTS(TS,fun = rptTS.getFinStat_ts, N = N,freq = freq,funchar = funchar,stat=stat,rm_N=rm_N)
}




# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
# ===================== get factors through database ===================
# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============

#' TS.getFactor.db
#'
#' get factors throug a SQL qurey from a database
#' @param TS a \bold{TS} object
#' @param subfun a function object,which get the factors of a subset of TS from the database.
#' @param ... other parametres of subfun
#' @note Note that the subfun must contain subset of TS as the first argument. and the subset must be a subset of TS on a certain "date".
#' @return A \bold{TSF} object
#' @author Ruifei.Yin
#' @examples
#' TS <- getTS(getRebDates(as.Date('2011-03-17'),as.Date('2012-04-17')),'EI000300')
#' subfun <- function(subTS,con_type){ # con_type indicate the consensus type
#'   dt <- subTS[1,"date"]
#'   qr_char <- paste("SELECT stock_code,con_date,con_type,c80
#'       FROM CON_FORECAST_STK a
#'         where a.con_date=",QT(dt),"and year(a.con_date)=a.rpt_date and a.stock_type=1 and con_type=",con_type,"and a.rpt_type=4")
#'   tmpdat <- queryAndClose.odbc(db.cs(),qr_char,as.is=1)
#'   subTS$stock_code <- stockID2tradeCode(subTS$stockID)
#'   re <- merge(subTS,tmpdat,by="stock_code",all.x=TRUE)
#'   re <- re[,c(names(TS),"c80")]
#'   re <- renameCol(re,"c80","factorscore")
#'   return(re)
#' }
#'  TSF <- TS.getFactor.db(TS,subfun,con_type=1)
TS.getFactor.db <- function(TS, subfun, ...){
  check.TS(TS)
  # cat("Function TS.getFactor.db Working...\n")
  re <- plyr::ddply(TS, "date", subfun,...)
  return(re)
}


# ----- some examples -------------
#' @rdname getfactor
#' @export
gf.F_NP_chg <- function(TS,span="w13",con_type="1"){
  # span: "w1","w4","w13","w26","w52"
  # con_type: one or more of 1,2,3,4
  subfun <- function(subTS,span,con_type){
    dt <- subTS[1,"date"]
    var <- switch(span,
                  w1="con_npgrate_1w",
                  w4="con_npgrate_4w",
                  w13="con_npgrate_13w",
                  w26="con_npgrate_26w",
                  w52="con_npgrate_52w")
    qr_char <- paste("SELECT stock_code,con_date,con_np_type as con_type,",var,"
                     FROM con_forecast_stk a
                     where a.con_date=",QT(dt),"and year(a.con_date)=a.con_year and con_np_type in (",con_type,")")
    tmpdat <- queryAndClose.odbc(db.cs(),qr_char,as.is=1)
    tmpdat$con_date <- as.Date(tmpdat$con_date)
    subTS$stock_code <- stockID2tradeCode(subTS$stockID)
    re <- merge(subTS,tmpdat,by="stock_code",all.x=TRUE)
    re <- re[,c(names(TS),var)]
    re <- renameCol(re,var,"factorscore")
    return(re)
  }
  re <- TS.getFactor.db(TS,subfun,span=span,con_type=con_type)
  return(re)
}







#' @rdname getfactor
#' @export
gf.F_rank_chg <- function(TS,lag=60,con_type="1"){
  # lag: integer,ginving the number of lag tradingdays
  # con_type: one or more of 1,2,3,4
  subfun <- function(subTS,lag,con_type){
    dt <- subTS[1,"date"]
    dt_lag <- trday.nearby(dt,by=-lag)
    qr_char <- paste(
      "select a.stock_code,a.con_date,a.con_rating_strength 'score',a.con_rating_type 'score_type',
      b.con_rating_strength 'score_ref',b.con_rating_type 'score_type_ref',
      a.con_rating_strength/(case when b.con_rating_strength=0 then NULL else b.con_rating_strength end)-1 as factorscore
      from con_rating_stk a,con_rating_stk b
      where a.con_date=",QT(dt),"and a.con_rating_type in (",con_type,")
      and b.con_date=",QT(dt_lag),"and b.stock_code=a.stock_code"
    )
    tmpdat <- queryAndClose.odbc(db.cs(),qr_char,as.is=1)
    tmpdat$con_date <- as.Date(tmpdat$con_date)
    subTS$stock_code <- stockID2tradeCode(subTS$stockID)
    re <- merge(subTS,tmpdat,by="stock_code",all.x=TRUE)
    #     re <- re[,c(names(TS),"factorscore")]
    return(re)
  }
  re <- TS.getFactor.db(TS,subfun,lag=lag,con_type=con_type)
  return(re)
}



#' @rdname getfactor
#' @export
gf.F_target_rtn <- function(TS,con_type="1"){
  # con_type: one or more of 1,2,3,4
  subfun <- function(subTS,con_type){
    dt <- subTS[1,"date"]
    qr_char <- paste(
      "SELECT a.stock_code,a.con_date,a.con_target_price as target_price,a.con_target_price_type as target_price_type,
      b.tclose as TCLOSE,a.con_target_price/(case when b.tclose=0 then NULL else b.tclose end)-1 as factorscore
      FROM con_target_price_stk a, qt_stk_daily b
      where a.con_date=",QT(dt),"and a.con_target_price_type in (",con_type,")
      and b.trade_date=",QT(dt),"and b.stock_code=a.stock_code")
    tmpdat <- queryAndClose.odbc(db.cs(),qr_char,as.is=1)
    tmpdat$con_date <- as.Date(tmpdat$con_date)
    subTS$stock_code <- stockID2tradeCode(subTS$stockID)
    re <- merge(subTS,tmpdat,by="stock_code",all.x=TRUE)
    return(re)
  }
  re <- TS.getFactor.db(TS,subfun,con_type=con_type)
  return(re)
}



# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
# ===================== Andrew  ===================
# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============

#inner function
andrew_rawdata_subfun <- function(TS,nwin,variables,datasrc){
  stocks <- unique(TS$stockID)
  begT <- trday.nearby(min(TS$date),-nwin)
  endT <- max(TS$date)
  if(datasrc=='local'){
    rawdata <- getQuote(stocks,begT,endT,variables,datasrc = "local",split = FALSE)
  }else if(datasrc=='quant'){
    rawdata <- getQuote(stocks,begT,endT,variables,tableName = 'QT_DailyQuote',datasrc = 'quant',split = FALSE)
  }
  return(rawdata)
}





#' @rdname getfactor
#' @export
gf.liquidity <- function(TS,nwin=c(22,66,250),wgt=c(0.35,0.35,0.3),datasrc=defaultDataSRC()){
  check.TS(TS)
  
  variables <- c("volume","free_float_shares")
  rawdata <- andrew_rawdata_subfun(TS,max(nwin),variables,datasrc)
  
  #process rawdata
  rawdata <- rawdata %>% dplyr::mutate(TurnoverRate=volume/(free_float_shares*1e4)) %>% 
    dplyr::filter(TurnoverRate>=0) %>% dplyr::select(-volume,-free_float_shares)
  
  #get mTSF
  mTSF <- TS
  for(i in 1:length(nwin)){
    TSF_ <- rawdata %>% dplyr::arrange(stockID,date) %>% dplyr::group_by(stockID) %>% 
      dplyr::mutate(factorscore=RcppRoll::roll_sum(TurnoverRate,nwin[i],align = "right",fill=NA,na.rm = TRUE)) %>% 
      dplyr::ungroup() %>% dplyr::select(-TurnoverRate)
    TSF_ <- TSF_ %>% dplyr::filter(factorscore>0) %>% dplyr::mutate(stockID=as.character(stockID),factorscore=log(factorscore))
    
    mTSF <- dplyr::left_join(mTSF,TSF_,by=c('date','stockID'))
  }
  
  #multifactor to one factor
  if(length(nwin)>1){
    fname <- paste("LIQ",nwin,sep = "")
    colnames(mTSF) <- c('date','stockID',fname)
    mTSF <- mTSF[rowSums(is.na(mTSF[,fname])) != length(nwin),] #remove all na in one row
    mTSF <- MultiFactor2CombiFactor(mTSF,wgt,factorNames =fname ,keep_single_factors = FALSE)
  }
  mTSF <- na.omit(mTSF)
  
  #factor orthogon
  size_ <- gf.ln_mkt_cap(mTSF[,c('date','stockID')])
  size_ <- dplyr::rename(size_,size=factorscore)
  mTSF <- dplyr::left_join(mTSF,size_,by=c('date','stockID'))
  mTSF <- RFactorModel::factor_orthogon_single(mTSF,'factorscore','size',sectorAttr = NULL)
  TSF <- dplyr::left_join(TS,mTSF,by=c('date','stockID'))
  return(TSF[,c("date","stockID","factorscore")])
}


#' @rdname getfactor
#' @export
gf.ILLIQ <- function(TS,nwin=22,datasrc = defaultDataSRC()){
  check.TS(TS)
  
  #get rawdata
  variables <- c("pct_chg","amt")
  rawdata <- andrew_rawdata_subfun(TS,nwin,variables,datasrc)
  
  #process rawdata
  rawdata <- rawdata %>% dplyr::filter(amt>0) %>% dplyr::mutate(ILLIQ=abs(pct_chg)/(amt/1e8)) %>% 
    dplyr::select(date,stockID,ILLIQ)
  
  #get TSF
  TSF <- rawdata %>% dplyr::arrange(stockID,date) %>% dplyr::group_by(stockID) %>% 
    dplyr::mutate(factorscore=RcppRoll::roll_mean(ILLIQ,nwin,align = "right",fill=NA,na.rm = TRUE)) %>% dplyr::ungroup() %>% 
    dplyr::select(-ILLIQ) %>% dplyr::filter(!is.na(factorscore))
  
  TSF <- TSF %>% dplyr::filter(factorscore>0) %>% dplyr::mutate(stockID=as.character(stockID),factorscore=log(factorscore))
  TSF <- as.data.frame(TSF)
  
  TSF <- dplyr::left_join(TS,TSF,by = c("date", "stockID"))
  return(TSF)
}



#' @rdname getfactor
#' @export
gf.beta <- function(TS,nwin=240,indexID='EI801003',datasrc=defaultDataSRC()){
  check.TS(TS)
  if(datasrc %in% c('local','quant')){
    
    #get rawdata
    variables <- c("pct_chg")
    rawdata <- andrew_rawdata_subfun(TS,nwin,variables,datasrc)
    begT <- trday.nearby(min(TS$date),-nwin)
    endT <- max(TS$date)
    index <- getIndexQuote("EI801003",begT,endT,'pct_chg',datasrc = 'jy')
    index <- dplyr::rename(index,index_pct_chg=pct_chg)
    rawdata <- dplyr::left_join(rawdata,index[,c('date','index_pct_chg')],by='date')
    
    pb <- txtProgressBar(style = 3)
    dates <- unique(TS$date)
    TSF <- data.frame()
    for(i in 1:length(dates)){
      begT <- trday.nearby(dates[i],-nwin)
      TS_ <- TS[TS$date==dates[i],]
      rawdata_ <- rawdata %>% dplyr::filter(date<dates[i],date>=begT,stockID %in% TS_$stockID)
      rawdata_ <- rawdata_ %>% dplyr::arrange(stockID,date) %>% dplyr::group_by(stockID)  %>%  
        dplyr::filter(n()>=nwin/2)
      
      TSF_ <- rawdata_ %>% dplyr::do(factorscore = lm(pct_chg ~ index_pct_chg, data = .)$coef[[2]]) %>% dplyr::ungroup()
      TSF_ <- transform(TSF_,date=dates[i],stockID=as.character(stockID),factorscore=as.numeric(factorscore))
      TSF <- rbind(TSF,TSF_[,c("date","stockID","factorscore")])
      setTxtProgressBar(pb,  i/length(dates))
    }
    close(pb)
    
    
  }else if(datasrc=='ts'){
    
    stopifnot(nwin %in% c(120,240))
    ipoday <- data.frame(stockID=unique(TS$stockID),stringsAsFactors = FALSE)
    ipoday <- ipoday %>% dplyr::mutate(ipo=rdate2int(trday.IPO(stockID)))
    ipoday <- transform(ipoday,ipo=intdate2r(ifelse(ipo<19901219,19901219,ipo)))
    ipoday <- ipoday %>% dplyr::mutate(tmpdate=trday.nearby(ipo,nwin/2)) %>% dplyr::select(stockID,tmpdate)
    
    TS_ <- TS %>% dplyr::left_join(ipoday,by='stockID') %>% dplyr::filter(date>tmpdate) %>% 
      dplyr::select(date,stockID)
    indexID <- stockID2stockID(indexID,'local','ts')
    if(nwin==240){
      funchar <- paste("StockBeta4(",QT(indexID),",19)",sep='')
    }else if(nwin==120){
      funchar <- paste("StockBeta4(",QT(indexID),",18)",sep='')
    }
    TSF <- TS.getTech_ts(TS_,funchar,varname = 'factorscore')
  }
  
  TSF <- dplyr::left_join(TS,TSF,by = c("date", "stockID"))
  return(TSF)
}






#' @rdname getfactor
#' @export
gf.IVR <- function(TS,nwin=22,datasrc=defaultDataSRC()){
  check.TS(TS)
  
  #get rawdata
  variables <- c("pct_chg")
  rawdata <- andrew_rawdata_subfun(TS,nwin,variables,datasrc)
  
  #get fama french 3 factors
  indexs <- c('EI801003','EI801811','EI801813','EI801831','EI801833')
  begT <- trday.nearby(min(TS$date),-nwin)
  endT <- max(TS$date)
  FF3 <- getIndexQuote(indexs,begT,endT,"pct_chg",datasrc = 'jy')
  FF3 <- reshape2::dcast(FF3,date~stockID,value.var = 'pct_chg')
  FF3 <- transform(FF3,SMB=EI801813-EI801811,HML=EI801833-EI801831,market=EI801003)
  FF3 <- FF3[,c('date','SMB','HML','market')]
  
  rawdata <- dplyr::left_join(rawdata,FF3,by='date')
  
  pb <- txtProgressBar(style = 3)
  dates <- unique(TS$date)
  TSF <- data.frame()
  for(i in 1:length(dates)){
    begT <- trday.nearby(dates[i],-nwin)
    TS_ <- TS[TS$date==dates[i],]
    rawdata_ <- rawdata %>% dplyr::filter(date<dates[i],date>=begT,stockID %in% TS_$stockID)
    rawdata_ <- rawdata_ %>% dplyr::arrange(stockID,date) %>% dplyr::group_by(stockID)  %>%  
      dplyr::filter(n()>=nwin/2,sum(pct_chg==0)<nwin/2)
    
    TSF_ <- rawdata_ %>% dplyr::do(factorscore =  1-summary(lm(pct_chg ~ SMB+HML+market,data = .))$r.squared) %>% dplyr::ungroup()
    TSF_ <- transform(TSF_,date=dates[i],stockID=as.character(stockID),factorscore=as.numeric(factorscore))
    TSF <- rbind(TSF,TSF_[,c("date","stockID","factorscore")])
    setTxtProgressBar(pb,  i/length(dates))
  }
  close(pb)
  TSF <- dplyr::left_join(TS,TSF,by = c("date", "stockID"))
  return(TSF)
}



#' @rdname getfactor
#' @export
gf.volatility <- function(TS,nwin=60){
  check.TS(TS)
  funchar <- paste("StockStdev2(",nwin,")",sep='')
  TSF <- TS.getTech_ts(TS,funchar,varname = 'factorscore')
  return(TSF)
}


#' @rdname getfactor
#' @export
gf.disposition <- function(TS,nwin=66,datasrc=defaultDataSRC()){
  check.TS(TS)
  
  #get rawdata
  variables <- c("RRclose","volume","free_float_shares")
  rawdata <- andrew_rawdata_subfun(TS,nwin,variables,datasrc)
  rawdata <- rawdata %>% dplyr::filter(free_float_shares>0) %>% dplyr::mutate(turnover=abs(volume/1e4)/free_float_shares) %>% 
    dplyr::select(date,stockID,RRclose,turnover)
  
  pb <- txtProgressBar(style = 3)
  dates <- unique(TS$date)
  TSF <- data.frame()
  for(i in 1:length(dates)){
    begT <- trday.nearby(dates[i],-nwin)
    
    #subset rawdata
    re <- rawdata %>% dplyr::filter(stockID %in% TS[TS$date==dates[i],'stockID'],date>=begT,date<dates[i]) %>% 
      dplyr::arrange(stockID,date)
    
    #add last price
    re <- re %>% dplyr::group_by(stockID) %>% 
      dplyr::mutate(P = last(RRclose)) %>% dplyr::ungroup()
    
    #add gain loss 
    re <- re %>% dplyr::mutate(gain=ifelse(RRclose<P,1-RRclose/P,0),loss=ifelse(RRclose>P,1-RRclose/P,0),turnovervise=1-turnover) %>% 
      dplyr::select(-P,-RRclose)
    
    #remove data
    re <- re %>% dplyr::arrange(stockID,desc(date)) %>% dplyr::group_by(stockID) %>% 
      dplyr::filter(n()==nwin,any(turnover!=0))
    
    #add one column
    re <- re %>% dplyr::mutate(tmp = c(1,cumprod(.$turnovervise[1:(nwin-1)]))) %>% dplyr::ungroup()
    
    #get wgt column  
    re <- re %>% dplyr::mutate(wgt = turnover*tmp) %>% dplyr::group_by(stockID) %>% 
      dplyr::mutate(wgt=wgt/sum(wgt))
    
    TSF_ <- re %>% dplyr::summarise(factorscore=as.numeric(gain %*% wgt+loss %*% wgt)) %>% 
      dplyr::ungroup() %>% dplyr::mutate(date=dates[i],stockID=as.character(stockID))
    
    TSF <- rbind(TSF,TSF_)
    setTxtProgressBar(pb,i/length(dates))
  }
  close(pb)
  TSF <- dplyr::left_join(TS,TSF,by = c("date", "stockID"))
  return(TSF)
}



#' @rdname getfactor
#' @export
gf.dividendyield <- function(TS,datasrc=c('ts','jy','wind')){
  datasrc <- match.arg(datasrc)
  if(datasrc=='jy'){
    tmp <- brkQT(substr(unique(TS$stockID),3,8))
    qr <- paste("SELECT convert(varchar,TradingDay,112) 'date',
                'EQ'+s.SecuCode 'stockID',isnull(DividendRatio,0) 'factorscore'
                FROM LC_DIndicesForValuation d,SecuMain s
                where d.InnerCode=s.InnerCode and s.SecuCode in",tmp,
                " and d.TradingDay>=",QT(min(TS$date))," and d.TradingDay<=",QT(max(TS$date)),
                " ORDER by d.TradingDay")
    re <- queryAndClose.odbc(db.jy(),qr,stringsAsFactors=FALSE)
    re <- transform(re,date=intdate2r(date))
    TSF <- dplyr::left_join(TS,re,by=c('date','stockID'))
  }else if(datasrc=='wind'){
    require(WindR)
    w.start(showmenu = FALSE)
    newTS <- transform(TS,stockID=stockID2stockID(stockID,'local','wind'))
    dates <- unique(TS$date)
    re <- data.frame()
    for(i in dates){
      i <- as.Date(i,origin='1970-01-01')
      tmp <- w.wss(newTS[newTS$date==i,'stockID'],'dividendyield2',tradeDate=i)[[2]]
      colnames(tmp) <- c('stockID','factorscore')
      tmp$date <- i
      re <- rbind(re,tmp[,c('date','stockID','factorscore')])
    }
    re <- transform(re,stockID=stockID2stockID(stockID,'wind','local'),
                    factorscore=factorscore/100)
    TSF <- dplyr::left_join(TS,re,by=c('date','stockID'))
  }else if(datasrc=='ts'){
    dates <- unique(TS$date)
    TSF <- data.frame()
    for(i in 1:length(dates)){
      stocks <- c(TS[TS$date==dates[i],'stockID'])
      funchar <- paste("'factorscore',StockDividendYieldRatio(",rdate2ts(dates[i]),")",sep = '')
      re <- ts.wss(stocks,funchar)
      TSF <- rbind(TSF,data.frame(date=dates[i],re))
    }
    TSF <- dplyr::left_join(TS,TSF,by=c('date','stockID'))
  }
  
  return(TSF)
}


# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
# ===================== Mazi  ===================
# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============

#' @rdname getfactor
#' @author han.qian
#' @export
gf.High3Managers <- function(TS){
  check.TS(TS)
  beg_year <- (lubridate::year(min(TS$date))) - 2
  end_year <- (lubridate::year(max(TS$date))) - 1
  
  ###### WIND DATA BASE
  suppressMessages(require(WindR))
  suppressMessages(w.start(showmenu = FALSE))
  year_char <- as.character(beg_year:end_year)
  dat_High3Managers <- data.frame()
  for(i in 1:length(year_char)){
    year_ <- year_char[i]
    qr_ <- paste0('year=',year_,';sectorid=a001010100000000')
    dat_ <- w.wset('managersalarystat',qr_)
    dat_ <- dat_$Data
    dat_High3Managers <- rbind(dat_High3Managers, dat_)
  }
  
  # FORMAT CLEASING
  dat_High3Managers$report_date <- w.asDateTime(dat_High3Managers$report_date, asdate = TRUE)
  dat_High3Managers$wind_code <- stockID2stockID(dat_High3Managers$wind_code, from = "wind", to = "local")
  dat_High3Managers <- dat_High3Managers[,c("report_date","wind_code","3_managers_compensation")]
  colnames(dat_High3Managers) <- c("rptDate","stockID","factorscore")
  dat_High3Managers[is.nan(dat_High3Managers$factorscore),"factorscore"] <- NA
  
  TS_rpt <- getrptDate_newest(TS, freq = "y")
  TS_rpt <- na.omit(TS_rpt) # SOME DATA COULD NOT GET THE LATEST RPTDATE
  TSF <- merge.x(TS_rpt, dat_High3Managers, by = c("rptDate","stockID"))
  TSF <- TSF[,c("date","stockID","factorscore")]
  TSF$factorscore <- ifelse(TSF$factorscore<0.001,NA,log(TSF$factorscore))
  TSF_final <- merge.x(TS, TSF, by = c("date","stockID"))   # MAKE SURE NROW OF TSF IS THE SAME AS NROW OF TS
  # w.stop()
  return(TSF_final)
}


#' @rdname getfactor
#' @author han.qian
#' @export
gf.pio_f_score <- function(TS){
  
  # TS manipulating
  check.TS(TS)
  TS_old <- TS
  TS_old$date <- trday.offset(TS$date, by = lubridate::years(-1))
  TS_rpt <- getrptDate_newest(TS)
  TS_old_rpt <- TS_rpt
  TS_old_rpt$rptDate <- rptDate.yoy(TS_old_rpt$rptDate)
  
  # get data part1
  multi_funchar <- '"OCF",reportofall(9900005,Rdate),
  "dOCF",reportofall(9900004,Rdate),
  "NetValue",reportofall(9900003,Rdate),
  "Debt",reportofall(9900024,Rdate),
  "Leverage",reportofall(9900203,Rdate),
  "CurrentRatio",reportofall(9900200,Rdate),
  "GrossMargin",reportofall(9900103,Rdate),
  "AssetTurnoverRate",reportofall(9900416,Rdate),
  "ROA",reportofall(9900100,Rdate)'
  
  dat <- rptTS.getFin_ts(TS_rpt, multi_funchar)
  dat_old <- rptTS.getFin_ts(TS_old_rpt, multi_funchar)
  
  # get data part2
  dat_extra <- gf.totalshares(TS)
  dat_extra_old <- gf.totalshares(TS_old)
  
  # data double checking
  if((nrow(dat) != nrow(TS)) | (nrow(dat_old) != nrow(TS)) | (nrow(dat_extra) != nrow(TS)) | 
     (nrow(dat_extra_old) != nrow(TS))){
    stop("Data retrieving failed.")
  }
  
  # TSF
  TSF <- TS
  # PROFITABILITY
  ### ROA > 0
  TSF$score1 <- (dat$ROA > 0) + 0
  ### OCF > 0
  TSF$score2 <- (dat$OCF > 0) + 0
  ### dROA > 0
  TSF$score3 <- (dat$ROA > dat_old$ROA) + 0
  ### ACCRUALS [(OPERATING CASH FLOW/TOTAL ASSETS) > ROA]
  TSF$score4 <- ((dat$OCF/(dat$NetValue + dat$Debt)*100) > dat$ROA) + 0
  
  # LEVERAGE, LIQUIDITY AND SOURCE OF FUNDS
  ### dLEVERAGE(LONG-TERM) < 0
  TSF$score5 <- (dat$Leverage < dat_old$Leverage) + 0
  ### d(Current ratio) > 0
  TSF$score6 <- (dat$CurrentRatio > dat_old$CurrentRatio) + 0
  ### d(Number of shares) == 0
  TSF$score7 <- (dat_extra$factorscore == dat_extra_old$factorscore) + 0
  
  # OPERATING EFFICIENCY
  ### d(Gross Margin) > 0
  TSF$score8 <- (dat$GrossMargin > dat_old$GrossMargin) + 0
  ### d(Asset Turnover ratio) > 0
  TSF$score9 <- (dat$AssetTurnoverRate > dat_old$AssetTurnoverRate) + 0

  # output
  TSF$factorscore <- rowSums(dplyr::select(TSF,score1:score9),na.rm = TRUE)
  TSF <- dplyr::select(TSF,-dplyr::num_range("score", 1:9))
  return(TSF)
}

# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============
# ===================== to be tested  ===================
# ===================== xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ==============

#' @export
gf.rotation_s <- function(TS){
  PB <- gf.PB_mrq(TS)$factorscore
  roe <- gf.ROE_ttm(TS)$factorscore/100
  rotation <- PB/ROE
  return(data.frame(TS,factorscore=rotation,PB=PB,roe=roe))
}

#' @export
gf.rotation <- function(TS){
  PB <- gf.PB_mrq(TS)$factorscore
  roe <- gf.ROE_ttm(TS)$factorscore/100
  rotation <- log(2*PB,(1+roe))
  return(data.frame(TS,factorscore=rotation,PB=PB,roe=roe))
}



