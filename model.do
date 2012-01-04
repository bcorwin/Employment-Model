clear all

set more off

use C:\Users\bcorwin\Desktop\acs.dta

*Data from: http://usa.ipums.org/usa-action/variables/group

*Label for employment status
label define employment_status_lbl 0 "Not in Labor Force" 1 "Unemployed" 3 "Employed" 2 "Underemployed" 4 "Overemployed"

*Labels for Industry variables
label variable occu_manage_buis_sci_arts "Occupation - Management, business, science, and arts occupations"
label variable occu_service "Occupation - Service occupations"
label variable occu_sales_office "Occupation - Sales and office occupations"
label variable occu_natural_con_maint "Occupation - Natural resources, construction, and maintenance occupations"
label variable occu_produc_trans_matmoving "Occupation - Production, transportation, and material moving occupations"
label variable ind_11 "Industry - Agriculture, forestry, fishing and hunting, and mining"
label variable ind_23 "Industry - Construction"
label variable ind_31to33 "Industry - Manufacturing"
label variable ind_42 "Industry - Wholesale trade"
label variable ind_44to45 "Industry - Retail trade"
label variable ind_48t049_22 "Industry - Transportation and warehousing, and utilities"
label variable ind_51 "Industry - Information"
label variable ind_52_53 "Industry - Finance and insurance, and real estate and rental and leasing"
label variable ind_54_55_56 "Industry - Professional, scientific, and management, and administrative and waste management services"
label variable ind_61_62 "Industry - Educational services, and health care and social assistance"
label variable ind_71_72 "Industry - Arts, entertainment, and recreation, and accommodation and food services"
label variable ind_81 "Industry - Other services, except public administration"
label variable ind_92 "Industry - Public administration"
label variable class_private "Class Of Worker - Private wage and salary workers"
label variable class_govt "Class Of Worker - Government workers"
label variable class_self "Class Of Worker - Self-employed in own not incorporated business workers"
label variable class_unpaid "Class Of Worker - Unpaid family workers"
label variable poverty_rate "Percentage Of Families And People Whose Income In The Past 12 Months Is Below The Poverty Level - All families"

*Recoding and generating variables

**Build the model on 30% of the data
gen oos = 1
	replace oos = 0 if uniform() <= .3
	
**Eligible to vote if over 18 and US citizen
gen vote_eligible = 0
	replace vote_eligible = 1 if age >=18 & citizen != 3
	
**Age
gen age_sq = age^2

gen age_1824 = 0
	replace age_1824 = 1 if age >=18 & age < 25
gen age_2534 = 0
	replace age_2534 = 1 if age >=25 & age < 35
gen age_3544 = 0
	replace age_3544 = 1 if age >=35 & age < 45
gen age_4554 = 0
	replace age_4554 = 1 if age >=45 & age < 55
gen age_5564 = 0
	replace age_5564 = 1 if age >=55 & age < 65
gen age_6574 = 0
	replace age_6574 = 1 if age >=65 & age < 75
gen age_75plus = 0
	replace age_75plus = 1 if age >=75

gen pumaRisk_bucket = ""
	replace pumaRisk_bucket = "18-24" if age_1824 == 1
	replace pumaRisk_bucket = "25-34" if age_2534 == 1
	replace pumaRisk_bucket = "35-44" if age_3544 == 1
	replace pumaRisk_bucket = "45-54" if age_4554 == 1
	replace pumaRisk_bucket = "55-64" if age_5564 == 1
	replace pumaRisk_bucket = "65-74" if age_6574 == 1
	replace pumaRisk_bucket = "75+" if age_75plus == 1

**Gender
gen gender_female = 0
	replace gender_female = 1 if sex == 2
gen gender_male = 0
	replace gender_male = 1 if sex == 1
**Marital status
***Married includes marriage with spouse present, marriage with spouse absent, exludes missing
gen consumer_smarstat_m = 0
	replace consumer_smarstat_m = 1 if marst == 1 | marst == 2
	
***Single includes widowed, divorced, seperated, never married, exclues missing
gen consumer_smarstat_s = 0
	replace consumer_smarstat_s = 1 if marst == 3 | marst == 4 | marst == 5 | marst == 6
	
