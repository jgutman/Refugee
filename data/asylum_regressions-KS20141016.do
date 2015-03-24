/*
*******************************************************************************************************
Asylum Regressions

10/14/2014 -KS

do asylum_regressions-KS20141016.do

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
global pathDropbox = "/Volumes/RAID/Dropbox/"

global path_tblschedule = "${pathDropbox}large_files/tbl_schedule_complete.dta"
global path_rawdata = "${pathDropbox}hothand/TRAC/data/raw/"
global path_cleandata = "${pathDropbox}hothand/TRAC/data/clean/"
global log_dir = "${pathDropbox}hothand/logs/"

capture log close
log using ${log_dir}asylum_regressions-KS20141014.smcl, replace



use "${path_cleandata}asylum_clean_chicago_eoirstrictconsec3_1.dta", clear

global SAMPLERES0 = "numcases_judge>=100 & numcases_court_hearing>=1000 & year>=1985 & year<2014 & prev5_dayslaps<=30 & courtprevother5_dayslapse<=30 & flag_decisionerror_strdes!=1 & L1.flag_decisionerror_strdes!=1 & flag_earlystarttime!=1 & L1.flag_earlystarttime!=1 & flag_mismatch_base_city!=1 & L1.flag_mismatch_base_city!=1 & flag_mismatch_hearing!=1 & L1.flag_mismatch_hearing!=1"

global SAMPLERES1 = "$SAMPLERES0 & lomeangrantraw_judgenatdef>.2 & lomeangrantraw_judgenatdef<.8"

global SAMPLERES2 = "$SAMPLERES1 & defensive==L1.defensive"

global SAMPLERES3 = "$SAMPLERES2 & defensive==L2.defensive & L2.flag_earlystarttime!=1 & L2.flag_mismatch_base_city!=1 & L2.flag_mismatch_hearing!=1"

global SAMPLERES4 = "$SAMPLERES0 & defensive==L1.defensive"

global CONTROLS1 = "i.numgrant_prev5 i.numcourtgrantother_prev5 lawyer defensive numinfamily lomeangrantraw_judgenatdef morning lunchtime flag_multiple_proceedings flag_notfirstproceeding flag_multiple_proceedings2 flag_notfirstproceeding2 flag_prevprocgrant flag_prevprocdeny flag_unknowntime written difmeannatdefyear lojudgemeannatdefyear"

*flag_decisionerror_idncaseproc -- this control has a huge t-stat


/*
***baseline
eststo clear

*across days
qui eststo: areg grant L1grant $CONTROLS1 if $SAMPLERES0, absorb(natdefcode) cluster(ij_court_code)

*+moderates
qui eststo: areg grant L1grant $CONTROLS1 if $SAMPLERES1, absorb(natdefcode) cluster(ij_court_code)

*+same day
qui eststo: areg grant L1grant $CONTROLS1 if $SAMPLERES1 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*+same defensive
qui eststo: areg grant L1grant $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*+streaks (same day for L1)
qui eststo: areg grant grantgrant grantdeny denygrant $CONTROLS1 if $SAMPLERES3 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

esttab, se r2 keep(L1grant grantgrant grantdeny denygrant) starlevels(* 0.10 ** 0.05 *** 0.01)



***baseline: omitted samples
eststo clear

*-moderates
qui eststo: areg grant L1grant $CONTROLS1 if $SAMPLERES0 & !(lomeangrantraw_judgenatdef>.2 & lomeangrantraw_judgenatdef<.8), absorb(natdefcode) cluster(ij_court_code)

*-same day
qui eststo: areg grant L1grant $CONTROLS1 if $SAMPLERES1 & L1grant_sameday==0, absorb(natdefcode) cluster(ij_court_code)

*-same defensive
qui eststo: areg grant L1grant $CONTROLS1 if $SAMPLERES1 & L1grant_sameday==1 & defensive!=L1.defensive, absorb(natdefcode) cluster(ij_court_code)

esttab, se r2 keep(L1grant) starlevels(* 0.10 ** 0.05 *** 0.01)



***case hetero - same day, same defensive
eststo clear

*nationality
qui eststo: areg grant c.L1grant##c.samenat $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*moderates
qui eststo: areg grant c.L1grant##c.moderategrantrawnatdef $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*experience
qui eststo: areg grant c.L1grant##c.experience8 $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*experience with judge FE
qui eststo: areg grant c.L1grant##c.experience8 i.ij_court_code $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

esttab, se r2 keep( L1grant* c.* samenat moderategrantrawnatdef experience8) starlevels(* 0.10 ** 0.05 *** 0.01)



***insignficant heterogeneity
eststo clear

*background
qui eststo: areg grant c.L1grant##c.govD c.L1grant##c.INSD c.L1grant##c.militaryD c.L1grant##c.privateD c.L1grant##c.academicD $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*republicans
qui eststo: areg grant c.L1grant##c.republican $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*busyness
qui eststo: areg grant c.L1grant##c.numanycasesperday $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg grant c.L1grant##c.numasylumcasesperday $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg grant c.L1grant##c.numfamsperday  $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

esttab, se r2 keep(L1grant* c.*) starlevels(* 0.10 ** 0.05 *** 0.01)



***insignficant heterogeneity including extremes with grant rates below .2 or over .8
eststo clear

*background
qui eststo: areg grant c.L1grant##c.govD c.L1grant##c.INSD c.L1grant##c.militaryD c.L1grant##c.privateD c.L1grant##c.academicD $CONTROLS1 if $SAMPLERES4 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*republicans
qui eststo: areg grant c.L1grant##c.republican $CONTROLS1 if $SAMPLERES4 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

*busyness
qui eststo: areg grant c.L1grant##c.numanycasesperday $CONTROLS1 if $SAMPLERES4 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg grant c.L1grant##c.numasylumcasesperday $CONTROLS1 if $SAMPLERES4 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg grant c.L1grant##c.numfamsperday  $CONTROLS1 if $SAMPLERES4 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

esttab, se r2 keep(L1grant* c.*) starlevels(* 0.10 ** 0.05 *** 0.01)
*/






