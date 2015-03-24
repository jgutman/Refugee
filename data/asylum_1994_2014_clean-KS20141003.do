/*
*******************************************************************************************************
Cleaned asylum judge files for test of gambler's fallacy

10/06/14 -KS

do "/Volumes/RAID/Dropbox/hothand/programs/asylum_1994_2014_clean-KS20141003.do"
do "I:/Dropbox/hothand/programs/asylum_1994_2014_clean-KS20141003.do"

******************************************************************************************************
*/

clear
clear matrix
clear mata
set maxvar 32767
set matsize 11000
set more off

*global pathDropbox = "/Volumes/Untitled/Dropbox/"
*global pathDropbox = "I:/Dropbox/"
*global path_tblschedule = "${pathDropbox}holger_erica_dlchen/Data/Asylum_and_IJs/tbl_schedule/tbl_schedule_complete.dta"

global pathDropbox = "/Volumes/RAID/Dropbox/"
global path_tblschedule = "${pathDropbox}large_files/tbl_schedule_complete.dta"
global path_rawdata = "${pathDropbox}hothand/TRAC/data/raw/"
global path_cleandata = "${pathDropbox}hothand/TRAC/data/clean/"
global log_dir = "${pathDropbox}hothand/logs/"

capture log close
log using ${log_dir}asylum_1994_2014_clean-KS20141003.smcl, replace