**Race - In voter file there's multiple options to name this variable (race_black_m, race_black_h, and ethnicity_black_infousa), not sure which to use so I made a new name
***Change variable later
***Also, many choices to use for determine race (racblk, racesing, and race), which should I use?
gen race_black = 0
	replace race_black = 1 if racblk == 2

**Hispanic see above
***Change variable name later
gen hispanic_general = 0
	replace hispanic_general = 1 if hispan != 0

**Fix effects by states
tab statefip, gen (state_d)

**Ln of income
gen ln_income = ln(incwage + 1)

**Employment status - 0 not in labor force, 1 is unemployed, 2 is under employed, 3 is employed, 4 is over employed
***Under employed if working <= 30 hours and looking for work
***Employed if working between 30 and 50 or less than 30 but not looking
gen employment_status = .
	replace employment_status = 0 if empstat == 3
	replace employment_status = 1 if empstat == 2
	replace employment_status = 2 if empstat == 1 & uhrswork <= 30 & looking == 2
	replace employment_status = 3 if empstat == 1 & ((uhrswork >30 & uhrswork <=50) | (uhrswork <= 30 & looking != 2))
	replace employment_status = 4 if empstat == 1 & uhrswork >50
	label values employment_status employment_status_lbl
gen employment_status_nilf = 0
	replace employment_status_nilf = 1 if employment_status == 0
gen employment_status_un = 0
	replace employment_status_un = 1 if employment_status == 1
gen employment_status_uem = 0
	replace employment_status_uem = 1 if employment_status == 2
gen employment_status_em = 0
	replace employment_status_em = 1 if employment_status == 3
gen employment_status_oem = 0
	replace employment_status_oem = 1 if employment_status == 4

**Unemployment rate buckets
gen unemployment_rate_bucket = ""
	replace unemployment_rate_bucket = "02-4" if unemployment_rate_oct11_puma >= 2 & unemployment_rate_oct11_puma < 4
	replace unemployment_rate_bucket = "04-6" if unemployment_rate_oct11_puma >= 4 & unemployment_rate_oct11_puma < 6
	replace unemployment_rate_bucket = "06-8" if unemployment_rate_oct11_puma >= 6 & unemployment_rate_oct11_puma < 8
	replace unemployment_rate_bucket = "08-10" if unemployment_rate_oct11_puma >= 8 & unemployment_rate_oct11_puma < 10
	replace unemployment_rate_bucket = "10-12" if unemployment_rate_oct11_puma >= 10 & unemployment_rate_oct11_puma < 12
	replace unemployment_rate_bucket = "12-14" if unemployment_rate_oct11_puma >= 12 & unemployment_rate_oct11_puma < 14
	replace unemployment_rate_bucket = "14-16" if unemployment_rate_oct11_puma >= 14 & unemployment_rate_oct11_puma < 16
	replace unemployment_rate_bucket = "16-18" if unemployment_rate_oct11_puma >= 16 & unemployment_rate_oct11_puma < 18
	replace unemployment_rate_bucket = "18-20" if unemployment_rate_oct11_puma >= 18 & unemployment_rate_oct11_puma < 20
	replace unemployment_rate_bucket = "20-22" if unemployment_rate_oct11_puma >= 20 & unemployment_rate_oct11_puma < 22
	replace unemployment_rate_bucket = "22-24" if unemployment_rate_oct11_puma >= 22 & unemployment_rate_oct11_puma < 24
	replace unemployment_rate_bucket = "24-26" if unemployment_rate_oct11_puma >= 24 & unemployment_rate_oct11_puma < 26
	replace unemployment_rate_bucket = "26-28" if unemployment_rate_oct11_puma >= 26 & unemployment_rate_oct11_puma < 28
	replace unemployment_rate_bucket = "28-30" if unemployment_rate_oct11_puma >= 28 & unemployment_rate_oct11_puma <= 30
tab unemployment_rate_bucket, gen (unemployment_rate_d)	
	
