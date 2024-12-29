

** 5th June 2024 ****
******* panel quantile regression *******
******* lbr share industry *******



import excel "C:\Users\user\Desktop\Macro Papers\thesis\result\panel\data_panel.xlsx", sheet("Sheet8") firstrow
set seed 8675309
capture postutil clear
tempfile holding
postfile handle quantile coefficient se using `holding'

*** quantile regression *** 

///qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr , id(idcode) fix(year) optimize(mcmc) noisy draws(1000) burn(100) arate(.5)
forvalues i=1(1)9{
local ii=`i'/10
qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr targetfactor reer, quantile(`ii') id(industry) fix(time) optimize(mcmc) ///
draws(10000) burn(1000) arate(0.5)
post handle (`ii') (_b[targetfactor]) (_se[targetfactor])
}
postclose handle

use `holding', clear
gen lb=coefficient-se*1.65 //90% Confidence interval
gen ub=coefficient+se*1.65 //90% Confidence interval
graph twoway (rarea lb ub quantile) || (line coefficient quantile)



//////////////////////




capture postutil clear
tempfile holding
postfile handle quantile coefficient lb ub using `holding'

forvalues i=1/9 {
    local ii = `i'/10
    qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr targetfactor reer, quantile(`ii') id(industry) fix(time) optimize(mcmc) ///
    draws(10000) burn(1000) arate(0.5)
    matrix M = r(table)
    post handle (`ii') (_b[targetfactor]) (M[1, 5]) (M[1,6])
}
postclose handle

//regress lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr targetfactor reer
//gen ols_coeff = _b[targetfactor]

//label var lb "lower limits"
//label var ub "upper limits"
//label var coefficient "beta"
//label var ols_coef "ols"

use `holding', clear
gen lb=coefficient-se*1.65 //90% Confidence interval
gen ub=coefficient+se*1.65 //90% Confidence interval
graph twoway (rarea lb ub quantile) || (line coefficient quantile)



qui regress lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d

predict residuals_i, resid
sort industry
by industry: egen alphat_i=mean(residuals_i)
summarize alphat_i

gen lab_inc_sh_vahat=lab_inc_sh_va-alphat_i


***  bootstrapped quantile regresion
set seed 10101
qui bsqreg lab_inc_sh_vahat lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d, quant(0.25) reps(400)
estimates store FE25boot
qui bsqreg lab_inc_sh_vahat lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d, quant(0.75) reps(400)
estimates store FE75boot



xtset industry
qui bootstrap, reps(400) seed(10101) cluster(industry): qreg lab_inc_sh_vahat lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d, quant(0.25)
estimates store FE25clus


qui bootstrap, reps(400) seed(10101) cluster(industry):qreg lab_inc_sh_vahat lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d, quant(0.75)
estimates store FE75clus

estimates table FE25boot FE75boot FE25clus FE75clus, b() p



xtset industry
qui bootstrap, reps(400) seed(10101) cluster(industry): qreg lab_inc_sh_vahat lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d, quant(0.80)
estimates store FE80clus

xtset industry
qui bootstrap, reps(400) seed(10101) cluster(industry): qreg lab_inc_sh_vahat lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d, quant(0.90)
estimates store FE90clus



xtset industry
qui bootstrap, reps(400) seed(10101) cluster(industry): qreg lab_inc_sh_vahat lab_prod price_index l_k_ratio fiscal wacr targetfactor reer c.targetfactor#d, quant(0.20)
estimates store FE20clus

estimates table FE80clus FE90clus FE20clus FE10clus, b() p


****** final regression ******

import excel "C:\Users\user\Desktop\Macro Papers\thesis\result\panel\data_panel.xlsx", sheet("Sheet8") firstrow
 qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr , id(idcode) fix(year) optimize(mcmc) noisy draws(1000) burn(100) arate(.5)
 qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr , id(industry) fix(time) optimize(mcmc) noisy draws(1000) burn(100) arate(.5)
 qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr , id(industry) fix(time) optimize(mcmc) noisy draws(1000) burn(100) arate(.1)
 qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr , id(industry) fix(time) optimize(mcmc) noisy draws(1000) burn(100) arate(0.9)
 qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal PathFactor , id(industry) fix(time) optimize(mcmc) noisy draws(1000) burn(100) arate(0.9)
 qregpd lab_inc_sh_va lab_prod price_index l_k_ratio fiscal PathFactor , id(industry) fix(time) optimize(mcmc) noisy draws(1000) burn(100) arate(0.9)
xtset industry time, yearly
xtunitroot llc lab_inc_sh_va
xtunitroot llc fiscal
xtunitroot llc wacr
xtunitroot llc l_k_ratio
xtunitroot llc price_index
xtunitroot llc price_index
xtunitroot llc lab_prod
xtunitroot llc fiscal, trend
xtunitroot llc fiscal, noconstant
xtunitroot ips fiscal, trend
xtunitroot ips fiscal
xtreg lab_inc_sh_va lab_prod price_index l_k_ratio fiscal wacr reer c.targetfactor#d_target c.pathfactor#d, fe