/*
*****************************************************************************************************
* Processing Sue's label files that will be merged into other files
*****************************************************************************************************

insheet using "${path_rawdata}master_case_type.csv", c double names clear
rename strcode case_type
rename strdescription case_type_string
replace case_type_string = trim(itrim(upper(case_type_string)))
replace case_type=trim(itrim(upper(case_type)))
duplicates tag case_type, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_case_type.dta", replace



*following Daniel's code, import the same file twice and save under different datasets
*we need to figure out why, but for now, these variables aren't used for anything
insheet using "${path_rawdata}master_decision_on_proceeding.csv", c double names clear
rename strcasetype case_type
rename strdeccode dec_code
rename strdectype outcome_recorded_in_field
rename strdecdescription dec_string
replace dec_string = trim(itrim(upper(dec_string)))
replace case_type=trim(itrim(upper(case_type)))
replace dec_code=trim(itrim(upper(dec_code)))
replace outcome_recorded_in_field=trim(itrim(upper(outcome_recorded_in_field)))
*drop annotation (1 obs) which is just text description
	drop if case_type=="TRAC ANNOTATION:"
drop v5 v6 v7
duplicates tag case_type dec_code outcome_recorded_in_field, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_decision_on_proceeding_dec.dta", replace



insheet using "${path_rawdata}master_decision_on_proceeding.csv", c double names clear
rename strcasetype case_type
rename strdeccode other_comp
rename strdectype outcome_recorded_in_field
rename strdecdescription dec_string
replace dec_string = trim(itrim(upper(dec_string)))
replace case_type=trim(itrim(upper(case_type)))
replace other_comp=trim(itrim(upper(other_comp)))
replace outcome_recorded_in_field=trim(itrim(upper(outcome_recorded_in_field)))
*drop annotation (1 obs) which is just text description
	drop if case_type=="TRAC ANNOTATION:"
drop v5 v6 v7
duplicates tag case_type other_comp outcome_recorded_in_field, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_decision_on_proceeding_oth.dta", replace



insheet using "${path_rawdata}master_decision_type.csv", c double names clear
rename strcode dec_type
rename strdescription dec_type_string
replace dec_type_string = trim(itrim(upper(dec_type_string)))
replace dec_type=trim(itrim(upper(dec_type)))
duplicates tag dec_type, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_decision_type.dta", replace



insheet using "${path_rawdata}master_application_type.csv", c double nonames clear
rename v1 appl_code
rename v2 application_type_string
drop if appl_code == ""
replace appl_code=trim(itrim(upper(appl_code)))
replace application_type_string = trim(itrim(upper(application_type_string)))
drop if appl_code=="????" | strpos(appl_code,"2007 FILE")!=0 | strpos(appl_code,"CURRENT LOOKUP")!=0 |  appl_code=="STRCODE"
drop if application_type_string=="UNKNOWN"
duplicates drop
duplicates tag appl_code, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}application_codes.dta", replace



insheet using "${path_rawdata}master_decision_on_application.csv", c double names clear
rename code appl_dec
rename description application_dec_string
replace application_dec_string = trim(itrim(upper(application_dec_string)))
replace appl_dec=trim(itrim(upper(appl_dec)))
duplicates tag appl_dec, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}application_dec.dta", replace



insheet using "${path_rawdata}tblLookupNationality.csv", c double nonames clear
rename v2 nat
rename v3 nat_string
keep nat nat_string
replace nat_string = trim(itrim(upper(nat_string)))
drop if nat=="??"
replace nat=trim(itrim(upper(nat)))
duplicates tag nat, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_nationality.dta", replace



insheet using "${path_rawdata}tblLookupBaseCity.csv", c double nonames clear
rename v2 base_city_code
rename v5 base_city_street
rename v6 base_city_string
rename v7 base_city_state
rename v8 base_city_zip5
rename v9 base_city_zip4
rename v10 base_city_phone
foreach var of varlist base_city_code base_city_street base_city_string base_city_state {
  replace `var' = trim(itrim(upper(`var')))
}
keep base_city*
duplicates tag base_city_code, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_base_city.dta", replace



insheet using "${path_rawdata}tblLookupHloc.csv", c double nonames clear
rename v2 hearing_loc_code
rename v3 hearing_loc_string1
rename v4 hearing_loc_string2
rename v5 hearing_loc_street
rename v6 hearing_loc_city
rename v7 hearing_loc_state
*Note: some are not zip5
	rename v8 hearing_loc_zip5 
rename v9 hearing_loc_phone
foreach var of varlist hearing_loc_code hearing_loc_street hearing_loc_string1 hearing_loc_string2  hearing_loc_street  hearing_loc_city  hearing_loc_state {
  replace `var' = trim(itrim(upper(`var')))
}
keep hearing*
duplicates tag hearing_loc_code, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_hearing_loc.dta", replace



insheet using "${path_rawdata}ijcodemap.csv", c double names clear
rename eoirid ij_code
rename eoirdata judge_name
replace judge_name = trim(itrim(upper(judge_name)))
replace ij_code=trim(itrim(upper(ij_code)))
duplicates drop
*fix codes that actually refer to same judge
	duplicates report tracid
	replace ij_code="DA" if ij_code=="VDA"
	replace ij_code="LOB" if ij_code=="LRB"
	replace ij_code="RAJ" if ij_code=="MVJ"
	replace ij_code="MHB" if ij_code=="MH7"
	replace ij_code="DLM" if ij_code=="DMK"
	replace ij_code="PLJ" if ij_code=="PJ"
	replace ij_code="JEB" if ij_code=="J8B"
	replace ij_code="ABM" if ij_code=="ABT"
	replace ij_code="JAD" if ij_code=="VJO"
	replace ij_code="KCW" if ij_code=="VJM"
	replace ij_code="MT" if ij_code=="VJE"
	replace ij_code="SJL" if ij_code=="SDL"
	replace ij_code="CMR" if ij_code=="VHJ"
	replace ij_code="JVC" if ij_code=="VJA"
	replace ij_code="JLB" if ij_code=="VJB"
	replace ij_code="HVW" if ij_code=="VJH"
	replace ij_code="PSL" if ij_code=="VPL"
	replace ij_code="SY" if ij_code=="VSY"
	replace ij_code="WKZ" if ij_code=="VWZ"
	replace ij_code="EWB" if ij_code=="EBW"
	replace judge_name="PAUL L. JOHNSTON" if judge_name=="PAUL L JOHNSTON"
	replace judge_name="ALISON M. BROWN" if judge_name=="ALISON M. BROWN (TEMP)"
	replace judge_name="DAVID AYALA" if judge_name=="DAVID AYALA (VISITING JUDGE)"
	replace judge_name="LAWRENCE O. BURMAN" if judge_name=="LAWRENCE R. BURMAN"
	replace judge_name="CLAREASE RANKIN YATES" if judge_name=="CLAREASE RANKIN YATES (VISITING JUDGE)"
	replace judge_name="JOAN V. CHURCHILL" if judge_name=="JOAN V. CHURCHILL (VISITING JUDGE)"
	replace judge_name="JIMMIE LEE BENTON" if judge_name=="JIMMIE LEE BENTON (VISITING JUDGE)"
	replace judge_name="HOWARD VAN WINKLE" if judge_name=="HOWARD VAN WINKLE (VISITING JUDGE)"
	replace judge_name="PHILIP S. LAW" if judge_name=="PHILIP S. LAW (VISITING JUDGE)"
	replace judge_name="SUSAN YARBROUGH" if judge_name=="SUSAN YARBROUGH (VISITING JUDGE)"
	replace judge_name="WILLIAM K. ZIMMER" if judge_name=="WILLIAM K. ZIMMER (VISITING JUDGE)"	
	drop if strpos(judge_name,"IJ")>0
	drop if judge_name=="LIVE JUDGE - BAL"
	drop if strpos(judge_name,"MASTER CALENDAR")>0
	drop if strpos(judge_name,"VISITING JUDGE")>0
	drop if judge_name=="FORMER IMMIGRATION JUDGE"
	drop if strpos(judge_name,"VIDEO")>0	
	duplicates drop
duplicates tag tracid, gen(dup)
assert dup==0
drop dup
duplicates tag ij_code, gen(dup)
assert dup==0
drop dup
duplicates tag judge_name, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_tracid.dta", replace



insheet using "${path_rawdata}ijcodemap.csv", c double names clear
rename eoirid ij_code
rename eoirdata judge_name
replace judge_name = trim(itrim(upper(judge_name)))
replace ij_code=trim(itrim(upper(ij_code)))
duplicates drop
*fix codes that actually refer to same judge
	duplicates report tracid
	replace ij_code="DA" if ij_code=="VDA"
	replace ij_code="LOB" if ij_code=="LRB"
	replace ij_code="RAJ" if ij_code=="MVJ"
	replace ij_code="MHB" if ij_code=="MH7"
	replace ij_code="DLM" if ij_code=="DMK"
	replace ij_code="PLJ" if ij_code=="PJ"
	replace ij_code="JEB" if ij_code=="J8B"
	replace ij_code="ABM" if ij_code=="ABT"
	replace ij_code="JAD" if ij_code=="VJO"
	replace ij_code="KCW" if ij_code=="VJM"
	replace ij_code="MT" if ij_code=="VJE"f
	replace ij_code="SJL" if ij_code=="SDL"
	replace ij_code="CMR" if ij_code=="VHJ"
	replace ij_code="JVC" if ij_code=="VJA"
	replace ij_code="JLB" if ij_code=="VJB"
	replace ij_code="HVW" if ij_code=="VJH"
	replace ij_code="PSL" if ij_code=="VPL"
	replace ij_code="SY" if ij_code=="VSY"
	replace ij_code="WKZ" if ij_code=="VWZ"
	replace ij_code="EWB" if ij_code=="EBW"
	replace judge_name="PAUL L. JOHNSTON" if judge_name=="PAUL L JOHNSTON"
	replace judge_name="ALISON M. BROWN" if judge_name=="ALISON M. BROWN (TEMP)"
	replace judge_name="DAVID AYALA" if judge_name=="DAVID AYALA (VISITING JUDGE)"
	replace judge_name="LAWRENCE O. BURMAN" if judge_name=="LAWRENCE R. BURMAN"
	replace judge_name="CLAREASE RANKIN YATES" if judge_name=="CLAREASE RANKIN YATES (VISITING JUDGE)"
	replace judge_name="JOAN V. CHURCHILL" if judge_name=="JOAN V. CHURCHILL (VISITING JUDGE)"
	replace judge_name="JIMMIE LEE BENTON" if judge_name=="JIMMIE LEE BENTON (VISITING JUDGE)"
	replace judge_name="HOWARD VAN WINKLE" if judge_name=="HOWARD VAN WINKLE (VISITING JUDGE)"
	replace judge_name="PHILIP S. LAW" if judge_name=="PHILIP S. LAW (VISITING JUDGE)"
	replace judge_name="SUSAN YARBROUGH" if judge_name=="SUSAN YARBROUGH (VISITING JUDGE)"
	replace judge_name="WILLIAM K. ZIMMER" if judge_name=="WILLIAM K. ZIMMER (VISITING JUDGE)"
	drop if strpos(judge_name,"IJ")>0
	drop if judge_name=="LIVE JUDGE - BAL"
	drop if strpos(judge_name,"MASTER CALENDAR")>0
	drop if strpos(judge_name,"VISITING JUDGE")>0
	drop if judge_name=="FORMER IMMIGRATION JUDGE"
	drop if strpos(judge_name,"VIDEO")>0	
duplicates drop
duplicates tag tracid, gen(dup)
assert dup==0
drop dup
duplicates tag ij_code, gen(dup)
assert dup==0
drop dup
duplicates tag judge_name, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_ij_code.dta", replace



*Note: this lookup judge table is more comprehensive than the ijcode table
*all judges in master_ij_code are also present in master_lookup_ij_code and have the same ij_code
insheet using "${path_rawdata}tblLookupJudge.csv", c double nonames clear
rename v2 ij_code
rename v3 judge_name_caps
keep ij_code judge_name_caps
replace judge_name_caps = trim(itrim(upper(judge_name_caps)))
replace ij_code=trim(itrim(upper(ij_code)))
*fix codes that actually refer to same judge
duplicates report judge_name_caps
	replace ij_code="DA" if ij_code=="VDA"
	replace ij_code="LOB" if ij_code=="LRB"
	replace ij_code="RAJ" if ij_code=="MVJ"
	replace ij_code="MHB" if ij_code=="MH7"
	replace ij_code="DLM" if ij_code=="DMK"
	replace ij_code="PLJ" if ij_code=="PJ"
	replace ij_code="JEB" if ij_code=="J8B"
	replace ij_code="ABM" if ij_code=="ABT"
	replace ij_code="JAD" if ij_code=="VJO"
	replace ij_code="KCW" if ij_code=="VJM"
	replace ij_code="MT" if ij_code=="VJE"
	replace ij_code="SJL" if ij_code=="SDL"
	replace ij_code="CMR" if ij_code=="VHJ"
	replace ij_code="JVC" if ij_code=="VJA"
	replace ij_code="JLB" if ij_code=="VJB"
	replace ij_code="HVW" if ij_code=="VJH"
	replace ij_code="PSL" if ij_code=="VPL"
	replace ij_code="SY" if ij_code=="VSY"
	replace ij_code="WKZ" if ij_code=="VWZ"
	replace ij_code="EWB" if ij_code=="EBW"
	replace judge_name_caps="PAUL L. JOHNSTON" if judge_name_caps=="PAUL L JOHNSTON"
	replace judge_name_caps="ALISON M. BROWN" if judge_name_caps=="ALISON M. BROWN (TEMP)"
	replace judge_name_caps="DAVID AYALA" if judge_name_caps=="DAVID AYALA (VISITING JUDGE)"
	replace judge_name_caps="LAWRENCE O. BURMAN" if judge_name_caps=="LAWRENCE R. BURMAN"
	replace judge_name_caps="CLAREASE RANKIN YATES" if judge_name_caps=="CLAREASE RANKIN YATES (VISITING JUDGE)"
	replace judge_name_caps="JOAN V. CHURCHILL" if judge_name_caps=="JOAN V. CHURCHILL (VISITING JUDGE)"
	replace judge_name_caps="JIMMIE LEE BENTON" if judge_name_caps=="JIMMIE LEE BENTON (VISITING JUDGE)"
	replace judge_name_caps="HOWARD VAN WINKLE" if judge_name_caps=="HOWARD VAN WINKLE (VISITING JUDGE)"
	replace judge_name_caps="PHILIP S. LAW" if judge_name_caps=="PHILIP S. LAW (VISITING JUDGE)"
	replace judge_name_caps="SUSAN YARBROUGH" if judge_name_caps=="SUSAN YARBROUGH (VISITING JUDGE)"
	replace judge_name_caps="WILLIAM K. ZIMMER" if judge_name_caps=="WILLIAM K. ZIMMER (VISITING JUDGE)"	
	drop if judge_name_caps=="<ALL JUDGES>"
	drop if strpos(judge_name_caps,"IJ")>0
	drop if judge_name_caps=="LIVE JUDGE - BAL"
	drop if strpos(judge_name_caps,"MASTER CALENDAR")>0
	drop if strpos(judge_name_caps,"VISITING JUDGE")>0
	drop if judge_name_caps=="FORMER IMMIGRATION JUDGE"
	drop if strpos(judge_name_caps,"VIDEO")>0
duplicates drop
duplicates tag ij_code, gen(dup)
assert dup==0
drop dup
duplicates tag judge_name_caps, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_lookup_ij_code.dta", replace



insheet using "${path_rawdata}court_appln.csv", c double names clear
destring idncase idnproceeding, force replace
drop if idncase == . | idnproceeding == .
replace appl_code = trim(itrim(upper(appl_code)))

* date of application received (hms is useless)
replace appl_recd_date=substr(appl_recd_date,1,19)
gen dateform = dofc(clock(appl_recd_date, "YMDhms"))
gen appl_year = year(dateform)
gen appl_month = month(dateform)
gen appl_day = day(dateform)
drop appl_recd_date dateform
gen appl_recd_date = mdy(appl_month,appl_day,appl_year)

duplicates tag idnproceedingappln, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}master_court_appln.dta", replace



* dbo_tblAdjournmentcodes.xlsx has idnAdjCode, Regd_By, strDescription, asy_clk_stat 
import excel using "${path_rawdata}dbo_tblAdjournmentcodes.xlsx", clear firstrow
rename strcode adj_rsn
rename strDesciption adj_rsn_string
rename Regd_By adj_requested_by
replace adj_requested_by = trim(itrim(upper(adj_requested_by)))
replace adj_requested_by = "GOVERNMENT" if adj_requested_by == "I"
replace adj_requested_by = "EITHER" if adj_requested_by == "E"
replace adj_requested_by = "ALIEN" if adj_requested_by == "A"
rename asy_clk_stat adj_clock_status
replace adj_clock_status = "STOPPED" if adj_clock_status == "S"
replace adj_clock_status = "RUNNING" if adj_clock_status == "R"
replace adj_clock_status = "ENDS" if adj_clock_status == "X"
replace adj_rsn_string = trim(itrim(upper(adj_rsn_string)))
keep adj_rsn adj_clock_status adj_requested_by adj_rsn_string
replace adj_rsn=trim(itrim(upper(adj_rsn)))
duplicates tag adj_rsn, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}scheduling_adjcodes.dta", replace



insheet using "${path_rawdata}eoir/tbllookupCal_Type.csv", c double nonames clear
rename v2 cal_type
rename v3 cal_type_string
replace cal_type=trim(itrim(upper(cal_type)))
replace cal_type_string=trim(itrim(upper(cal_type_string)))
replace cal_type_string = "INDIVIDUAL" if cal_type == "I"
replace cal_type_string = "MULTIPLE" if cal_type == "M"
replace cal_type_string = "NATURALIZATION" if cal_type == "N"
keep cal_type cal_type_string
keep if cal_type == "I" |  cal_type == "M" |  cal_type == "N"
duplicates drop
duplicates tag cal_type, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}scheduling_caltype.dta", replace



insheet using "${path_rawdata}eoir/tblLookupNOTICE.csv", c double nonames clear
rename v2 notice_code
rename v3 notice_code_string
keep notice_code notice_code_string
replace notice_code_string = trim(notice_code_string)
replace notice_code=trim(itrim(upper(notice_code)))
duplicates tag notice_code, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}scheduling_notice.dta", replace



insheet using "${path_rawdata}tbllookupSchedule_Type.csv", c double nonames clear
rename v2 schedule_type
rename v3 schedule_type_string
replace schedule_type_string=trim(itrim(upper(schedule_type_string)))
keep schedule*
replace schedule_type=trim(itrim(upper(schedule_type)))
drop if schedule_type_string=="UNKNOWN"
duplicates tag schedule_type, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}scheduling_schedcodes.dta", replace






*****************************************************************************************************
* Master Decision Files
*****************************************************************************************************

insheet using "${path_rawdata}master.csv", c double names clear

*Later code focuses on comp_date rather than other dates
* date of decision
assert strlen(comp_date)==9 if comp_date!=""
gen dateform = date(comp_date,"DMY")
gen comp_year = year(dateform)
gen comp_month = month(dateform)
gen comp_day = day(dateform)
drop comp_date dateform
gen comp_date = mdy(comp_month,comp_day,comp_year)

* date of filing
assert strlen(osc_date)==9 if osc_date!=""
gen dateform = date(osc_date,"DMY")
gen osc_year = year(dateform)
gen osc_month = month(dateform)
gen osc_day = day(dateform)
drop osc_date dateform 
gen osc_date = mdy(osc_month,osc_day,osc_year)

* date of proceeding commencing
assert strlen(input_date)==9 if input_date!=""
gen dateform = date(input_date,"DMY")
gen input_year = year(dateform)
gen input_month = month(dateform)
gen input_day = day(dateform)
drop input_date dateform
gen input_date = mdy(input_month,input_day,input_year)

*comp_date almost always occurs after osc_date and input_date
g tempdif = comp_date-osc_date
sum tempdif, d
drop tempdif
g tempdif = comp_date-input_date
sum tempdif, d
drop tempdif

*attorney_flag is either 1 or missing, so assume no attorney if attorney_flag is missing
gen lawyer = (attorney_flag == 1)

*E represents defensive case (a good proxy for detained case) and I represents affirmative case (grant rates are higher)
replace c_asy_type=trim(itrim(upper(c_asy_type)))
replace c_asy_type="" if !(c_asy_type=="E" | c_asy_type=="I")
gen defensive = c_asy_type == "E" if c_asy_type != ""
gen affirmative = c_asy_type == "I" if c_asy_type != ""

*drop 14 cases in which idnproceeding is not a number, or missing idncase or idnproceeding
destring idnproceeding, force replace
drop if idncase == . | idnproceeding == .

*clean matching variables
foreach v in case_type dec_type other_comp nat base_city_code hearing_loc_code ij_code {
	replace `v'=trim(itrim(upper(`v')))
}

*fix ij_codes that actually refer to same judge
*TO DO LATER -- If we think that visiting judge codes may have mistakes (e.g. VJA could refer to >=2 people), we should flag these and not use their decisions to estimate autocorrelation (except for controls for general case quality)
replace ij_code="DA" if ij_code=="VDA"
replace ij_code="LOB" if ij_code=="LRB"
replace ij_code="RAJ" if ij_code=="MVJ"
replace ij_code="MHB" if ij_code=="MH7"
replace ij_code="DLM" if ij_code=="DMK"
replace ij_code="PLJ" if ij_code=="PJ"
replace ij_code="JEB" if ij_code=="J8B"
replace ij_code="ABM" if ij_code=="ABT"
replace ij_code="JAD" if ij_code=="VJO"
replace ij_code="KCW" if ij_code=="VJM"
replace ij_code="MT" if ij_code=="VJE"
replace ij_code="SJL" if ij_code=="SDL"
replace ij_code="CMR" if ij_code=="VHJ"
replace ij_code="JVC" if ij_code=="VJA"
replace ij_code="JLB" if ij_code=="VJB"
replace ij_code="HVW" if ij_code=="VJH"
replace ij_code="PSL" if ij_code=="VPL"
replace ij_code="SY" if ij_code=="VSY"
replace ij_code="WKZ" if ij_code=="VWZ"
replace ij_code="EWB" if ij_code=="EBW"

merge m:1 case_type using "${path_cleandata}master_case_type.dta", gen(_mcase) keep(1 3)
tab case_type if _mcase==1

merge m:1 dec_type using "${path_cleandata}master_decision_type.dta", gen(_mdectype) keep(1 3)
tab dec_type if _mdectype==1

*KSNOTE: we don't know the justification for the next 10 lines of code, but the variables are not used in the analysis and no obs are lost
gen outcome_recorded_in_field = "C" if dec_code != ""

merge m:1 case_type dec_code outcome_recorded_in_field using "${path_cleandata}master_decision_on_proceeding_dec.dta", gen(_mdecproceeddec) keep(1 3)
tab case_type if _mdecproceeddec==1
tab dec_code if _mdecproceeddec==1
tab outcome_recorded_in_field if _mdecproceeddec==1

replace outcome_recorded_in_field = "O" if other_comp != ""

merge m:1 case_type other_comp outcome_recorded_in_field using "${path_cleandata}master_decision_on_proceeding_oth.dta", gen(_mdecproceedoth) update keep(1 3 4 5)
tab case_type if _mdecproceedoth==1
tab other_comp if _mdecproceedoth==1
tab outcome_recorded_in_field if _mdecproceedoth==1

merge m:1 nat using "${path_cleandata}master_nationality.dta", gen(_mnat) keep(1 3)
tab nat if _mnat==1

merge m:1 base_city_code using "${path_cleandata}master_base_city.dta", gen(_mbasecity) keep(1 3)
tab base_city_code if _mbasecity==1

merge m:1 hearing_loc_code using "${path_cleandata}master_hearing_loc.dta", gen(_mhearingloc) keep(1 3)
tab hearing_loc_code if _mhearingloc==1

merge m:1 ij_code using "${path_cleandata}master_lookup_ij_code.dta", gen(_mlookupijcode) keep(1 3)
tab ij_code if _mlookupijcode==1

*ids for city, KSNOTE: drop unknown cities (51 obs)
drop if base_city_code=="" | _mbasecity==1
egen cityid = group(base_city_code)

*ids for judge
sort judge_name_caps
assert ij_code==ij_code[_n-1] if judge_name_caps==judge_name_caps[_n-1] & judge_name_caps!=""
egen judgeid = group(ij_code) if _mlookupijcode==3

*NOTE: dropping unknown judgeid's is probably okay, but we lose power for controlling time varying case quality
drop if missing(judgeid)
assert cityid!=.

*ids for nationality, KSNOTE: keep obs corresponding to unknown nat but do not assign id number
egen natid = group(nat) if _mnat==3

* generate covariates for proceedings -- these are not used for anything in the analysis so for
replace dec_string=trim(itrim(upper(dec_string)))
gen venue_change = dec_string=="CHANGE OF VENUE" if dec_string != ""
gen deport = dec_string=="DEPORT" if dec_string != ""
gen relief_granted = dec_string=="RELIEF GRANTED" if dec_string != ""
gen remove = dec_string=="REMOVE" if dec_string != ""
gen terminated = strpos(dec_string,"TERMINATE") != 0 if dec_string != ""
gen voluntary_departure = strpos(dec_string,"VOLUNTARY DEPARTURE") != 0 if dec_string != ""

replace dec_type_string=trim(itrim(upper(dec_type_string)))
gen oral = strpos(dec_type_string,"ORAL") != 0  if dec_type_string != ""
gen written = strpos(dec_type_string,"WRITTEN") != 0  if dec_type_string != ""
gen deport_form = strpos(dec_type_string,"DEPORT") != 0  if dec_type_string != ""
gen voluntary_form = strpos(dec_type_string,"VOLUNTARY") != 0  if dec_type_string != ""

replace case_type_string=trim(itrim(upper(case_type_string)))
gen deportation_proceeding =  strpos(case_type_string,"DEPORTATION") != 0  if case_type_string != ""
gen exclusion_proceeding =  strpos(case_type_string,"EXCLUSION") != 0  if case_type_string != ""
gen removal_proceeding =  strpos(case_type_string,"REMOVAL") != 0  if case_type_string != ""
gen asylum_only_proceeding =  strpos(case_type_string,"ASYLUM") != 0  if case_type_string != ""
gen withholding_only_proceeding =  strpos(case_type_string,"WITHHOLDING") != 0  if case_type_string != ""

*KSNOTE: data here is unique at idncase idnproceeding
egen idncode=group(idnproceeding idncase)
duplicates tag idncode, gen(dup)
assert dup==0
drop dup

compress
save "${path_cleandata}master_clean.dta", replace






*****************************************************************************
*Clean application level file that Sue sent to Chicago
*****************************************************************************
use ${path_cleandata}master_court_appln.dta, clear

merge m:1 appl_code using "${path_cleandata}application_codes.dta", gen(_mapplcode) keep(1 3)
tab appl_code if _mapplcode==1

merge m:1 appl_dec using  "${path_cleandata}application_dec.dta", gen(_mappldec) keep(1 3)
tab appl_dec if _mappldec==1

*keep only asylum related applications
gen strdescription = "ASYLUM" if application_type_string == "ASYLUM"
replace strdescription = "ASYLUM WITHHOLDING" if application_type_string == "ASYLUM WITHHOLDING"
replace strdescription = "WITHHOLDING-CONVENTION AGAINST TORTURE" if application_type_string == "WITHHOLDING-CONVENTION AGAINST TORTURE"
drop if strdescription==""

g decision = "GRANT" if strpos(application_dec_string,"GRANT") != 0 | strpos(application_dec_string,"CONDITIONAL") != 0
replace decision = "DENY" if strpos(application_dec_string,"DENY") != 0
replace decision = "ABANDONED" if strpos(application_dec_string,"ABANDON") != 0
replace decision = "WITHDRAWN" if strpos(application_dec_string,"WITHDRAWN") != 0
replace decision = "OTHER" if strpos(application_dec_string,"OTHER") != 0 | strpos(application_dec_string,"RESERVED") != 0

*code unique decision at the idncase idnproceeding strdescription level
*prioritized in order GRANT DENY ABANDONED WITHDRAWN OTHER UNKNOWN
keep idncase idnproceeding strdescription decision
duplicates drop
egen temp_code = group(idncase idnproceeding strdescription)
sort temp_code
count if decision!=decision[_n-1] & temp_code==temp_code[_n-1]

g temp_flag=decision!=decision[_n-1] & temp_code==temp_code[_n-1]
egen flag_decisionerror_strdes=max(temp_flag), by(temp_code)
drop temp_flag

g temp_decision = ""
foreach v in "GRANT" "DENY" "ABANDONED" "WITHDRAWN" "OTHER" {
	g temp_tag=decision=="`v'"
	egen temp_maxtag=max(temp_tag), by(temp_code)
	replace temp_decision="`v'" if temp_maxtag==1 & temp_decision==""
	drop temp_tag temp_maxtag
}
replace temp_decision="UNKNOWN" if temp_decision==""
drop decision
rename temp_decision decision 

keep idncase idnproceeding strdescription decision flag_decisionerror_strdes

duplicates drop
duplicates tag idncase idnproceeding strdescription, gen(dup)
assert dup==0
drop dup

*make unique at the idncase idnproceeding level
*decision1: prioritize grant or deny decisions, and within that, by ASYLUM, ASYLUM WITHHOLDING, and TORTURE
*decision2: grant if grant for any of asylum, withholding, or torture, then deny if for any of the 3
*	then what was recorded in asylum, withholding, or torture
sort idncase idnproceeding strdescription
g grantordeny=1 if decision=="GRANT" | decision=="DENY"
egen temp_code = group(idncase idnproceeding)

g temp_flag=decision!=decision[_n-1] & temp_code==temp_code[_n-1]
egen flag_decisionerror_idncaseproc=max(temp_flag), by(temp_code)
drop temp_flag

egen temp=max(flag_decisionerror_strdes), by(temp_code)
replace flag_decisionerror_strdes=temp
drop temp

g decision2 = ""
foreach v in "GRANT" "DENY" {
	g temp_tag=decision=="`v'"
	egen temp_maxtag=max(temp_tag), by(temp_code)
	replace decision2="`v'" if temp_maxtag==1 & decision2==""
	drop temp_tag temp_maxtag
}
assert decision!="GRANT" & decision!="DENY" if decision2==""
replace decision2=decision if decision2==""
rename decision decision1

sort temp_code grantordeny strdescription
count if decision1!=decision1[_n-1] & temp_code==temp_code[_n-1]
drop if temp_code==temp_code[_n-1]
drop temp_code

duplicates tag idncase idnproceeding, gen(dup)
assert dup==0
drop dup
sort idncase idnproceeding

keep idncase idnproceeding decision1 decision2 flag* strdescription

rename decision1 decision1_chicago
rename decision2 decision2_chicago
rename strdescription strdescription_chicago
compress
save "${path_cleandata}master_court_appln_clean.dta", replace






*****************************************************************************
*Clean alternative version of application level file that Sue gave to Holger
*****************************************************************************
insheet using "${path_rawdata}court_appln_holger_raw.csv", c double names clear

duplicates drop
drop if idncase==. | idnproceeding==.

*keep only asylum related applications
gen temp = "ASYLUM" if strdescription == "ASYLUM"
replace temp = "ASYLUM WITHHOLDING" if strdescription == "ASYLUM WITHHOLDING"
replace temp = "WITHHOLDING-CONVENTION AGAINST TORTURE" if strdescription == "WITHHOLDING-CONVENTION AGAINST TORTURE"

replace strdescription=temp
drop if strdescription==""
drop temp

g decision = "GRANT" if strpos(strcourtapplndecdesc,"GRANT") != 0
replace decision = "DENY" if strpos(strcourtapplndecdesc,"DENY") != 0
replace decision = "ABANDONED" if strpos(strcourtapplndecdesc,"ABANDON") != 0
replace decision = "WITHDRAWN" if strpos(strcourtapplndecdesc,"WITHDRAWN") != 0
replace decision = "OTHER" if strpos(strcourtapplndecdesc,"OTHER") != 0 | strpos(strcourtapplndecdesc,"RESERVED") != 0

keep idncase idnproceeding strdescription decision
duplicates drop

*code unique decision at the idncase idnproceeding strdescription level
*prioritized in order GRANT DENY ABANDONED WITHDRAWN OTHER UNKNOWN
egen temp_code = group(idncase idnproceeding strdescription)
sort temp_code
count if decision!=decision[_n-1] & temp_code==temp_code[_n-1]

g temp_flag=decision!=decision[_n-1] & temp_code==temp_code[_n-1]
egen flag_decisionerror_strdes=max(temp_flag), by(temp_code)
drop temp_flag

g temp_decision = ""
foreach v in "GRANT" "DENY" "ABANDONED" "WITHDRAWN" "OTHER" {
	g temp_tag=decision=="`v'"
	egen temp_maxtag=max(temp_tag), by(temp_code)
	replace temp_decision="`v'" if temp_maxtag==1 & temp_decision==""
	drop temp_tag temp_maxtag
}
replace temp_decision="UNKNOWN" if temp_decision==""
drop decision
rename temp_decision decision 

keep idncase idnproceeding strdescription decision flag_decisionerror_strdes

duplicates drop
duplicates tag idncase idnproceeding strdescription, gen(dup)
assert dup==0
drop dup

*make unique at the idncase idnproceeding level
*prioritize grant or deny decisions, and within that, by ASYLUM, ASYLUM WITHHOLDING, and TORTURE
sort idncase idnproceeding strdescription
g grantordeny=1 if decision=="GRANT" | decision=="DENY"
egen temp_code = group(idncase idnproceeding)

g temp_flag=decision!=decision[_n-1] & temp_code==temp_code[_n-1]
egen flag_decisionerror_idncaseproc=max(temp_flag), by(temp_code)
drop temp_flag

egen temp=max(flag_decisionerror_strdes), by(temp_code)
replace flag_decisionerror_strdes=temp
drop temp

g decision2 = ""
foreach v in "GRANT" "DENY" {
	g temp_tag=decision=="`v'"
	egen temp_maxtag=max(temp_tag), by(temp_code)
	replace decision2="`v'" if temp_maxtag==1 & decision2==""
	drop temp_tag temp_maxtag
}
assert decision!="GRANT" & decision!="DENY" if decision2==""
replace decision2=decision if decision2==""
rename decision decision1

sort temp_code grantordeny strdescription
count if decision1!=decision1[_n-1] & temp_code==temp_code[_n-1]
drop if temp_code==temp_code[_n-1]
drop temp_code

duplicates tag idncase idnproceeding, gen(dup) 
assert dup==0
drop dup
sort idncase idnproceeding

keep idncase idnproceeding decision1 decision2 flag* strdescription

rename decision1 decision1_holger
rename decision2 decision2_holger
rename strdescription strdescription_holger
compress
save "${path_cleandata}court_appln_holger_clean.dta", replace






*****************************************************************************
* merge master file with judge id's with decisions from application files
*****************************************************************************

use "${path_cleandata}master_clean.dta", clear

merge 1:1 idncase idnproceeding using "${path_cleandata}master_court_appln_clean.dta", gen(_mmasterappl)
drop if _mmasterappl==2

*most of the master dataset does not match to anything in the proceedings file
*of those that match, many do not have grant or deny decisions corresponding to asylum proceedings
count
count if _mmasterappl==3
count if _mmasterappl==3 & (decision2_chicago=="GRANT" | decision2_chicago=="DENY")

merge 1:1 idncase idnproceeding using "${path_cleandata}court_appln_holger_clean.dta", gen(_mmasterappl2)
drop if _mmasterappl2==2

*most of the master dataset does not match to anything in the proceedings file
*of those that match, many do not have grant or deny decisions corresponding to asylum proceedings
count
count if _mmasterappl2==3
count if _mmasterappl2==3 & (decision2_holger=="GRANT" | decision2_holger=="DENY")

compress
sort idncase idnproceeding
save "${path_cleandata}master_decisions_clean.dta", replace






*************************************************************************************
*Scheduling file
*************************************************************************************

* for variables that are in both scheduling and master files, add adj_* for scheduling file variables

use ${path_tblschedule}, clear

rename IDNPROCEEDING idnproceeding
rename IDNCASE idncase 

drop if idncase == . | idnproceeding == .

* clean dates, later use adj_date to match with comp_date in master decision dataset
replace adj_date=substr(adj_date,1,19)
gen dateform = date(adj_date,"YMDhms")
gen adj_year = year(dateform)
gen adj_month = month(dateform)
gen adj_day = day(dateform)
drop adj_date dateform
gen adj_date = mdy(adj_month,adj_day,adj_year)
assert adj_date!=.
gen comp_date = adj_date

replace input_date=substr(input_date,1,19)
gen dateform = date(input_date,"YMDhms")
gen adj_input_year = year(dateform)
gen adj_input_month = month(dateform)
gen adj_input_day = day(dateform)
drop input_date dateform
gen adj_input_date = mdy(adj_input_month,adj_input_day,adj_input_year)

replace osc_date=substr(osc_date,1,19)
gen dateform = date(osc_date,"YMDhms")
gen adj_osc_year = year(dateform)
gen adj_osc_month = month(dateform)
gen adj_osc_day = day(dateform)
drop osc_date dateform
gen adj_osc_date = mdy(adj_osc_month,adj_osc_day,adj_osc_year)

*clean times, assume that 0 is missing
*Assume 600 is the earliest possible start time
*600 and 700 are flagged because they are unusually early and may mean 1800 and 1900
destring adj_time_start, replace
replace adj_time_start=. if adj_time_start==0
g flag_earlystarttime=adj_time_start>=600 & adj_time_start<800
replace adj_time_start = adj_time_start + 1200 if adj_time_start < 600

replace adj_time_stop = "0" if adj_time_stop == "000*"
destring adj_time_stop, replace
replace adj_time_stop=. if adj_time_stop==0
replace adj_time_stop = adj_time_stop + 1200 if adj_time_stop < 600
replace adj_time_stop=. if adj_time_stop>2400

*add adj_ to start of variable if also in master dataset
foreach v in hearing_loc_code base_city_code ij_code {
	rename `v' adj_`v'
}
foreach v in eoirattorneyid alien_atty_code lang adj_hearing_loc_code adj_base_city_code {
	replace `v'=trim(itrim(upper(`v')))
}
egen eoirattyid = group(eoirattorneyid)
egen alienattyid = group(alien_atty_code)
egen langid = group(lang)
egen adj_hearingid = group(adj_hearing_loc_code)
egen adj_basecityid = group(adj_base_city_code)

*merge codes to scheduling dictionaries
foreach v in adj_rsn cal_type notice_code schedule_type {
	replace `v'=trim(itrim(upper(`v')))
}

merge m:1 adj_rsn using "${path_cleandata}scheduling_adjcodes.dta", gen(_madj) keep(1 3)
tab adj_rsn if _madj==1

merge m:1 cal_type using "${path_cleandata}scheduling_caltype.dta", gen(_mcaltype) keep(1 3)
tab cal_type if _mcaltype==1

merge m:1 notice_code using "${path_cleandata}scheduling_notice.dta", gen(_mnotice) keep(1 3)
tab notice_code if _mnotice==1

merge m:1 schedule_type using "${path_cleandata}scheduling_schedcodes.dta", gen(_mschedcodes) keep(1 3)
tab schedule_type if _mschedcodes==1

*NOTE: these variables are not used for the current analysis
* generate covariates for adjournment reasons
gen adj_completion_prior_to_hearing = strpos(adj_rsn_string,"COMPLETION PRIOR TO HEARING") != 0  if adj_rsn_string != ""
gen adj_case_conversion = strpos(adj_rsn_string,"CASE CONVERSION") != 0  if adj_rsn_string != ""

* this is not a final decision
gen adj_alien_to_seek_representation = strpos(adj_rsn_string,"ALIEN TO SEEK REPRESENTATION") != 0  if adj_rsn_string != ""
gen adj_merits_hearing = strpos(adj_rsn_string,"MERITS HEARING") != 0  if adj_rsn_string != ""
gen adj_to_file = strpos(adj_rsn_string,"TO FILE") != 0  if adj_rsn_string != ""
gen adj_preparation = strpos(adj_rsn_string,"PREPARATION") != 0  if adj_rsn_string != ""
gen adj_consolidation_family = strpos(adj_rsn_string,"CONSOLIDATION WITH FAMILY") != 0  if adj_rsn_string != ""

* which are important?  do we need these in the future for a hearing-level analysis rather than decision-level analysis?
* it could be useful to understand what is the "last" adjournment reason on a decision
gen government_requested = adj_requested_by == "GOVERNMENT" if adj_requested_by != ""
gen alien_requested = adj_requested_by == "ALIEN" if adj_requested_by != ""
gen either_requested = adj_requested_by == "EITHER" if adj_requested_by != ""

*KSNOTE: what does adj_clock_status=="Q" mean?
gen clock_stopped =  adj_clock_status == "STOPPED" if adj_clock_status != ""
gen clock_running = adj_clock_status == "RUNNING" if adj_clock_status != ""
gen clock_end = adj_clock_status == "ENDS" if adj_clock_status != ""

* generate covariates for calendar reasons
gen individual_cal = cal_type_string == "INDIVIDUAL" if cal_type_string != ""
gen multiple_cal = cal_type_string == "MULTIPLE" if cal_type_string != ""

* generate covariates for notice
*KSNOTE: changed "CUSTORY" to "CUSTODY" -- was this a typo?
gen deportation_notice =  strpos(notice_code_string,"DEPORTATION") != 0  if notice_code_string != ""
gen exclusion_notice =  strpos(notice_code_string,"EXCLUSION") != 0  if notice_code_string != ""
gen removal_notice =  strpos(notice_code_string,"REMOVAL") != 0  if notice_code_string != ""
gen asylum_only_notice =  strpos(notice_code_string,"ASYLUM") != 0  if notice_code_string != ""
gen withholding_only_notice =  strpos(notice_code_string,"WITHHOLDING") != 0  if notice_code_string != ""
gen custody_notice =  strpos(notice_code_string,"CUSTODY") != 0  if notice_code_string != ""
gen family_notice =  strpos(notice_code_string,"FAMILY") != 0  if notice_code_string != ""
gen initial_notice =  strpos(notice_code_string,"INITIAL") != 0  if notice_code_string != ""

* generate covariates for scheduling type
gen individual_sched = strpos(schedule_type_string,"INDIVIDUAL") != 0 if schedule_type_string != ""
gen multiple_sched = strpos(schedule_type_string,"MASTER") != 0 if schedule_type_string != ""
gen unknown_sched = strpos(schedule_type_string,"UNKNOWN") != 0 if schedule_type_string != ""

egen idncode_sched=group(idnproceeding idncase)

duplicates tag idnschedule idnproceeding idncase, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}scheduling_full.dta", replace



* Create file unique at idncase idnproceeding comp_date level
* Assume if there is a scheduled hearing (adj_date) on the date of a proceeding's decision (comp_date), 
* then the last adj_time_start is correct
use "${path_cleandata}scheduling_full.dta", clear 

egen tempcode = group(idncode_sched comp_date)

*Data is unique at level below
sort tempcode adj_time_start idnschedule

*check that important variables are consistent within tempcode
count
count if eoirattyid!=eoirattyid[_n-1] & tempcode==tempcode[_n-1]
count if alienattyid!=alienattyid[_n-1] & tempcode==tempcode[_n-1]
count if adj_hearing_loc_code!=adj_hearing_loc_code[_n-1] & tempcode==tempcode[_n-1]
count if adj_basecityid!=adj_basecityid[_n-1] & tempcode==tempcode[_n-1]

by tempcode: keep if _n == _N
drop tempcode

compress
save "${path_cleandata}scheduling_compdate.dta", replace



use "${path_cleandata}scheduling_compdate.dta", clear
keep idnproceeding idncase comp_date adj_date adj_time_start adj_input_date adj_osc_date eoirattyid alienattyid adj_hearing_loc_code adj_base_city_code flag_*
duplicates tag idnproceeding idncase comp_date, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}scheduling_compdate_short.dta", replace

 

* This file assumes adj_date and adj_time_start, within litigant, is the correct order, saves the last hearing before the decision
* If we are unable to find an adj_date that matches a comp_date within an idncase and idnproceedings, this allows a merge directly on idncase idnproceeding.
use "${path_cleandata}scheduling_full.dta", clear

*Data is not unique at the (idncode_sched adj_date adj_time_start) level, but is unique at level below
sort idncode_sched adj_date adj_time_start idnschedule

count
count if eoirattyid!=eoirattyid[_n-1] & idncode_sched==idncode_sched[_n-1]
count if alienattyid!=alienattyid[_n-1] & idncode_sched==idncode_sched[_n-1]
count if adj_hearing_loc_code!=adj_hearing_loc_code[_n-1] & idncode_sched==idncode_sched[_n-1]
count if adj_basecityid!=adj_basecityid[_n-1] & idncode_sched==idncode_sched[_n-1]

by idncode_sched: keep if _n == _N
compress
save "${path_cleandata}scheduling_adjdate.dta", replace



use "${path_cleandata}scheduling_adjdate.dta", clear
keep idnproceeding idncase adj_date adj_time_start adj_input_date adj_osc_date eoirattyid alienattyid adj_hearing_loc_code adj_base_city_code flag_*
duplicates tag idnproceeding idncase, gen(dup)
assert dup==0
drop dup
compress
save "${path_cleandata}scheduling_adjdate_short.dta", replace






*************************************************************************************
*Merge Master Decision File and Scheduling file
*************************************************************************************

use "${path_cleandata}master_decisions_clean.dta", clear

*drop 431 observations without comp_date
drop if comp_date==.

*merge with scheduling data at idncase idnproceeding comp_date level
*564294 obs out of 609778 match
merge 1:1 idncase idnproceeding comp_date using "${path_cleandata}scheduling_compdate_short", gen(_mschedcompdate) keep(1 3)

*flag whether key variables matched correctly
g flag_mismatch_base_city=(base_city_code!=adj_base_city_code) if base_city_code!="" & adj_base_city_code!=""
tab flag_mismatch_base_city

g flag_mismatch_hearing=(hearing_loc_code!=adj_hearing_loc_code) if hearing_loc_code!="" & adj_hearing_loc_code!=""
tab flag_mismatch_hearing

*save a version of the dataset taking comp_date from Master file as correct
*so a non-match to Scheduling data means we don't have time of day information
compress
save "${path_cleandata}decision_sched_merge_compdateoriginal.dta", replace



*alternate version of data using compdate as adj_date if there's a mismatch
*merge with scheduling data at idncase idnproceeding level if there was no comp_date match
*NOTE: we flag these observations because the adj_date != compdate
use "${path_cleandata}decision_sched_merge_compdateoriginal.dta", clear
keep if _mschedcompdate==1
drop adj_date adj_time_start
merge 1:1 idncase idnproceeding using "${path_cleandata}scheduling_adjdate_short.dta", gen(_mscheddatetime) keep(1 3 4 5 ) update

g flag_datemismatch=(_mscheddatetime==3)

g temp_difdate=comp_date - adj_date
sum temp_difdate, d
drop temp_difdate

*flag whether key variables matched correctly
replace flag_mismatch_base_city=(base_city_code!=adj_base_city_code) if base_city_code!="" & adj_base_city_code!="" & flag_mismatch_base_city==.
tab flag_mismatch_base_city if flag_datemismatch==1

replace flag_mismatch_hearing=(hearing_loc_code!=adj_hearing_loc_code) if hearing_loc_code!="" & adj_hearing_loc_code!="" & flag_mismatch_hearing==.
tab flag_mismatch_hearing if flag_datemismatch==1

save "${path_cleandata}temp_match_scheduling_datetimestamp_short.dta", replace

use "${path_cleandata}decision_sched_merge_compdateoriginal.dta", clear
keep if _mschedcompdate==3
append using "${path_cleandata}temp_match_scheduling_datetimestamp_short.dta"
rm "${path_cleandata}temp_match_scheduling_datetimestamp_short.dta"

replace comp_date=adj_date if adj_date!=.
replace comp_year=year(comp_date)
replace comp_month=month(comp_date)
replace comp_day=day(comp_date)
compress
save "${path_cleandata}decision_sched_merge_adjdate.dta", replace
*/