**Interactions
gen married_female = gender_female*consumer_smarstat_m
gen black_female = race_black*gender_female
gen hispanic_female = hispanic_general*gender_female
gen married_black = consumer_smarstat_m*race_black
gen married_hispanic = consumer_smarstat_m*hispanic_general
gen pumaForeclosure = pumaRisk*pumaHMI
gen pumaRisk_sq = pumaRisk^2
gen ind_23_puma_sq = ind_23_puma^2
gen ind_31to33_puma_sq = ind_31to33_puma^2
gen ind_31to33_puma_cu = ind_31to33_puma^3
gen ind_44to45_puma_sq = ind_44to45_puma^2

	
***Building the model using only nilf, un, and em
drop employment_status
gen employment_status = .
	replace employment_status = 0 if empstat == 3
	replace employment_status = 1 if empstat == 2
	replace employment_status = 3 if empstat == 1
	label values employment_status employment_status_lbl

drop employment_status_nilf employment_status_un employment_status_em
gen employment_status_nilf = 0
	replace employment_status_nilf = 1 if employment_status == 0
gen employment_status_un = 0
	replace employment_status_un = 1 if employment_status == 1
gen employment_status_em = 0
	replace employment_status_em = 1 if employment_status == 3
	
mlogit employment_status age_1824 age_2534 age_3544 age_5564 age_6574 age_75plus ///
	state_d1-state_d4 state_d6-state_d51 ///
	ln_income famsize gender_female consumer_smarstat_m race_black hispanic_general married_female ///
	pumaRisk pumaRisk_sq unemployment_rate_oct11_puma ///
	ind_23_puma ind_31to33_puma ///
	[aw = perwt] if vote_eligible == 1 & oos == 0

drop employment_prob_nilf employment_prob_un employment_prob_em
predict employment_prob_nilf employment_prob_un employment_prob_em, pr

drop employment_prob_nilf_dec
xtile employment_prob_nilf_dec = employment_prob_nilf if vote_eligible == 1, n(10)
//tabstat employment_prob_nilf employment_status_nilf if oos == 1, by(employment_prob_nilf_dec) statistics(mean, count)
hist employment_prob_nilf if vote_eligible == 1, bin(100) freq ///
	title(Employment Status) subtitle(Not in Labor Force)
drop employment_prob_nilf_100 employment_status_nilf_100
gen employment_status_nilf_100 = employment_status_nilf*100
gen employment_prob_nilf_100 = employment_prob_nilf*100
graph bar (mean) employment_prob_nilf_100 employment_status_nilf_100, over(employment_prob_nilf_dec) ///
	title(Employment Status) subtitle(Not in Labor Force)
	
drop employment_prob_un_dec
xtile employment_prob_un_dec = employment_prob_un if vote_eligible == 1, n(10)
//tabstat employment_prob_un employment_status_un if oos == 1, by(employment_prob_un_dec) statistics(mean, count)
hist employment_prob_un if vote_eligible == 1, bin(100) freq ///
	title(Employment Status) subtitle(Unemployed)
drop employment_prob_un_100 employment_status_un_100
gen employment_status_un_100 = employment_status_un*100
gen employment_prob_un_100 = employment_prob_un*100
graph bar (mean) employment_prob_un_100 employment_status_un_100, over(employment_prob_un_dec) ///
	title(Employment Status) subtitle(Unemployed)
	
drop employment_prob_em_dec
xtile employment_prob_em_dec = employment_prob_em if vote_eligible == 1, n(10)
//tabstat employment_prob_em employment_status_em if oos == 1, by(employment_prob_em_dec) statistics(mean, count)
hist employment_prob_em if vote_eligible == 1, bin(100) freq ///
	title(Employment Status) subtitle(Employed)
drop employment_prob_em_100 employment_status_em_100
gen employment_status_em_100 = employment_status_em*100
gen employment_prob_em_100 = employment_prob_em*100
graph bar (mean) employment_prob_em_100 employment_status_em_100, over(employment_prob_em_dec) ///
	title(Employment Status) subtitle(Employed)
	
*Making buckets for tables
gen pumaRisk_bucket = ""
	replace pumaRisk_bucket = "0-10" if pumaRisk >= 0 & pumaRisk < 10
	replace pumaRisk_bucket = "10-20" if pumaRisk >= 10 & pumaRisk < 20
	replace pumaRisk_bucket = "20-30" if pumaRisk >= 20 & pumaRisk < 30
	replace pumaRisk_bucket = "30-40" if pumaRisk >= 30 & pumaRisk < 40
	replace pumaRisk_bucket = "40-50" if pumaRisk >= 40 & pumaRisk < 50
	replace pumaRisk_bucket = "50-60" if pumaRisk >= 50 & pumaRisk < 60
	replace pumaRisk_bucket = "60-70" if pumaRisk >= 60 & pumaRisk < 70
	replace pumaRisk_bucket = "70-80" if pumaRisk >= 70 & pumaRisk < 80
	replace pumaRisk_bucket = "80-90" if pumaRisk >= 80 & pumaRisk < 90
	replace pumaRisk_bucket = "90-100" if pumaRisk >= 90 & pumaRisk <= 100
	
