use "\\Data\HomeShare$\bcorwin\Documents\OFA Projects\Employment Model\cpsSept11.dta"
//-1 is used for missing
//Uses the voter file names when they exist

*Recoding and Generating variables

**Build the model on 70% of the data
gen oos = 0
	replace oos = 1 if uniform() <= .3

**Eligible to vote - excludes people under 18, non-citizens, and un-known citizenship
gen vote_eligible = 0
	replace vote_eligible = 1 if peage >= 18 & prcitshp != 5 & prcitshp != -1
	
**Marital status - married includes marriage with spouse present, marriage with spouse absent, exludes missing
gen consumer_smarstat_m = 0
	replace consumer_smarstat_m = 1 if pemaritl == 1 | pemaritl == 2
	
***Single includes widowed, divorced, seperated, never married, exclues missing
gen consumer_smarstat_s = 0
	replace consumer_smarstat_s = 1 if pemaritl == 3 | pemaritl == 4 | pemaritl == 5 | pemaritl == 6
	
**Race - how to do this? In voter file, based on percentages, hispanic data too
**Income - no data for people in voter file (median income for census tracts i think?)
**Industry type information

**Employment status - 1 is employed, 2 is unemployed, 3 is not in labor force
***How to determine Over and Under Employed
gen employment_status = .
	replace employment_status = 1 if pemlr == 1 | pemlr == 2
	replace employment_status = 2 if pemlr == 3 | pemlr == 4
	replace employment_status = 3 if pemlr == 5 | pemlr == 6 | pemlr == 7

