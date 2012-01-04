clear all

use usa_00002.dta

gen temp = string(puma,"%05.0f")
drop puma
gen puma = temp
drop temp

merge m:1 puma using HMDAwithPUMA.dta