gen pumaHMI_bucket = ""
	replace pumaHMI_bucket = "-2.6 to -2.08" if pumaHMI >= -2.6 & pumaHMI < -2.08
	replace pumaHMI_bucket = "-2.08 to -1.56" if pumaHMI >= -2.08 & pumaHMI < -1.56
	replace pumaHMI_bucket = "-1.56 to -1.04" if pumaHMI >= -1.56 & pumaHMI < -1.04
	replace pumaHMI_bucket = "-1.04 to -.52" if pumaHMI >= -1.04 & pumaHMI < -.52
	replace pumaHMI_bucket = "-.52 to 0" if pumaHMI >= -.52 & pumaHMI < 0
	replace pumaHMI_bucket = "0 to .52" if pumaHMI >= 0 & pumaHMI < .52
	replace pumaHMI_bucket = ".52 to 1.04" if pumaHMI >= .52 & pumaHMI < 1.04
	replace pumaHMI_bucket = "1.04 to 1.56" if pumaHMI >= 1.04 & pumaHMI < 1.56
	replace pumaHMI_bucket = "1.56 to 2.08" if pumaHMI >= 1.56 & pumaHMI < 2.08
	replace pumaHMI_bucket = "2.08 to 2.6" if pumaHMI >= 2.08 & pumaHMI < 2.6
	
gen ind_23_bucket = ""
	replace ind_23_bucket = "0-4" if ind_23_puma >= 0 & ind_23_puma < 4
	replace ind_23_bucket = "04-8" if ind_23_puma >= 4 & ind_23_puma < 8
	replace ind_23_bucket = "08-12" if ind_23_puma >= 8 & ind_23_puma < 12
	replace ind_23_bucket = "12-16" if ind_23_puma >= 12 & ind_23_puma < 16
	replace ind_23_bucket = "16-20" if ind_23_puma >= 16 & ind_23_puma <= 20
	
gen ind_31to33_bucket = ""
	replace ind_31to33_bucket = "0-5" if ind_31to33_puma >= 0 & ind_31to33_puma < 5
	replace ind_31to33_bucket = "05-10" if ind_31to33_puma >= 5 & ind_31to33_puma < 10
	replace ind_31to33_bucket = "10-15" if ind_31to33_puma >= 10 & ind_31to33_puma < 15
	replace ind_31to33_bucket = "15-20" if ind_31to33_puma >= 15 & ind_31to33_puma < 20
	replace ind_31to33_bucket = "20-25" if ind_31to33_puma >= 20 & ind_31to33_puma < 25
	replace ind_31to33_bucket = "25-30" if ind_31to33_puma >= 25 & ind_31to33_puma < 30
	replace ind_31to33_bucket = "30-35" if ind_31to33_puma >= 30 & ind_31to33_puma < 35
	replace ind_31to33_bucket = "35-40" if ind_31to33_puma >= 35 & ind_31to33_puma <= 40

gen ind_44to45_bucket = ""
	replace ind_44to45_bucket = "04-8" if ind_44to45_puma >= 4 & ind_44to45_puma < 8
	replace ind_44to45_bucket = "08-12" if ind_44to45_puma >= 8 & ind_44to45_puma < 12
	replace ind_44to45_bucket = "12-16" if ind_44to45_puma >= 12 & ind_44to45_puma < 16
	replace ind_44to45_bucket = "16-20" if ind_44to45_puma >= 16 & ind_44to45_puma < 20
	replace ind_44to45_bucket = "20-24" if ind_44to45_puma >= 20 & ind_44to45_puma <= 24
	
*Making Validation Graphs
ta statefip if vote_eligible == 1, summarize(employment_prob_nilf) nosta
ta statefip if vote_eligible == 1, summarize(employment_status_nilf) nosta
ta statefip if vote_eligible == 1, summarize(employment_prob_un) nosta
ta statefip if vote_eligible == 1, summarize(employment_status_un) nosta
ta statefip if vote_eligible == 1, summarize(employment_prob_em) nosta
ta statefip if vote_eligible == 1, summarize(employment_status_em) nosta

