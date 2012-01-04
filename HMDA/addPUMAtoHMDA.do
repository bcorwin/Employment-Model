//Adding PUMA information
use "\\Data\HomeShare$\bcorwin\Documents\OFA Projects\Employment Model\HMDA.dta"

gen censustract = string(censustractidentifier,"%011.0f")

merge m:1 censustract using "\\Data\HomeShare$\bcorwin\Documents\OFA Projects\PUMA Conversion\PUMAconversion.dta"

drop if censustractidentifier == .
drop pop2k afact afact2

save HMDAwithPUMA.dta
