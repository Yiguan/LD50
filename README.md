# LD50
The package is used to calculate median lethal dose/concentration, LD50/LC50.
## Description

If death rate in control group < 0.05, no correction is needed; if death rate between 0.05 - 0.2, using Abbott fomula to adjust the assay; if death rate > 0.2, invalid assay. Program will stop!

## Usage

LD_cal(dfr)

## Arguments
dfr

A dataframe with three variables(concentration/dose, death, total), make sure the first observation(row) is control.

## Examples

```R
library(LD50)

aa <- data.frame('con' = c(0,0.01,0.02,0.04,0.08,0.16,0.32), 'death' = c(1,6,16,23,25,34,44), 'total' = c(60,59,60,60,57,58,60))

LD_cal(aa)

```

## output
```
[1] Control OK!

[2] Summary of Model: 
$coefficients
            Estimate Std. Error  z value     Pr(>|z|)
(Intercept) 1.155386  0.1881415 6.141050 8.197784e-10
log_c       1.118938  0.1450051 7.716541 1.195288e-14


[3] Chi-square test for goodness of fit:
 Chi_square df   P_value
   2.060938  4 0.7245516

[4] Estimate of LD50-LD99: 
        estimate        lci       uci
LD50  0.09277388 0.06846923  0.125706
LD90  1.29644665 0.57085152  2.944328
LD95  2.73803809 1.00694110  7.445175
LD99 11.12997629 2.89860174 42.736596
```

## conclusion
The results are very consistent with results from SAS and SPSS. The advantage using this package is to be able to adjust your observations based on control group using Abbott formula.
