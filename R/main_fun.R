#' @title calculate LC/LC
#' @description 
#' Used for control. If death rate in control group < 0.05, no correction is needed;
#' if death rate between 0.05 - 0.2, using Abbott fomula to adjust the assay;
#' if death rate > 0.2, invalid assay. Program will stop! Private function in LD50 package.
#' @param df A dataframe with three variables(concentration/dose, death, total), the first observation is control.
#' @export
ctl <- function(df){
  if(df[1,4] < 0.05){
    cat("\n[1] Control OK!\n")
    df$adjust <- df[,4]
  }
  else if(df[1,4] > 0.2){
    stop("Too high death rate in control!")
  }
  else {
    cat("\n[1] Control used for Abbott Adjustment!\n")
    df$adjust <- (df[,4] - df[1,4])/(1 - df[1,4])
  }
  return(df)
}

#' @title calulate LDx
#' @description 
#' LDx is used to infer LD50 and corresponding CI.
#' For private use in package LD50.
#' @import MASS
#' @param fit.model a object of glm model
#' @param x which death rate, eg, LD50 -> x = 0.5
#' @export
LDx <- function(fit.model, x){
  mm <- dose.p(fit.model, p = x)
  Dx <- 10^c(mm + c(0, -1.96, 1.96) * attr(mm, "SE")) 
  return(Dx)
}


#' @title main function to calculate LD50.
#' @description 
#' If death rate in control group < 0.05, no correction is needed;
#' if death rate between 0.05 - 0.2, using Abbott fomula to adjust the assay;
#' if death rate > 0.2, invalid assay. Program will stop! 
#' @param dfr A dataframe with three variables(concentration/dose, death, total), make sure the first observation(row) is control.
#' @import stats
#' @export
#' @examples 
#' aa <- data.frame('con' = c(0,0.01,0.02,0.04,0.08,0.16,0.32), 
#' 'death' = c(1,6,16,23,25,34,44), 'total' = c(60,59,60,60,57,58,60))
#' LD_cal(aa)
#' 
LD_cal <- function(dfr){
  dfr$death_rate <- dfr[,2]/dfr[,3]
  dfr.adj <- ctl(dfr)
  dfr.adj$log_c <- log10(dfr.adj[,1])
  dfr.adj <- dfr.adj[-1,] # remove control
  dfr.adj <- dfr.adj[dfr.adj$adjust > 0 & dfr.adj$adjust < 1,]
  dfr.fit <- glm(adjust ~ log_c, weights = dfr.adj[,3],
                family = binomial(link = 'probit'), data = dfr.adj)
  cat("\n[2] Summary of Model: \n")
  print(summary(dfr.fit)[12], row.names = F)
  
  chi <- data.frame("Chi_square" = dfr.fit$deviance, "df" = dfr.fit$df.residual, 
                    "P_value" = pchisq(dfr.fit$deviance, df = dfr.fit$df.residual,lower.tail = F))
  cat("\n[3] Chi-square test for goodness of fit:\n")
  print(chi, row.names = F)
  
  LD_df <- data.frame()                      
  for (x in c(0.5,0.90,0.95,0.99)){
    tmp <- LDx(dfr.fit, x)
    LD_df <- rbind(LD_df, tmp)
  }
  names(LD_df) <- c("estimate","lci","uci")
  row.names(LD_df) <- paste0("LD", c(50,90,95,99))
  cat("\n[4] Estimate of LD50-LD99: \n")
  print(LD_df)
}