ta gender_female consumer_smarstat_m if vote_eligible == 1, summarize(employment_status_em) nosta nomean
ta gender_female consumer_smarstat_m if vote_eligible == 1, summarize(employment_prob_nilf) nosta nofreq
ta gender_female consumer_smarstat_m if vote_eligible == 1, summarize(employment_status_nilf) nosta nofreq
ta gender_female consumer_smarstat_m if vote_eligible == 1, summarize(employment_prob_un) nosta nofreq
ta gender_female consumer_smarstat_m if vote_eligible == 1, summarize(employment_status_un) nosta nofreq
ta gender_female consumer_smarstat_m if vote_eligible == 1, summarize(employment_prob_em) nosta nofreq
ta gender_female consumer_smarstat_m if vote_eligible == 1, summarize(employment_status_em) nosta nofreq

ta pumaRisk_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nomeans
ta pumaRisk_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nofreq
ta pumaRisk_bucket if vote_eligible == 1, summarize(employment_status_nilf) nosta nofreq
ta pumaRisk_bucket if vote_eligible == 1, summarize(employment_prob_un) nosta nofreq
ta pumaRisk_bucket if vote_eligible == 1, summarize(employment_status_un) nosta nofreq
ta pumaRisk_bucket if vote_eligible == 1, summarize(employment_prob_em) nosta nofreq
ta pumaRisk_bucket if vote_eligible == 1, summarize(employment_status_em) nosta nofreq

ta unemployment_rate_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nomeans
ta unemployment_rate_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nofreq
ta unemployment_rate_bucket if vote_eligible == 1, summarize(employment_status_nilf) nosta nofreq
ta unemployment_rate_bucket if vote_eligible == 1, summarize(employment_prob_un) nosta nofreq
ta unemployment_rate_bucket if vote_eligible == 1, summarize(employment_status_un) nosta nofreq
ta unemployment_rate_bucket if vote_eligible == 1, summarize(employment_prob_em) nosta nofreq
ta unemployment_rate_bucket if vote_eligible == 1, summarize(employment_status_em) nosta nofreq

ta ind_23_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nomeans
ta ind_23_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nofreq
ta ind_23_bucket if vote_eligible == 1, summarize(employment_status_nilf) nosta nofreq
ta ind_23_bucket if vote_eligible == 1, summarize(employment_prob_un) nosta nofreq
ta ind_23_bucket if vote_eligible == 1, summarize(employment_status_un) nosta nofreq
ta ind_23_bucket if vote_eligible == 1, summarize(employment_prob_em) nosta nofreq
ta ind_23_bucket if vote_eligible == 1, summarize(employment_status_em) nosta nofreq

ta ind_31to33_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nomeans
ta ind_31to33_bucket if vote_eligible == 1, summarize(employment_prob_nilf) nosta nofreq
ta ind_31to33_bucket if vote_eligible == 1, summarize(employment_status_nilf) nosta nofreq
ta ind_31to33_bucket if vote_eligible == 1, summarize(employment_prob_un) nosta nofreq
ta ind_31to33_bucket if vote_eligible == 1, summarize(employment_status_un) nosta nofreq
ta ind_31to33_bucket if vote_eligible == 1, summarize(employment_prob_em) nosta nofreq
ta ind_31to33_bucket if vote_eligible == 1, summarize(employment_status_em) nosta nofreq

*Old Model and verification
set matsize 500

mlogit employment_status age_1824 age_2534 age_3544 age_5564 age_6574 age_75plus ///
	state_d1-state_d4 state_d6-state_d51 ///
	ln_income famsize gender_female consumer_smarstat_m race_black hispanic_general married_female married_black ///
	pumaHMI pumaRisk unemployment_rate_oct11_puma ///
	occu_service_puma occu_natural_con_maint_puma ///
	ind_23_puma ind_31to33_puma ind_44to45_puma ///
	[aw = perwt] if vote_eligible == 1 & oos == 0

drop employment_prob_nilf employment_prob_un employment_prob_uem employment_prob_em employment_prob_oem
predict employment_prob_nilf employment_prob_un employment_prob_uem employment_prob_em employment_prob_oem, pr