global CONTROLS2 = "lawyer defensive numinfamily written i.natdefcode"

global LAGQUALITY = "L1.quality_hat1 L2.quality_hat1 L3.quality_hat1 L4.quality_hat1 L5.quality_hat1 L6.quality_hat1 L7.quality_hat1 L8.quality_hat1 L9.quality_hat1 L10.quality_hat1"

global LAGQUALITYRESID = "L1.quality_hat1_resid L2.quality_hat1_resid L3.quality_hat1_resid L4.quality_hat1_resid L5.quality_hat1_resid L6.quality_hat1_resid L7.quality_hat1_resid L8.quality_hat1_resid L9.quality_hat1_resid L10.quality_hat1_resid"

global CONTROLS_LAW = "i.numgrant_prev5 i.numcourtgrantother_prev5 defensive numinfamily lomeangrantraw_judgenatdef morning lunchtime flag_multiple_proceedings flag_notfirstproceeding flag_multiple_proceedings2 flag_notfirstproceeding2 flag_prevprocgrant flag_prevprocdeny flag_unknowntime written difmeannatdefyear lojudgemeannatdefyear"

global CONTROLS_FAM = "i.numgrant_prev5 i.numcourtgrantother_prev5 lawyer defensive lomeangrantraw_judgenatdef morning lunchtime flag_multiple_proceedings flag_notfirstproceeding flag_multiple_proceedings2 flag_notfirstproceeding2 flag_prevprocgrant flag_prevprocdeny flag_unknowntime written difmeannatdefyear lojudgemeannatdefyear"


*predicted quality measure 1
reg grantraw lawyer defensive numinfamily written i.natdefcode
predict quality_hat1, xb
reg quality_hat1 i.year##i.courtid
predict quality_hat1_resid, resid
reg quality_hat1 i.courtid
predict quality_hat1_resid2, resid
reg quality_hat1 i.year
predict quality_hat1_resid3, resid
reg quality_hat1 i.ij_court_code
predict quality_hat1_resid4, resid


*predicted quality measure 2 using observations for other judges
egen meangrantpred=mean(grantraw), by(lawyer numinfamily written natdefcode)
egen temptotal=count(grantraw), by(lawyer numinfamily written natdefcode)
egen judgemeangrantpred=mean(grantraw), by(lawyer numinfamily written natdefcode ij_court_code)
egen tempjudgetotal=count(grantraw), by(lawyer numinfamily written natdefcode ij_court_code)
g quality_hat2=((meangrantpred*temptotal)-(judgemeangrantpred*tempjudgetotal))/(temptotal-tempjudgetotal)
reg quality_hat2 i.year##i.courtid
predict quality_hat2_resid, resid

reg quality_hat2 i.courtid
predict quality_hat2_resid2, resid
reg quality_hat2 i.year
predict quality_hat2_resid3, resid
reg quality_hat2 i.ij_court_code
predict quality_hat2_resid4, resid

*lawyer quality
egen meangrantlawyer=mean(grantraw), by(eoirattyid)
egen numcaseslawyer=count(grantraw), by(eoirattyid)
g lomeangrantlawyer=(meangrantlawyer*numcaseslawyer-grantraw)/(numcaseslawyer-1)




*FIFO TESTS
eststo clear

qui eststo: areg quality_hat1_resid L1grant $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg quality_hat2_resid L1grant $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg lomeangrantlawyer L1grant $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1 & eoirattyid!=. & numcaseslawyer>=10, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg lawyer L1grant $CONTROLS_LAW if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

qui eststo: areg numinfamily L1grant $CONTROLS_FAM if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)

esttab, se r2 keep(L1grant) starlevels(* 0.10 ** 0.05 *** 0.01)



*SCE TESTS
eststo clear

qui eststo: areg grant L1grant L1.quality_hat1_resid $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)
test L.quality_hat1_resid

qui eststo: areg grant L1grant L1.quality_hat1_resid4 $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)
test L.quality_hat1_resid4

qui eststo: areg grant L1grant L1.quality_hat2_resid $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)
test L.quality_hat2_resid

qui eststo: areg grant L1grant L1.quality_hat2_resid4 $CONTROLS1 if $SAMPLERES2 & L1grant_sameday==1, absorb(natdefcode) cluster(ij_court_code)
test L.quality_hat2_resid4

esttab, se r2 keep(L1grant *quality_hat* ) starlevels(* 0.10 ** 0.05 *** 0.01)



***positive autocorelation in predicted loan quality residuals
eststo clear

qui eststo: reg quality_hat1 $LAGQUALITY if $SAMPLERES0, cluster(ij_court_code)

qui eststo: reg quality_hat1_resid $LAGQUALITYRESID if $SAMPLERES0, cluster(ij_court_code)

qui eststo: reg quality_hat1 $LAGQUALITY if $SAMPLERES0 & comp_date!=L1.comp_date, cluster(ij_court_code)

qui eststo: reg quality_hat1_resid $LAGQUALITYRESID if $SAMPLERES0 & comp_date!=L1.comp_date, cluster(ij_court_code)

esttab, se r2 keep(*quality*) starlevels(* 0.10 ** 0.05 *** 0.01)



capture log close







