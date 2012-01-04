clear all

use usa_00002.dta

gen statefips = string(statefip, "%02.0f")
gen temp = string(puma, "%005.0f")
drop puma
gen puma = statefips + temp
drop temp statefips

merge m:1 puma using HMI_RiskScore_byPUMA.dta


//Don't have data for all the PUMAs, means plugging by state
egen temp = mean(pumaHMI), by(statefip)
replace pumaHMI = temp if pumaHMI == .
drop temp
egen temp = mean(pumaRisk), by (statefip)
replace pumaRisk = temp if pumaRisk == .
drop temp

drop if _merge == 2

//drop variables that we don't need or have in the voter files
drop metro metarea metaread city citypop gq famunit speakeng hispand occ ind _merge

save acsWithScores.dta, replace