drop employment_prob_nilf_dec
xtile employment_prob_nilf_dec = employment_prob_nilf if vote_eligible == 1, n(10)
//tabstat employment_prob_nilf employment_status_nilf if oos == 1, by(employment_prob_nilf_dec) statistics(mean, count)
//hist employment_prob_nilf if vote_eligible == 1, bin(100) freq ///
//	title(Employment Status) subtitle(Not in Labor Force)
drop employment_prob_nilf_100 employment_status_nilf_100
gen employment_status_nilf_100 = employment_status_nilf*100
gen employment_prob_nilf_100 = employment_prob_nilf*100
graph bar (mean) employment_prob_nilf_100 (mean) employment_status_nilf_100, over(employment_prob_nilf_dec) ///
	title(Employment Status) subtitle(Not in Labor Force)
	
drop employment_prob_un_dec
xtile employment_prob_un_dec = employment_prob_un if vote_eligible == 1, n(10)
//tabstat employment_prob_un employment_status_un if oos == 1, by(employment_prob_un_dec) statistics(mean, count)
//hist employment_prob_un if vote_eligible == 1, bin(100) freq ///
//	title(Employment Status) subtitle(Unemployed)
drop employment_prob_un_100 employment_status_un_100
gen employment_status_un_100 = employment_status_un*100
gen employment_prob_un_100 = employment_prob_un*100
graph bar (mean) employment_prob_un_100 (mean) employment_status_un_100, over(employment_prob_un_dec) ///
	title(Employment Status) subtitle(Unemployed)
	
drop employment_prob_uem_dec
xtile employment_prob_uem_dec = employment_prob_uem if vote_eligible == 1, n(10)
//tabstat employment_prob_uem employment_status_uem if oos == 1, by(employment_prob_uem_dec) statistics(mean, count)
//hist employment_prob_uem if vote_eligible == 1, bin(100) freq ///
//	title(Employment Status) subtitle(Underemployed)
drop employment_prob_uem_100 employment_status_uem_100
gen employment_status_uem_100 = employment_status_uem*100
gen employment_prob_uem_100 = employment_prob_uem*100
graph bar (mean) employment_prob_uem_100 (mean) employment_status_uem_100, over(employment_prob_uem_dec) ///
	title(Employment Status) subtitle(Underemployed)
	
drop employment_prob_em_dec
xtile employment_prob_em_dec = employment_prob_em if vote_eligible == 1, n(10)
//tabstat employment_prob_em employment_status_em if oos == 1, by(employment_prob_em_dec) statistics(mean, count)
//hist employment_prob_em if vote_eligible == 1, bin(100) freq ///
//	title(Employment Status) subtitle(Employed)
drop employment_prob_em_100 employment_status_em_100
gen employment_status_em_100 = employment_status_em*100
gen employment_prob_em_100 = employment_prob_em*100
graph bar (mean) employment_prob_em_100 (mean) employment_status_em_100, over(employment_prob_em_dec) ///
	title(Employment Status) subtitle(Employed)
	
drop employment_prob_oem_dec
xtile employment_prob_oem_dec = employment_prob_oem if vote_eligible == 1, n(10)
//tabstat employment_prob_oem employment_status_oem if oos == 1, by(employment_prob_oem_dec) statistics(mean, count)
//hist employment_prob_oem if vote_eligible == 1, bin(100) freq ///
//	title(Employment Status) subtitle(Over Employed)
drop employment_prob_oem_100 employment_status_oem_100
gen employment_status_oem_100 = employment_status_oem*100
gen employment_prob_oem_100 = employment_prob_oem*100
graph bar (mean) employment_prob_oem_100 (mean) employment_status_oem_100, over(employment_prob_oem_dec) ///
	title(Employment Status) subtitle(Over Employed)
	
*Me messing around
drop test_split
xtile test_split = employment_prob_nilf if vote_eligible == 1, n(100)
drop employment_prob_nilf_100 employment_status_nilf_100
gen employment_status_nilf_100 = employment_status_nilf*100
gen employment_prob_nilf_100 = employment_prob_nilf*100
graph bar (mean) employment_prob_nilf_100 (mean) employment_status_nilf_100, over(test_split) ///
	title(Employment Status) subtitle(Employed)
	