clear all

insheet using 2010avg.csv, comma names

**Some counties don't match up on the conversion file. After researching it, the following county number changes need to be made
***Prince of Wales - Outer Ketchikan Census Area, AK is the title in the conversion file
***Here it's called Prince of Wales-Hyder Census Area, AK so they county number needs to change
replace countyfips = 201 if countyfips == 198 & statefips == 2

***Conversion File: Wrangell - Petersburg Census Area, AK
***Here it's split into two counties, Petersburg Census Area, AK and Wrangell Borough/city, AK (needs to be changed after merge)
replace countyfips = 280 if countyfips == 195 & statefips == 2

tostring statefips, replace format("%02.0f")
tostring countyfips, replace format("%03.0f")
gen county = statefips + countyfips

merge 1:m county using county_to_puma.dta

***When adding afact for 0200400, it's off by .001, the row known as Wrangell Borough/city, AK thus is likely apart of that PUMA and with that afact value
replace afact = .001 if statefips == "02" & countyfips == "275"
replace afact2 = 1 if statefips == "02" & countyfips == "275"
replace puma = "0200400" if statefips == "02" & countyfips == "275"
replace _merge = 3 if statefips == "02" & countyfips == "275"

**Missing a county in HI
***Replace values with average from the PUMA
replace statefips = "15" if county == "15005"
replace countyfips = "005" if county == "15005"
replace count_state_name = "Kalawao County, HI" if county == "15005"

egen temp = mean(unemployment_rate_2010), by(puma)
	replace unemployment_rate_2010 = temp if county == "15005"
	drop temp

**Katrina speed bump, Ana gave me these numbers/code
replace puma = "2277777" if puma == "2201801"
replace puma = "2277777" if puma == "2201802"
replace puma = "2277777" if puma == "2201905"

/*I don't have pop2k
replace afact = .207 if puma == "2277777" & pop2k == 67,229
replace afact = .083 if puma == "2277777" & pop2k == 26,757
replace afact = .02 if puma == "2277777" & pop2k == 6,587
replace afact = .332 if puma == "2277777" & pop2k == 107,802
replace afact = .357 if puma == "2277777" & pop2k == 115,878

Got these from factfinder:
		Jefferson Parish Orleans Parish Plaquemines Parish St. Bernard Parish
Total            455,466	    484,674	            26,757	           67,229

Added this:
afact 				  .44		   .469				  .026				 .065
Found by dividing the population by the total*/

**County 22071 is repeated, drop one
duplicates drop puma county, force

replace afact = .44 if county == "22051"
replace afact = .469 if county == "22071"
replace afact = .026 if county == "22075"
replace afact = .065 if county == "22087"
	
**Find adjusted amounts for each variable
gen unemployment_rate_2010_ad = afact*unemployment_rate_2010
	
**Find total of the ad amounts by puma
egen unemployment_rate_2010_puma = total(unemployment_rate_2010_ad), by(puma)

**Not needed anymore
drop _merge statefips countyfips count_state_name unemployment_rate_2010 county afact afact2 _merge unemployment_rate_2010_ad

duplicates drop puma, force
	
save 2010avg.dta, replace

**Attach the above data to the acs.dta

clear all

use "\\Data\HomeShare$\bcorwin\Documents\OFA Projects\Employment Model\acs.dta"

merge m:1 puma using 2010avg.dta

drop if _merge == 2

drop _merge

save acs.dta, replace