*************************************************************************************
*Set as panel data by judge time
*************************************************************************************

***LOOP THROUGH AND CREATE DIFFERENT DATA SETS WITH DIFFERENT ASSUMPTIONS FOR THE REGRESSIONS

*decisions from either chicago dataset or holger's dataset
foreach source in chicago /* holger */ {

*decisions defined as (1) grant in asylum if available, then witholding, then torture, or (2) max of grant dummy in any
foreach decis in 1 /* 2 */ { 

*family definition
foreach family in eoirstrictconsec3 /* strictconsec3 eoirstrict2 strictconsec2 strict2 loose2 consec2 eoirstrictconsec eoirstrict loose  consec  strict strictconsec faminput famosc */ {

use "${path_cleandata}decision_sched_merge_compdateoriginal", clear

*court codes, assume random assignment at city level instead of city-hearing level
assert cityid!=.
egen courtid=group(cityid)
egen ij_court_code=group(ij_code courtid)

*To simplify the code, we treat each IDNCODE=group(idncase idnproceeding) as a new case
*And add controls for whether its a first or subsequent proceeding
*90% of obs have a single proceeding per idncase
*most idncases w/ multiple proceedings have proceedings on dif comp_date's and have different grant decisions
*the first proceeding is likely to be deny and subsequent proceedings are about 60% grant
*the proceedings for the same idncase are often very far apart (median is 3 years)


*number of cases per day, including nonasylum and those without grant or deny decisions
egen numanycasesperday=count(idncode), by(ij_court_code comp_date)

*flags for multiple proceedings per idncase -- counting all proceedings
egen numproceedings=count(idnproceeding), by(idncase)
tab numproceedings
g flag_multiple_proceedings=numproceedings>1

sort idncase comp_date idnproceeding
g temp_daysapart=comp_date-comp_date[_n-1] if idncase==idncase[_n-1]
sum temp_daysapart, d
drop temp_*

g flag_notfirstproceeding=0
replace flag_notfirstproceeding=(idncase==idncase[_n-1])

*determine which decisions to use: Chicago or Holger, V1 or V2?
g decision=decision`decis'_`source'
g strdescription=strdescription_`source'

*limit to asylum-related grant or deny and repeat flags
g grantordeny=(decision=="GRANT" | decision=="DENY")
g asylum_grantordeny=(strdescription!="" & grantordeny==1)
egen tempcode=group(idncase asylum_grantordeny)

egen numproceedings2=count(idnproceeding) if asylum_grantordeny==1, by(tempcode)
tab numproceedings2
g flag_multiple_proceedings2=numproceedings2>1 if asylum_grantordeny==1

sort tempcode comp_date idnproceeding
g temp_daysapart2=comp_date-comp_date[_n-1] if tempcode==tempcode[_n-1] & asylum_grantordeny==1
sum temp_daysapart2, d
drop temp_*

g grant=(decision=="GRANT") if asylum_grantordeny==1
g deny=(decision=="DENY") if asylum_grantordeny==1
count if grant!=grant[_n-1] & tempcode==tempcode[_n-1] & asylum_grantordeny==1
count if grant!=grant[_n-1] & tempcode==tempcode[_n-1] & comp_date==comp_date[_n-1] & asylum_grantordeny==1 

g flag_notfirstproceeding2=0
replace flag_notfirstproceeding2=(idncase==idncase[_n-1]) if asylum_grantordeny==1

g flag_prevprocgrant=grant[_n-1] if tempcode==tempcode[_n-1] & asylum_grantordeny==1
g flag_prevprocdeny=deny[_n-1] if tempcode==tempcode[_n-1] & asylum_grantordeny==1

assert flag_prevprocgrant+flag_prevprocdeny==1 if flag_prevprocgrant+flag_prevprocdeny!=.

drop temp*

*keep only asylum decisions
keep if strdescription!=""

*number of asylum cases per day, including those without grant or deny decisions
egen numasylumcasesperday=count(idncode), by(ij_court_code comp_date)

*keep only asylum decisions with known grant or deny
*TO DO: tag observations if they follow other types of proceedings
keep if asylum_grantordeny==1



***Identify families

assert ij_court_code!=.
assert comp_date!=.
assert grant!=.
assert lawyer!=.

*only 1 observation is missing hearing location
drop if hearing_loc_code==""

*NOTE: natid defensive adj_time_start can be missing
*TEMP: later on, we should flag these and remove if relevant for current or previous observation

*LOOSE FAMILY DEFINITION 
*Family members required to be in same day, court, nationality, decision, lawyer, defensive
*Family members can be in different nonconsecutive time slots
if "`family'"=="loose" {
	egen famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
}

*LOOSE FAMILY DEFINITION 2
*Family members required to be in same day, court, hearing location, nationality, decision, lawyer, defensive
*Family members can be in different nonconsecutive time slots
if "`family'"=="loose2" {
	egen famcode=group(ij_court_code hearing_loc_code comp_date natid grant lawyer defensive), missing
}

*CONSECUTIVE FAMILY DEFINITION 
*Family members required to be in same day, court, nationality, decision, lawyer, defensive
*Family members must be in same or consecutive time slots
*If there are 2+ families with known time slots within day, and one person without known time slot that could be assigned to either family, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="consec" {
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	egen temp_famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode temptimecounter idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}

*CONSECUTIVE FAMILY DEFINITION 
*Family members required to be in same day, court, hearing location, nationality, decision, lawyer, defensive
*Family members must be in same or consecutive time slots
*If there are 2+ families with known time slots within day, and one person without known time slot that could be assigned to either family, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="consec2" {
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	egen temp_famcode=group(ij_court_code hearing_loc_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode temptimecounter idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}

*STRICT FAMILY DEFINITION USING ALIEN ATTY CODE
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="strict" {
	egen temp_famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode alienattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(alienattyid!=alienattyid[_n-1] & alienattyid!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}

*STRICT FAMILY DEFINITION USING ALIEN ATTY CODE 2
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="strict2" {
	egen temp_famcode=group(ij_court_code hearing_loc_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode alienattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(alienattyid!=alienattyid[_n-1] & alienattyid!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}

*STRICT FAMILY DEFINITION USING EOIR ATTY CODE
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="eoirstrict" {
	egen temp_famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode eoirattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(eoirattyid!=eoirattyid[_n-1] & eoirattyid!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}

*STRICT FAMILY DEFINITION USING EOIR ATTY CODES 2
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="eoirstrict2" {
	egen temp_famcode=group(ij_court_code hearing_loc_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode eoirattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(eoirattyid!=eoirattyid[_n-1] & eoirattyid!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}

*STRICT CONSECUTIVE FAMILY DEFINITION USING ALIEN ATTY CODE
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="strictconsec" {
	egen temp_famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode alienattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(alienattyid!=alienattyid[_n-1] & alienattyid!=.) if _n!=1 
	egen temp_famcode2=group(temp_famcode temp_count)	
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	sort temp_famcode2 temptimecounter idncase idnproceeding
	drop temp_count
	g temp_count=0
	by temp_famcode2: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode2 temp_count)
	drop temp*	
}

*STRICT CONSECUTIVE FAMILY DEFINITION USING ALIEN ATTY CODE 2
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="strictconsec2" {
	egen temp_famcode=group(ij_court_code comp_date hearing_loc_code natid grant lawyer defensive), missing
	sort temp_famcode alienattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(alienattyid!=alienattyid[_n-1] & alienattyid!=.) if _n!=1 
	egen temp_famcode2=group(temp_famcode temp_count)	
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	sort temp_famcode2 temptimecounter idncase idnproceeding
	drop temp_count
	g temp_count=0
	by temp_famcode2: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode2 temp_count)
	drop temp*	
}

if "`family'"=="strictconsec3" {
	replace lawyer=1 if alienattyid!=.
	egen temp_famcode=group(ij_court_code comp_date hearing_loc_code natid grant lawyer defensive), missing
	sort temp_famcode alienattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(alienattyid!=alienattyid[_n-1] & alienattyid!=.) if _n!=1 
	egen temp_famcode2=group(temp_famcode temp_count)	
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	sort temp_famcode2 temptimecounter idncase idnproceeding
	drop temp_count
	g temp_count=0
	by temp_famcode2: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode2 temp_count)
	drop temp*	
}

*STRICT CONSECUTIVE FAMILY DEFINITION USING EOIR ATTY CODE
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="eoirstrictconsec" {
	egen temp_famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode eoirattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(eoirattyid!=eoirattyid[_n-1] & eoirattyid!=.) if _n!=1 
	egen temp_famcode2=group(temp_famcode temp_count)	
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	sort temp_famcode2 temptimecounter idncase idnproceeding
	drop temp_count
	g temp_count=0
	by temp_famcode2: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode2 temp_count)
	drop temp*	
}

*STRICT CONSECUTIVE FAMILY DEFINITION USING EOIR ATTY CODE 2
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different known lawyers
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="eoirstrictconsec2" {
	egen temp_famcode=group(ij_court_code comp_date hearing_loc_code natid grant lawyer defensive), missing
	sort temp_famcode eoirattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(eoirattyid!=eoirattyid[_n-1] & eoirattyid!=.) if _n!=1 
	egen temp_famcode2=group(temp_famcode temp_count)	
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	sort temp_famcode2 temptimecounter idncase idnproceeding
	drop temp_count
	g temp_count=0
	by temp_famcode2: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode2 temp_count)
	drop temp*	
}

if "`family'"=="eoirstrictconsec3" {
	replace lawyer=1 if eoirattyid!=.
	egen temp_famcode=group(ij_court_code comp_date hearing_loc_code natid grant lawyer defensive), missing
	sort temp_famcode eoirattyid idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(eoirattyid!=eoirattyid[_n-1] & eoirattyid!=.) if _n!=1 
	egen temp_famcode2=group(temp_famcode temp_count)	
	sort ij_court_code comp_date adj_time_start idncase idnproceeding
	g temptimecounter=0
	by ij_court_code comp_date: replace temptimecounter=temptimecounter[_n-1]+(adj_time_start!=adj_time_start[_n-1] & adj_time_start!=.) if _n!=1
	replace temptimecounter=. if adj_time_start==.
	sort temp_famcode2 temptimecounter idncase idnproceeding
	drop temp_count
	g temp_count=0
	by temp_famcode2: replace temp_count=temp_count[_n-1]+(temptimecounter>temptimecounter[_n-1]+1 & temptimecounter!=.) if _n!=1 
	egen famcode=group(temp_famcode2 temp_count)
	drop temp*	
}


/*
*INPUT DATE BASED FAMILY DEFINITION
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different input dates
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="faminput" {
	egen temp_famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode input_date idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(input_date!=input_date[_n-1] & input_date!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}

*OSC DATE BASED FAMILY DEFINITION
*Family members required to be in same day
*Family members can be in different nonconsecutive time slots
*Family members cannot have different input dates
*If there are 2+ families with known lawyers within day, and one person without known lawyer, that person is arbitrarily assigned to the family with the largest idncase idnproceeding associated with them
if "`family'"=="famosc" {
	egen temp_famcode=group(ij_court_code comp_date natid grant lawyer defensive), missing
	sort temp_famcode osc_date idncase idnproceeding
	g temp_count=0
	by temp_famcode: replace temp_count=temp_count[_n-1]+(osc_date!=osc_date[_n-1] & osc_date!=.) if _n!=1 
	egen famcode=group(temp_famcode temp_count)
	drop temp*
}
*/


***Reduce to family level

egen numinfamily=count(idncode), by(famcode)
egen numpeopleperday=total(numinfamily), by(ij_court_code comp_date)

*For each family, assign the earliest known time slot for any family member
egen temp=min(adj_time_start), by(famcode)
replace adj_time_start=temp
drop temp

*also record lowest idncase idnproceeding within family, this allows sorts that can be replicated
egen temp=min(idncase), by(famcode)
replace idncase=temp
drop temp
egen temp=min(idnproceeding), by(famcode)
replace idnproceeding=temp
drop temp

*If we include flag variables that vary at the idncode idnproceeding level, we should take the max of them within a family
*Consider a written decision if written for any member of the family
foreach v of varlist flag_* written {
	g temp=`v'==1
	egen temp2=max(temp), by(famcode)
	replace `v'=temp2
	drop temp*
}

*take the mode of hearing location within a family, hearing location will never vary within family definitions with a 2.
egen temp=mode(hearing_loc_code), by(famcode) minmode
replace hearing_loc_code=temp
drop temp

*take the mode of attorney id
egen temp=mode(eoirattyid), by(famcode) minmode
replace eoirattyid=temp
drop temp

egen temp=mode(alienattyid), by(famcode) minmode
replace alienattyid=temp
drop temp

egen temp=mode(lawyer), by(famcode) minmode
replace lawyer=temp
drop temp



*take the min and max dates of within a family
foreach v in osc_date input_date {
	egen temp=min(`v'), by(famcode)
	g min_`v'=temp
	drop temp
	egen temp=max(`v'), by(famcode)
	g max_`v'=temp
	drop temp
}

keep famcode idncase idnproceeding ij_court_code comp_date adj_time_start natid grant lawyer* defensive ij_code courtid numinfamily numpeopleperday flag_* numanycasesperday numasylumcasesperday min_osc_date min_input_date max_osc_date max_input_date written hearing_loc_code eoirattyid alienattyid
duplicates drop
duplicates tag famcode, gen(dup)
assert dup==0
drop dup

g flag_unknowntime=adj_time_start==. 

g flag_unknownorderwithinday=0

***cases in which order within day is unknown:

*unknown order if multiple families assigned to same time slot within day
egen numfamsperslot=count(famcode), by(ij_court_code comp_date adj_time_start)
g temp=(numfamsperslot>1)
egen temp2=max(temp), by(ij_court_code comp_date)
replace flag_unknownorderwithinday=1 if temp2==1
drop temp*

*unknown order if more than one family per day, and at least one family has an unknown time slot
egen numfamsperday=count(famcode), by(ij_court_code comp_date)
g temp=(flag_unknowntime==1 & numfamsperday>1)
egen temp2=max(temp), by(ij_court_code comp_date)
replace flag_unknownorderwithinday=1 if temp2==1
drop temp*

*set order within day, missing if unknown
sort ij_court_code comp_date adj_time_start idncase idnproceeding
assert flag_unknownorderwithinday==flag_unknownorderwithinday[_n-1] if ij_court_code==ij_court_code[_n-1] & comp_date==comp_date[_n-1]
by ij_court_code comp_date: g orderwithinday=_n
g orderwithindayraw=orderwithinday
replace orderwithinday=. if flag_unknownorderwithinday==1
g lastindayD=(orderwithinday==numfamsperday)

*set raw order across days: this is just to make programming easier
*the raw order cannot be used if separated by multiple days or order is unknown within day
sort ij_court_code comp_date adj_time_start idncase idnproceeding
by ij_court_code: gen order_raw=_n
xtset ij_court_code order_raw

*create lagged grant variables
g comp_dow=dow(comp_date)

*raw grant variables
g grantraw=grant

*grant variable and lags nonmissing only if order within day is known
replace grant=. if flag_unknownorderwithinday==1

g L1grant=L.grant if orderwithinday!=. & (orderwithinday>1)
g L1grant_sameday=L1grant!=.
replace L1grant=L.grant if orderwithinday==1 & (L.comp_date==comp_date-1 | (L.comp_date>=comp_date-3 & comp_dow==1))
assert L1grant==. if grant==.

g L2grant=L2.grant if orderwithinday!=. & (orderwithinday>2)
g L2grant_sameday=L2grant!=.
replace L2grant=L2.grant if orderwithinday==2 & (L2.comp_date==comp_date-1 | (L2.comp_date>=comp_date-3 & comp_dow==1))
replace L2grant=L2.grant if orderwithinday==1 & (L2.comp_date==comp_date-1 | (L2.comp_date>=comp_date-3 & comp_dow==1))
replace L2grant=L2.grant if orderwithinday==1 & L1.orderwithinday==1 & (L2.comp_date==comp_date-2 | (L2.comp_date>=comp_date-4 & comp_dow==1))
assert L2grant==. if grant==.
assert L2grant==. if L1grant==.

*grant2 variable and lags nonomissing if order within day is known or second of 2 decisions in same day
g grant2=grant
g L1grant2=L1grant
g L2grant2=L2grant
replace grant2=grantraw if grant2==. & numfamsperday==2 & orderwithindayraw==2
replace L1grant2=L1.grantraw if L1grant2==. & numfamsperday==2 & orderwithindayraw==2


*number of grants by judge out the previous X decisions
*include decisions for which we don't know the exact time
*ties for ordering of these decisions are chosen according to order_raw
g numgrant_prev5=L1.grantraw+L2.grantraw+L3.grantraw+L4.grantraw+L5.grantraw
forval x=6/10 {
	local z=`x'-1
	g numgrant_prev`x'=numgrant_prev`z'+L`x'.grantraw
}
forval x=5/10 {
	g prev`x'_dayslapse=comp_date-L`x'.comp_date
}

*number of grants within same court, excluding the current judge
*include decisions for which we don't know the exact time
*ties for ordering of these decisions are chosen according to raw_order_court
sort courtid comp_date adj_time_start famcode
by courtid: g raw_order_court=_n
xtset courtid raw_order_court
g numcourtgrant_prev5=L1.grantraw+L2.grantraw+L3.grantraw+L4.grantraw+L5.grantraw

g numcourtgrantself_prev5=L1.grantraw*(L1.ij_court_code==ij_court_code)+L2.grantraw*(L2.ij_court_code==ij_court_code)+L3.grantraw*(L3.ij_court_code==ij_court_code)+L4.grantraw*(L4.ij_court_code==ij_court_code)+L5.grantraw*(L5.ij_court_code==ij_court_code)

g numcourtdecideself_prev5=(L1.ij_court_code==ij_court_code)+(L2.ij_court_code==ij_court_code)+(L3.ij_court_code==ij_court_code)+(L4.ij_court_code==ij_court_code)+(L5.ij_court_code==ij_court_code)


forval x=6/20 {
	local z=`x'-1
	g numcourtgrant_prev`x'=numcourtgrant_prev`z'+L`x'.grantraw
	g numcourtdecideself_prev`x'=numcourtdecideself_prev`z'+(L`x'.ij_court_code==ij_court_code)
	g numcourtgrantself_prev`x'=numcourtgrantself_prev`z'+L`x'.grantraw*(L`x'.ij_court_code==ij_court_code)
}
forval x=5/20 {
	g courtprev`x'_dayslapse=comp_date-L`x'.comp_date
}

*loop through court grant variables until the number of decisions by OTHER judges equals the desired count
forval x=5/10 {
	g numcourtgrantother_prev`x'=.
	g courtprevother`x'_dayslapse=.
	forval i=5/20 {
		replace numcourtgrantother_prev`x'=(numcourtgrant_prev`i'-numcourtgrantself_prev`i') if `i'-numcourtdecideself_prev`i'==`x'
		replace courtprevother`x'_dayslapse=courtprev`i'_dayslapse if `i'-numcourtdecideself_prev`i'==`x'
	}
}

g year=year(comp_date)

*mean grant rate per judge
egen meangrant_judge=mean(grant), by(ij_court_code)
egen numdecisions_judge=count(grant), by(ij_court_code)
g lomeangrant_judge=(numdecisions_judge*meangrant_judge-grant)/(numdecisions_judge-1)

egen meangrantraw_judge=mean(grantraw), by(ij_court_code)
egen numdecisionsraw_judge=count(grantraw), by(ij_court_code)
g lomeangrantraw_judge=(numdecisionsraw_judge*meangrantraw_judge-grantraw)/(numdecisionsraw_judge-1)

*moderate judge dummy
g moderategrant3070=(lomeangrant_judge>=.30 & lomeangrant_judge<=.70)
g moderategrantraw3070=(lomeangrantraw_judge>=.30 & lomeangrantraw_judge<=.70)

*mean grant rate per judge x nationality
egen meangrant_judgenat=mean(grant), by(ij_court_code natid)
egen numdecisions_judgenat=count(grant), by(ij_court_code natid)
g lomeangrant_judgenat=(numdecisions_judgenat*meangrant_judgenat-grant)/(numdecisions_judgenat-1)

egen meangrantraw_judgenat=mean(grantraw), by(ij_court_code natid)
egen numdecisionsraw_judgenat=count(grantraw), by(ij_court_code natid)
g lomeangrantraw_judgenat=(numdecisionsraw_judgenat*meangrantraw_judgenat-grantraw)/(numdecisionsraw_judgenat-1)

*mean grant rate per judge x defensive
egen meangrant_judgedef=mean(grant), by(ij_court_code defensive)
egen numdecisions_judgedef=count(grant), by(ij_court_code defensive)
g lomeangrant_judgedef=(numdecisions_judgedef*meangrant_judgedef-grant)/(numdecisions_judgedef-1)

egen meangrantraw_judgedef=mean(grantraw), by(ij_court_code defensive)
egen numdecisionsraw_judgedef=count(grantraw), by(ij_court_code defensive)
g lomeangrantraw_judgedef=(numdecisionsraw_judgedef*meangrantraw_judgedef-grantraw)/(numdecisionsraw_judgedef-1)

*mean grant rate per judge x nationality x defensive
egen meangrant_judgenatdef=mean(grant), by(ij_court_code natid defensive)
egen numdecisions_judgenatdef=count(grant), by(ij_court_code natid defensive)
g lomeangrant_judgenatdef=(numdecisions_judgenatdef*meangrant_judgenatdef-grant)/(numdecisions_judgenatdef-1)

egen meangrantraw_judgenatdef=mean(grantraw), by(ij_court_code natid defensive)
egen numdecisionsraw_judgenatdef=count(grantraw), by(ij_court_code natid defensive)
g lomeangrantraw_judgenatdef=(numdecisionsraw_judgenatdef*meangrantraw_judgenatdef-grantraw)/(numdecisionsraw_judgenatdef-1)

*mean grant rate per judge x lawyer
egen meangrant_judgelawyer=mean(grant), by(ij_court_code lawyer)
egen numdecisions_judgelawyer=count(grant), by(ij_court_code lawyer)
g lomeangrant_judgelawyer=(numdecisions_judgelawyer*meangrant_judgelawyer-grant)/(numdecisions_judgelawyer-1)

egen meangrantraw_judgelawyer=mean(grantraw), by(ij_court_code lawyer)
egen numdecisionsraw_judgelawyer=count(grantraw), by(ij_court_code lawyer)
g lomeangrantraw_judgelawyer=(numdecisionsraw_judgelawyer*meangrantraw_judgelawyer-grantraw)/(numdecisionsraw_judgelawyer-1)

*nat defensive court ids
egen natcourtcode=group(natid courtid)
egen natdefcode=group(natid defensive)
egen natdefcourtcode=group(natid defensive courtid)

*grant means and deviation from court means
egen courtmeanyear=mean(grantraw), by(year courtid)
egen courtmeannatyear=mean(grantraw), by(year natcourtcode)
egen courtmeannatdefyear=mean(grantraw), by(year natdefcourtcode)

egen judgemeanyear=mean(grantraw), by(year ij_court_code)
egen judgemeannatyear=mean(grantraw), by(year ij_court_code natid)
egen judgemeannatdefyear=mean(grantraw), by(year ij_court_code natid defensive)

egen judgenumdecyear=count(grantraw), by(year ij_court_code)
egen judgenumdecnatyear=count(grantraw), by(year ij_court_code natid)
egen judgenumdecnatdefyear=count(grantraw), by(year ij_court_code natid defensive)

g lojudgemeanyear=(judgemeanyear*judgenumdecyear-grantraw)/(judgenumdecyear-1)
g lojudgemeannatyear=(judgemeannatyear*judgenumdecnatyear-grantraw)/(judgenumdecnatyear-1)
g lojudgemeannatdefyear=(judgemeannatdefyear*judgenumdecnatdefyear-grantraw)/(judgenumdecnatdefyear-1)

g difmeanyear=lojudgemeanyear-courtmeanyear
g difmeannatyear=lojudgemeannatyear-courtmeannatyear
g difmeannatdefyear=lojudgemeannatdefyear-courtmeannatdefyear

g absdifmeanyear=abs(lojudgemeanyear-courtmeanyear)
g absdifmeannatyear=abs(lojudgemeannatyear-courtmeannatyear)
g absdifmeannatdefyear=abs(lojudgemeannatdefyear-courtmeannatdefyear)

g outliermeanyear=absdifmeanyear>.1 if absdifmeanyear!=.
g outliermeannatyear=absdifmeannatyear>.2 if absdifmeannatyear!=.
g outliermeannatdefyear=absdifmeannatdefyear>.2 if absdifmeannatdefyear!=.

g negoutliermeanyear=difmeanyear<-.1 if difmeanyear!=.
g negoutliermeannatyear=difmeannatyear<-.2 if difmeannatyear!=.
g negoutliermeannatdefyear=difmeannatdefyear<-.2 if difmeannatdefyear!=.

g moderategrantrawnatdef=(lojudgemeannatdefyear>=.3 & lojudgemeannatdefyear<=.7)

*misc dummies
g samenat = (natid==L1.natid)
g haseoir=eoirattyid!=.
g samedefensive=defensive==L1.defensive

*streaks
g grantgrant=(L2grant==1 & L1grant==1) if L1grant!=. & L2grant!=.
g grantdeny=(L2grant==1 & L1grant==0) if L1grant!=. & L2grant!=.
g denygrant=(L2grant==0 & L1grant==1) if L1grant!=. & L2grant!=.
g denydeny=(L2grant==0 & L1grant==0) if L1grant!=. & L2grant!=.
assert grantgrant+grantdeny+denygrant+denydeny==1 if L1grant!=. & L2grant!=.

*coarse time of day fixed effects
g hour_start=floor(adj_time_start/100)
gen morning = adj_time_start < 1200
gen lunchtime = adj_time_start >= 1200 &  adj_time_start <= 1400
gen afternoon = adj_time_start > 1400

*number of cases
egen numcases_judgeday=count(grantraw), by(ij_court_code comp_date)
egen numcases_judge=count(grantraw), by(ij_court_code)
egen numcases_court=count(grantraw), by(courtid)
egen numcases_court_hearing=count(grantraw), by(courtid hearing_loc_code)

egen avgnumanycasesperday = mean(numanycasesperday), by(year ij_court_code)
egen avgnumasylumcasesperday = mean(numasylumcasesperday), by(year ij_court_code)
egen avgnumpeopleperday = mean(numpeopleperday), by(year ij_court_code)
egen avgnumfamsperday = mean(numfamsperday), by(year ij_court_code)



*merge judge biographies
merge m:1 ij_code using "${path_cleandata}bios_clean2.dta"
drop if _merge==2
drop _merge

xtset ij_court_code order_raw

g experience=year-Year_Appointed_SLR
replace experience=. if experience<0
g experience8=experience>=8 if experience!=.

gen log_experience = log(experience+1)
gen log_gov_experience = log(Government_Years_SLR+1)
gen log_INS_experience = log(INS_Years_SLR+1)
gen log_military_experience = log(Military_Years_SLR+1)
gen log_private_experience = log(Privateprac_Years_SLR+1)
gen log_academic_experience = log(Academia_Years_SLR+1)

g govD=(Government_Years_SLR>0) if Government_Years_SLR!=.
g INSD=(INS_Years_SLR>0) if INS_Years_SLR!=.
g militaryD=(Military_Years_SLR>0) if Military_Years_SLR!=.
g privateD=(Privateprac_Years_SLR>0) if Privateprac_Years_SLR!=.
g academicD=(Academia_Years_SLR>0) if Academia_Years_SLR!=.

g democrat=(President_SLR=="Carter" | President_SLR=="Clinton" | President_SLR=="Ford" | President_SLR=="Johnson" | President_SLR=="Obama") if President_SLR!=""
g republican=democrat==0 if democrat!=.

xtset ij_court_code order_raw
compress
save "${path_cleandata}asylum_clean_`source'_`family'_`decis'.dta", replace

}
}
}

capture log close

