clear all

use industry.dta

**Some counties don't match up on the conversion file. After researching it, the following county number changes need to be made
***Prince of Wales - Outer Ketchikan Census Area, AK is the title in the conversion file
***Here it's split into two counties, Petersburg Census Area, AK and Wrangell Borough/city, AK (needs to be changed after merge)
replace county = "02280" if county == "02195"
replace county = "02201" if county == "02198"

merge 1:m county using county_to_puma.dta

***When adding afact for 0200400, it's off by .001, the row known as Wrangell Borough/city, AK thus is likely apart of that PUMA and with that afact value
replace afact = .001 if county == "02275"
replace afact2 = 1 if county == "02275"
replace puma = "0200400" if county == "02275"

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
gen occu_manage_buis_sci_arts_ad = afact*occu_manage_buis_sci_arts
gen occu_service_ad = afact*occu_service
gen occu_sales_office_ad = afact*occu_sales_office
gen occu_natural_con_maint_ad = afact*occu_natural_con_maint
gen occu_produc_trans_matmoving_ad = afact*occu_produc_trans_matmoving
gen ind_11_ad = afact*ind_11
gen ind_23_ad = afact*ind_23
gen ind_31to33_ad = afact*ind_31to33
gen ind_42_ad = afact*ind_42
gen ind_44to45_ad = afact*ind_44to45
gen ind_48t049_22_ad = afact*ind_48t049_22
gen ind_51_ad = afact*ind_51
gen ind_52_53_ad = afact*ind_52_53
gen ind_54_55_56_ad = afact*ind_54_55_56
gen ind_61_62_ad = afact*ind_61_62
gen ind_71_72_ad = afact*ind_71_72
gen ind_81_ad = afact*ind_81
gen ind_92_ad = afact*ind_92
gen class_private_ad = afact*class_private
gen class_govt_ad = afact*class_govt
gen class_self_ad = afact*class_self
gen class_unpaid_ad = afact*class_unpaid
gen poverty_rate_ad = afact*poverty_rate 
	
**Find total of the ad amounts by puma
egen occu_manage_buis_sci_arts_puma = total(occu_manage_buis_sci_arts_ad), by(puma)
egen occu_service_puma = total(occu_service_ad), by(puma)
egen occu_sales_office_puma = total(occu_sales_office_ad), by(puma)
egen occu_natural_con_maint_puma = total(occu_natural_con_maint_ad), by(puma)
egen occu_produc_trans_matmoving_puma = total(occu_produc_trans_matmoving_ad), by(puma)
egen ind_11_puma = total(ind_11_ad), by(puma)
egen ind_23_puma = total(ind_23_ad), by(puma)
egen ind_31to33_puma = total(ind_31to33_ad), by(puma)
egen ind_42_puma = total(ind_42_ad), by(puma)
egen ind_44to45_puma = total(ind_44to45_ad), by(puma)
egen ind_48t049_22_puma = total(ind_48t049_22_ad), by(puma)
egen ind_51_puma = total(ind_51_ad), by(puma)
egen ind_52_53_puma = total(ind_52_53_ad), by(puma)
egen ind_54_55_56_puma = total(ind_54_55_56_ad), by(puma)
egen ind_61_62_puma = total(ind_61_62_ad), by(puma)
egen ind_71_72_puma = total(ind_71_72_ad), by(puma)
egen ind_81_puma = total(ind_81_ad), by(puma)
egen ind_92_puma = total(ind_92_ad), by(puma)
egen class_private_puma = total(class_private_ad), by(puma)
egen class_govt_puma = total(class_govt_ad), by(puma)
egen class_self_puma = total(class_self_ad), by(puma)
egen class_unpaid_puma = total(class_unpaid_ad), by(puma)
egen poverty_rate_puma = total(poverty_rate_ad), by(puma)

**Not needed anymore
drop occu_manage_buis_sci_arts occu_service occu_sales_office ///
	occu_natural_con_maint occu_produc_trans_matmoving ind_11 ind_23 ///
	ind_31to33 ind_42 ind_44to45 ind_48t049_22 ind_51 ind_52_53 ind_54_55_56 ///
	ind_61_62 ind_71_72 ind_81 ind_92 class_private class_govt class_self ///
	class_unpaid poverty_rate afact afact2 _merge occu_manage_buis_sci_arts_ad ///
	occu_service_ad occu_sales_office_ad occu_natural_con_maint_ad ///
	occu_produc_trans_matmoving_ad ind_11_ad ind_23_ad ind_31to33_ad ind_42_ad ///
	ind_44to45_ad ind_48t049_22_ad ind_51_ad ind_52_53_ad ind_54_55_56_ad ind_61_62_ad ///
	ind_71_72_ad ind_81_ad ind_92_ad class_private_ad class_govt_ad class_self_ad class_unpaid_ad poverty_rate_ad
	
rename county state_county_code

duplicates drop puma, force
	
save industry_puma.dta, replace

**Attach the above data to the acs.dta

clear all

use "\\Data\HomeShare$\bcorwin\Documents\OFA Projects\Employment Model\acs.dta"

drop _merge state_county_code county_name_state

merge m:1 puma using "\\Data\HomeShare$\bcorwin\Documents\OFA Projects\Employment Model\Industry\industry_puma.dta"

save acs.dta, replace


