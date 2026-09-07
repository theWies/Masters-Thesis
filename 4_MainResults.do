******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Results
******************************************************************************************
******************************************************************************************
******************************************************************************************

* This .do is used to produce the results from the data using the SCM

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Figure 2 - GDPpc Results (Core)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* GDPpc growth rate
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

******************************************************************************************
* Identifier start of a new episode for Core Populists
gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen Pol_`i' = "L" if CoreTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
	* Omitted since no 15-10 year pre period (Meciar)
	
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = var - var[1]
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	
	if inlist(`i', 3, 14, 21, 25) {
		xtset cid ti
		* For panel analysis
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
		* ereturn list
		* SCM	
	}
	else {
		xtset cid ti
		* For panel analysis
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
		* ereturn list
		* SCM
	}
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
		
	cap twoway ///
	(scatter _Y_treated time_rel, sort c(l) clp(l) ms(i) clc(black) mc(black) clw(thick)) ///
	(scatter _Y_synthetic time_rel, sort c(l) clp(dot) ms(i) clc(black) mc(black) clw(thick)), ///
	legend(rows(1) order(1 "Populist" 2 "Synthetic") region(lstyle(none))) ///
	xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) /// 
	ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
	ytitle("", size(medsmall) margin(medium)) /// 
	xtitle("") ///
	title(" `tmp' (`y')") ///
	xline(0, lpattern(dot) lcolor(black)) ///
	xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
	* create plot for each populist
	
	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c', replace	
	* Creates a save for each treatment and calls it _year_cid
	graph export "Figures/Individual_Core_GDPpc/_`y'_`c'.pdf", replace
	graph save "_`p'_`y'_`c'.gph", replace
	* save each plot
	
	restore
	* Restore so loop can continue back up
}


cap !del _data
cap !rm _data.dta
clear

******************************************************************************************
******************************************************************************************
* Append data into one set

* All Core Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _temp, replace
				restore
				sleep 5
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Core Cases
local allfiles : dir . files "_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _L_temp, replace
				restore
				sleep 5
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Core Cases
local allfiles : dir . files "_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _R_temp, replace
				restore
				sleep 5
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "2_Core_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "2_Core_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _L_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap data
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "2_LeftCore_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "2_LeftCore_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _R_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1994_29"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "2_RightCore_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "2_RightCore_GDPpc_gap_average.gph", replace

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "2_Core_GDPpc_average" "2_LeftCore_GDPpc_average" "2_RightCore_GDPpc_average" ///
"2_Core_GDPpc_gap_average" "2_LeftCore_GDPpc_gap_average" "2_RightCore_GDPpc_gap_average"
gr export Figures/2_Core_GDPpc.pdf, replace

cap erase "2_Core_GDPpc_average.gph"
cap erase "2_LeftCore_GDPpc_average.gph"
cap erase "2_RightCore_GDPpc_average.gph"
cap erase "2_Core_GDPpc_gap_average.gph"
cap erase "2_LeftCore_GDPpc_gap_average.gph"
cap erase "2_RightCore_GDPpc_gap_average.gph"

clear

******************************************************************************************
******************************************************************************************
* Create graph for all individual core populists

local files : dir "." files "_*.gph"

local graphlist
local n = 1
foreach f of local files {
    graph use "`f'", name(g`n', replace)
    local graphlist `graphlist' g`n'
    local ++n
}

graph combine `graphlist', iscale(0.25) graphregion(color(white) margin(small)) cols(6) xsize(7) ysize(9)
gr export Figures/Append_3_Individual_Core_GDPpc.pdf, replace


cap erase "_*.gph"

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Table 6 - Treatment and Doppelganger similarities

* More or less from the replication package of Schularik but put into my framework
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* Growth rates and Naming
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

gen d_R = Inflation

gen lg_DebtShare = log(DebtShare)
gen D = lg_DebtShare

rename Institution_Index I
rename FinCrisis F 

drop lg_*

******************************************************************************************
* Identifier start of a new episode for Core Populists
gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
*
foreach i of local TakeID {
	
	if `i' == 30 continue
	* Omitted since no 15-10 year pre period (Meciar) - no enough data
	
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	drop ipo_var 
	* Exclude War time values and instead use interpolation values
	
	foreach x in var I F D{ 
		bys cid: ipolate `x' year, gen(ipo_`x') 
		replace `x' = ipo_`x' if ipo_`x'!=. & `x'==. 
		gsort cid -year
		bys cid: replace `x' = `x'[_n-1] if `x'==.	
	}
	* Interpolate other variables
	
	bys cid (refyear_`i'): gen d = var - var[1]
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	bys cid (refyear_`i'): gen d_I = I - I[1]
	bys cid (d_I): drop if missing(d_I[_N]) & cid != tcid_`i'
*	bys cid (refyear_`i'): gen d_R = R - R[1]
	bys cid (d_R): drop if missing(d_R[_N]) & cid != tcid_`i'
	bys cid (refyear_`i'): gen d_D = D - D[1]
	bys cid (d_D): drop if missing(d_D[_N]) & cid != tcid_`i'
	* Creates change rates of Institution_Index, Inflation rate and DebtShare
	
	bys cid : egen Fyn = max(F) if (tyear_`i' > year) & (year >= (tyear_`i' - 5))    
	bys cid : egen mFyn = max(Fyn) 
	bys cid (mFyn): drop if missing(mFyn[_N]) & cid != tcid_`i'
	* Creates probability of having Financial Crisis 5 years prior to treatment
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	xtset cid ti
	* For panel analysis
	
	cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14) d(15) d_I(0) d_I(1) d_I(2) d_I(3) d_I(4) d_I(5) d_I(6) d_I(7) d_I(8) d_I(9) d_I(10) d_I(11) d_I(12) d_I(13) d_I(14) d_I(15) d_R(0) d_R(1) d_R(2) d_R(3) d_R(4) d_R(5) d_R(6) d_R(7) d_R(8) d_R(9) d_R(10) d_R(11) d_R(12) d_R(13) d_R(14) d_R(15) d_D(0) d_D(1) d_D(2) d_D(3) d_D(4) d_D(5) d_D(6) d_D(7) d_D(8) d_D(9) d_D(10) d_D(11) d_D(12) d_D(13) d_D(14) d_D(15) mFyn(15), trp(20) tru(`c') unitnames(country) k(_data, replace)	
		
	matrix matrixbalance = e(X_balance)
	svmat matrixbalance
	rename matrixbalance1 Treated
	rename matrixbalance2 Synthetic
	gen DonorPool = .
	gen Predictor=""
	
	gen dpoolof_d = .
	gen dpoolof_d_I = .
	gen dpoolof_d_R = .
	gen dpoolof_d_D = .
	gen dpoolof_mFyn = .

	foreach k in d d_I d_R d_D mFyn {

		forvalues l = 0/14 { 
			egen dpool_`k'`l' = mean(`k') if ti == `l' & cid!=tcid_`i'
			egen mdpool_`k'`l' = max(dpool_`k'`l') 
		}
	}
		
	forvalues l = 0/14 { 
		replace dpoolof_d = mdpool_d`l'  if _n==`l'+1
		replace dpoolof_d_I = mdpool_d_I`l'  if _n==`l'+16
		replace dpoolof_d_R = mdpool_d_R`l'  if _n==`l'+31
		replace dpoolof_d_D = mdpool_d_D`l'  if _n==`l'+46
		cap replace dpoolof_mFyn = mdpool_mFyn`l'  if _n==`l'+ 61
	}
	
	replace DonorPool = dpoolof_d in 1/16
	replace DonorPool = dpoolof_d_I in 17/32 
	replace DonorPool = dpoolof_d_R in 33/48	
	replace DonorPool = dpoolof_d_D in 49/64
	replace DonorPool = dpoolof_mFyn in 65/65

	gen time_d = _n-1 in 1/16
	gen time_I = _n-16 in 17/32
	gen time_R = _n-31 in 33/48
	gen time_D = _n-46 in 49/64
	tostring time_*, replace

	replace Predictor="GDP" + time_d in 1/16
	replace Predictor="Institutions" + time_I  in 17/32
	replace Predictor="Inflation" + time_R  in 33/48
	replace Predictor="DebtShare" + time_D in 49/64
	replace Predictor="Financial crises" in 65/65
	
	save _`y'_`c'.dta

	restore
}

cap !del _data
cap !rm _data.dta
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				save _temp, replace
				restore
		append using _temp, force
} 

drop if Synthetic==. | Treated==. 
cap !del _*
cap !rm _*.dta

replace Predictor = "GDP" if strpos(Predictor, "GDP") >0
replace Predictor = "Institutions" if strpos(Predictor, "Institutions") >0
replace Predictor = "Inflation" if strpos(Predictor, "Inflation") >0
replace Predictor = "DebtShare" if strpos(Predictor, "DebtShare") >0
replace Predictor = "Financial crises" if strpos(Predictor, "Financial") >0

collapse (mean) Treated Synthetic DonorPool , by(Predictor)

gen rank = 1 if Predictor=="GDP" 
replace rank = 2 if Predictor=="Institutions" 
replace rank = 3 if Predictor=="Inflation"
replace rank = 4 if Predictor=="DebtShare"
replace rank = 5 if Predictor=="Financial crises" 

sort rank
 
gen sTreated = string(Treated, "%04.3f") 
gen sSynthetic = string(Synthetic, "%04.3f") 
gen sDonorPool = string(DonorPool, "%04.3f")
drop Treated Synthetic DonorPool rank
rename (sTreated sSynthetic sDonorPool) (Treated Synthetic DonorPool)
texsave * using Tables/7_MainCoreGDPComparison.tex, replace

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Append - GDPpc Results (Borderline)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* GDPpc growth rate
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

******************************************************************************************
* Identifier start of a new episode for Border Populists
gen episode = 0
replace episode = 1 if BorderTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if BorderPop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if BorderTake==1
	gen treatedcid_`i' = cid if BorderTake==1
	gen Name_`i' = Leaders if BorderTake==1
	gen Pol_`i' = "L" if BorderTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightBorderTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 59 continue
	* Omitted since no 15-10 year pre period (Meciar)
		
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if BorderPop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = var - var[1]
	drop if d == . & WorldWar==1
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	xtset cid ti
	* For panel analysis
	
	if inlist(`i', 9, 22, 48) {
	cap synth d d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	
	else{
	cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)	
	}
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
	
	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c', replace	
	* Creates a save for each treatment and calls it _year_cid

	
	restore
	* Restore so loop can continue back up
}


cap !del _data
cap !rm _data.dta
clear

******************************************************************************************
******************************************************************************************
* Append data into one set

* All Borderline Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _temp, replace
				restore
				sleep 7
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Borderline Cases
local allfiles : dir . files "_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _L_temp, replace
				restore
				sleep 7
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Borderline Cases
local allfiles : dir . files "_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _R_temp, replace
				restore
				sleep 7
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Border
use _append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All borderline populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "4_Border_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All borderline populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "4_Border_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Left Border
use _L_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap data
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "4_LeftBorder_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "4_LeftBorder_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Right Border
use _R_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1994_29"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "4_RightBorder_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "4_RightBorder_GDPpc_gap_average.gph", replace

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "4_Border_GDPpc_average" "4_LeftBorder_GDPpc_average" "4_RightBorder_GDPpc_average" ///
"4_Border_GDPpc_gap_average" "4_LeftBorder_GDPpc_gap_average" "4_RightBorder_GDPpc_gap_average"
gr export Figures/Append_4_Border_GDPpc.pdf, replace

cap erase "4_Border_GDPpc_average.gph"
cap erase "4_LeftBorder_GDPpc_average.gph"
cap erase "4_RightBorder_GDPpc_average.gph"
cap erase "4_Border_GDPpc_gap_average.gph"
cap erase "4_LeftBorder_GDPpc_gap_average.gph"
cap erase "4_RightBorder_GDPpc_gap_average.gph"

clear

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Append - GDPpc Results (Extended)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* GDPpc growth rate
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

******************************************************************************************
* Identifier start of a new episode for Ext Populists
gen episode = 0
replace episode = 1 if ExtTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if ExtPop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if ExtTake==1
	gen treatedcid_`i' = cid if ExtTake==1
	gen Name_`i' = Leaders if ExtTake==1
	gen Pol_`i' = "L" if ExtTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightExtTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if inlist(`i', 54, 60, 74, 92, 93) continue
	* Omitted since no 15-10 year pre period (Medero, Billinghurst, Meciar, Battle)
		
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if ExtPop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = var - var[1]
	drop if d == . & WorldWar==1
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	xtset cid ti
	* For panel analysis
	
	if inlist(`i', 1, 13, 26, 29, 35, 55, 61, 62, 72, 85) {
	cap synth d d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	
	else{
	cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)	
	}
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
	
	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c', replace	
	* Creates a save for each treatment and calls it _year_cid

	
	restore
	* Restore so loop can continue back up
}


cap !del _data
cap !rm _data.dta
clear

******************************************************************************************
******************************************************************************************
* Append data into one set

* All Extended Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _temp, replace
				restore
				sleep 5
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Extended Cases
local allfiles : dir . files "_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _L_temp, replace
				restore
				sleep 5
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Extended Cases
local allfiles : dir . files "_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _R_temp, replace
				restore
				sleep 5
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Ext
use _append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All extended populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "5_Ext_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All extended populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "5_Ext_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Left Ext
use _L_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap data
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "5_LeftExt_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "5_LeftExt_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Right Ext
use _R_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1994_29"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "5_RightExt_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "5_RightExt_GDPpc_gap_average.gph", replace

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "5_Ext_GDPpc_average" "5_LeftExt_GDPpc_average" "5_RightExt_GDPpc_average" ///
"5_Ext_GDPpc_gap_average" "5_LeftExt_GDPpc_gap_average" "5_RightExt_GDPpc_gap_average"
gr export Figures/Append_5_Ext_GDPpc.pdf, replace

cap erase "5_Ext_GDPpc_average.gph"
cap erase "5_LeftExt_GDPpc_average.gph"
cap erase "5_RightExt_GDPpc_average.gph"
cap erase "5_Ext_GDPpc_gap_average.gph"
cap erase "5_LeftExt_GDPpc_gap_average.gph"
cap erase "5_RightExt_GDPpc_gap_average.gph"

clear

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Figure 3 - CountryPlacebos GDPpc (Core)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* GDPpc growth rate
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

******************************************************************************************
* Identifier start of a new episode for Core Populists
gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen Pol_`i' = "L" if CoreTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
	* Omitted since no 15-10 year pre period (Meciar)
	
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = (var - var[1])*100
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
 	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	xtset cid ti
	* For panel analysis
	
	cap synth_runner d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trperiod(20) trunit(`c') gen_vars ci keep(_data) replace 
	

	use _data, clear 
	* use synthetic control data

	gen time_rel = ti - 20 
	* create time code for Graphic
	
	drop if cid==`c'
	
	egen _gapsd = sd(effect) if time_rel >=-20 & time_rel<=-5, by(cid)
	
	collapse (mean) effect _gapsd, by(time_rel)
	
	egen gapsd = max(_gapsd)
	drop _*
	gen low_gapsd = effect - gapsd
	gen high_gapsd = effect + gapsd
	drop gapsd

	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c', replace	
	* Creates a save for each treatment and calls it _year_cid

	
	restore
	* Restore so loop can continue back up
}


cap !del _data
cap !rm _data.dta
clear


******************************************************************************************
******************************************************************************************
* Append data into one set

* All Core Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _temp, replace
				restore
				sleep 5
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Core Cases
local allfiles : dir . files "_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _L_temp, replace
				restore
				sleep 5
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Core Cases
local allfiles : dir . files "_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _R_temp, replace
				restore
				sleep 5
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _append_synth, clear

keep effect low_gapsd high_gapsd time_rel ca

* Create means over all doppelgangers with standard deviations
egen _gapmean = mean(effect), by(time_rel)
egen _l_gapsd = mean(low_gapsd), by(time_rel)
egen _h_gapsd = mean(high_gapsd), by(time_rel)

******************************************************************************************
* only one
drop if ca!="1998_42"

******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _h_gapsd _l_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All placebos") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "3_Core_Placebo_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All LeftCore
use _L_append_synth, clear

keep effect low_gapsd high_gapsd time_rel ca

* Create means over all doppelgangers with standard deviations
egen _gapmean = mean(effect), by(time_rel)
egen _l_gapsd = mean(low_gapsd), by(time_rel)
egen _h_gapsd = mean(high_gapsd), by(time_rel)

******************************************************************************************
* only one
drop if ca!="1998_42"

******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _h_gapsd _l_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All left placebos") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "3_LeftCore_Placebo_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All RightCore
use _R_append_synth, clear

keep effect low_gapsd high_gapsd time_rel ca

* Create means over all doppelgangers with standard deviations
egen _gapmean = mean(effect), by(time_rel)
egen _l_gapsd = mean(low_gapsd), by(time_rel)
egen _h_gapsd = mean(high_gapsd), by(time_rel)

******************************************************************************************
* only one
drop if ca!="1994_29"

******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _h_gapsd _l_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All right placebos") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "3_RightCore_Placebo_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _R_append_synth
cap !rm _R_append_synth.dta
clear


graph combine "3_Core_Placebo_GDPpc_gap_average" "3_LeftCore_Placebo_GDPpc_gap_average" "3_RightCore_Placebo_GDPpc_gap_average", ///
    rows(1) cols(3) ///
    xsize(18) ysize(4) ///
    iscale(1) ///
    graphregion(margin(1))
	
gr export Figures/3_CountryPlacebo_Core_GDPpc.pdf, replace

cap erase "3_Core_Placebo_GDPpc_gap_average.gph"
cap erase "3_LeftCore_Placebo_GDPpc_gap_average.gph"
cap erase "3_RightCore_Placebo_GDPpc_gap_average.gph"

cap !del _*
cap !rm _*.dta

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Figure 4 - GDPpc Results (DonorRestriction - Advanced/Emerging) -> 1 = Advanced and 0 = Emerging
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* GDPpc growth rate
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

******************************************************************************************
* Identifier start of a new episode for Core Populists
gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen str10 Pol_`i' = "L" if CoreTake==1
	gen str10 Adv_`i' = "A" if advanced==1 
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "" if treatedcid_`i' == .
	replace Adv_`i' = "E" if advanced==0
	replace Adv_`i' = "" if episode_ID !=`i'
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	egen tAdv_`i' = mode(Adv_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
	* Omitted since no 15-10 year pre period (Meciar)
	
	* Advanced Economies
if tAdv_`i'=="A" {
		
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	drop if advanced==0
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = var - var[1]
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	sum tAdv_`i'
	local a = tAdv_`i'
	* Identifyer for Advanced Economy
	
	if inlist(`i', 3, 14, 25) {
		xtset cid ti
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
	
	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c'_`a', replace	
	* Creates a save for each treatment and calls it _year_cid
	
	restore
	* Restore so loop can continue back up	
}
	
	* Emerging economies
if tAdv_`i'=="E" {
	
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	drop if advanced==1
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = var - var[1]
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	sum tAdv_`i'
	local a = tAdv_`i'
	* Identifyer for Advanced Economy
	
	if inlist(`i', 3, 14, 25) {
		xtset cid ti
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
	
	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c'_`a', replace	
	* Creates a save for each treatment and calls it _year_cid
	
	restore
	* Restore so loop can continue back up
}

}

cap !del _data
cap !rm _data.dta
clear

******************************************************************************************
******************************************************************************************
* Append data into one set

* All Core Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _temp, replace
				restore
				sleep 7
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Core Cases
local allfiles : dir . files "_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _L_temp, replace
				restore
				sleep 7
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Core Cases
local allfiles : dir . files "_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _R_temp, replace
				restore
				sleep 7
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "4_DonorRestr_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "4_DonorRestr_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _L_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap data
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "4_LeftDonorRestr_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "4_LeftDonorRestr_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _R_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1994_29"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "4_RightDonorRestr_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "4_RightDonorRestr_GDPpc_gap_average.gph", replace

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "4_DonorRestr_GDPpc_average" "4_LeftDonorRestr_GDPpc_average" "4_RightDonorRestr_GDPpc_average" ///
"4_DonorRestr_GDPpc_gap_average" "4_LeftDonorRestr_GDPpc_gap_average" "4_RightDonorRestr_GDPpc_gap_average"
gr export Figures/4_DonorRestr_GDPpc.pdf, replace

cap erase "4_DonorRestr_GDPpc_average.gph"
cap erase "4_LeftDonorRestr_GDPpc_average.gph"
cap erase "4_RightDonorRestr_GDPpc_average.gph"
cap erase "4_DonorRestr_GDPpc_gap_average.gph"
cap erase "4_LeftDonorRestr_GDPpc_gap_average.gph"
cap erase "4_RightDonorRestr_GDPpc_gap_average.gph"

clear

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Figure 4 - GDPpc Results (DonorRestriction - Omit Treated Continent) 
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* GDPpc growth rate
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

******************************************************************************************
* Identifier start of a new episode for Core Populists
gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen str10 Pol_`i' = "L" if CoreTake==1
	gen Cont_`i' = Continent if CoreTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "" if treatedcid_`i' == .
	replace Cont_`i' = "" if treatedcid_`i' != cid
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	egen tCont_`i' = mode(Cont_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
	* Omitted since no 15-10 year pre period (Meciar)
		
	preserve 
	* So not to delete within the loop
	
	drop if Continent == tCont_`i' & tcid_`i' != cid
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = var - var[1]
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 3, 4, 14, 21, 25) {
		xtset cid ti
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
	
	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c'_`a', replace	
	* Creates a save for each treatment and calls it _year_cid
	
	restore
	* Restore so loop can continue back up	
}


cap !del _data
cap !rm _data.dta
clear

******************************************************************************************
******************************************************************************************
* Append data into one set

* All Core Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _temp, replace
				restore
				sleep 7
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Core Cases
local allfiles : dir . files "_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _L_temp, replace
				restore
				sleep 7
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Core Cases
local allfiles : dir . files "_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 7
				save _R_temp, replace
				restore
				sleep 7
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "5_DonorOmitCont_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "5_DonorOmitCont_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _L_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap data
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "5_LeftDonorOmitCont_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "5_LeftDonorOmitCont_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _R_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1994_29"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "5_RightDonorOmitCont_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "5_RightDonorOmitCont_GDPpc_gap_average.gph", replace

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "5_DonorOmitCont_GDPpc_average" "5_LeftDonorOmitCont_GDPpc_average" "5_RightDonorOmitCont_GDPpc_average" ///
"5_DonorOmitCont_GDPpc_gap_average" "5_LeftDonorOmitCont_GDPpc_gap_average" "5_RightDonorOmitCont_GDPpc_gap_average"
gr export Figures/5_DonorOmitCont_GDPpc.pdf, replace

cap erase "5_DonorOmitCont_GDPpc_average.gph"
cap erase "5_LeftDonorOmitCont_GDPpc_average.gph"
cap erase "5_RightDonorOmitCont_GDPpc_average.gph"
cap erase "5_DonorOmitCont_GDPpc_gap_average.gph"
cap erase "5_LeftDonorOmitCont_GDPpc_gap_average.gph"
cap erase "5_RightDonorOmitCont_GDPpc_gap_average.gph"

clear

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Figure 6 - GDPpc Results with multiple Covariates (Core)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* Growth rates and Naming
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

gen d_R = Inflation

rename Institution_Index I

rename FinCrisis F 

drop lg_*
******************************************************************************************
* Identifier start of a new episode for Core Populists
gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen Pol_`i' = "L" if CoreTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************

foreach i of local TakeID {
	
	if inlist(`i', 30, 31) continue
	* Omitted since no 15-10 year pre period (Meciar) - no enough data
	
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	drop ipo_var 
	* Exclude War time values and instead use interpolation values
	
	foreach x in var I F { 
		bys cid: ipolate `x' year, gen(ipo_`x') 
		replace `x' = ipo_`x' if ipo_`x'!=. & `x'==. 
		gsort cid -year
		bys cid: replace `x' = `x'[_n-1] if `x'==.	
	}
	* Interpolate other variables
	
	bys cid (refyear_`i'): gen d = var - var[1]
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	bys cid (refyear_`i'): gen d_I = I - I[1]
	bys cid (d_I): drop if missing(d_I[_N]) & cid != tcid_`i'
*	bys cid (refyear_`i'): gen d_R = R - R[1]
	bys cid (d_R): drop if missing(d_R[_N]) & cid != tcid_`i'
	
	bys cid : egen Fyn = max(F) if (tyear_`i' > year) & (year >= (tyear_`i' - 5))    
	bys cid : egen mFyn = max(Fyn) 
	bys cid (mFyn): drop if missing(mFyn[_N]) & cid != tcid_`i'
	* Creates probability of having Financial Crisis 5 years prior to treatment
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	xtset cid ti
	* For panel analysis
	
	if inlist(`i', 14, 26, 37) {
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14) d(15) d_I(0(1)15) d_R(0(1)15) mFyn(15), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14) d(15) d_I(0(1)15) d_R(0(1)15) mFyn(15), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	
	* d_I(1) d_I(2) d_I(3) d_I(4) d_I(5) d_I(6) d_I(7) d_I(8) d_I(9) d_I(10) d_I(11) d_I(12) d_I(13) d_I(14) d_I(15)
	* d_R(1) d_R(2) d_R(3) d_R(4) d_R(5) d_R(6) d_R(7) d_R(8) d_R(9) d_R(10) d_R(11) d_R(12) d_R(13) d_R(14) d_R(15)
		
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
	
	gen ca = "`y'_`c'"
	sav _`p'_`y'_`c', replace	
	* Creates a save for each treatment and calls it _year_cid

	
	restore
	* Restore so loop can continue back up
}


cap !del _data
cap !rm _data.dta
clear

******************************************************************************************
******************************************************************************************
* Append data into one set

* All Core Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _temp, replace
				restore
				sleep 5
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Core Cases
local allfiles : dir . files "_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _L_temp, replace
				restore
				sleep 5
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Core Cases
local allfiles : dir . files "_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _R_temp, replace
				restore
				sleep 5
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "6_MoreCov_Core_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "6_MoreCov_Core_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _L_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap data
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1998_42"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "6_MoreCov_LeftCore_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "6_MoreCov_LeftCore_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _R_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-20 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1994_29"


******************************************************************************************
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "6_MoreCov_RightCore_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "6_MoreCov_RightCore_GDPpc_gap_average.gph", replace

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "6_MoreCov_Core_GDPpc_average" "6_MoreCov_LeftCore_GDPpc_average" "6_MoreCov_RightCore_GDPpc_average" ///
"6_MoreCov_Core_GDPpc_gap_average" "6_MoreCov_LeftCore_GDPpc_gap_average" "6_MoreCov_RightCore_GDPpc_gap_average"
gr export Figures/6_MoreCov_Core_GDPpc.pdf, replace

cap erase "6_MoreCov_Core_GDPpc_average.gph"
cap erase "6_MoreCov_LeftCore_GDPpc_average.gph"
cap erase "6_MoreCov_RightCore_GDPpc_average.gph"
cap erase "6_MoreCov_Core_GDPpc_gap_average.gph"
cap erase "6_MoreCov_LeftCore_GDPpc_gap_average.gph"
cap erase "6_MoreCov_RightCore_GDPpc_gap_average.gph"

clear

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

sleep 10

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Figure 7 - GDPpc Results (Core) - Partially Pooled SCM
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* GDPpc growth rate
gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

******************************************************************************************
* Identifier start of a new episode for Core Populists
gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen Pol_`i' = "L" if CoreTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* generating individual weights
foreach i of local TakeID {
	
	if `i' == 30 continue
	* Omitted since no 15-10 year pre period (Meciar)
	
	preserve 
	* So not to delete within the loop
	
	bys cid (year): gen TreatCountry = 0
	replace TreatCountry = 1 if CorePop == 1 & cid != tcid_`i'
	bysort cid (year): egen TreatCountryCID = max(TreatCountry)
	drop if TreatCountryCID == 1
	* Omitting all treated countries in the observation period
	
	bys cid (refyear_`i'): keep if year >= tyear_`i' - 20 & year <= tyear_`i' + 15
	bys cid (refyear_`i'): gen ti = year - tyear_`i' + 20
	* Create the 15 year timeframe with time index for easier synthetic control
	
	replace var = . if WorldWar == 1
	bys cid (refyear_`i'): ipolate var year, gen(ipo_var)
	replace var = ipo_var if WorldWar==1 & var==.
	* Exclude War time values and instead use interpolation values
	
	bys cid (refyear_`i'): gen d = var - var[1]
	bys cid (d): drop if missing(d[_N]) & cid != tcid_`i'
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	save _DD_`i', replace
	
	if inlist(`i', 3, 14, 21, 25) {
		xtset cid ti
		* For panel analysis
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
		* ereturn list
		* SCM	
	}
	else {
		xtset cid ti
		* For panel analysis
		cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
		* ereturn list
		* SCM
	}
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
	replace _Y_treated = _Y_treated * 100
	replace _Y_synthetic = _Y_synthetic * 100
	* Convert to percentage
		
	gen ca = "`y'_`c'"
	save _individual_`i', replace	
	* Creates a save for each treatment and calls it _year_cid
	
	restore
	* Restore so loop can continue back up
}


cap !del _data
cap !rm _data.dta
clear

******************************************************************************************
******************************************************************************************
* Building the pooled treated unit

* All Core Cases
local allfiles : dir . files "_individual_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _temp, replace
				restore
				sleep 5
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

* Pooled Unit
use _append_synth, clear

* create mean and mergable units
keep _Y_treated _time 
collapse (mean) _Y_treated, by(_time)
rename _time ti
rename _Y_treated d
replace d = d/100

* create cid for pooled unit
gen cid = 9999
gen country = "Pooled"
drop if missing(ti)

save _pooled_unit, replace

clear

cap !del _append_synth
cap !rm _append_synth.dta


******************************************************************************************
******************************************************************************************
* Generating pooled weights (have to run identification loop for TakeID again...)

use Master_Data, clear

gen lg_realGDPpc = log(realGDPpc)
gen var = lg_realGDPpc

gen episode = 0
replace episode = 1 if CoreTake == 1 
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == .

levelsof episode_ID, local(TakeID)
* Identification local for loop

foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen Pol_`i' = "L" if CoreTake==1
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
}

******************************************************************************************
******************************************************************************************
* pooled SCM with individual donor pools
foreach i of local TakeID {
	
	if `i' == 30 continue
	* drop Meciar
	
	preserve
	
	* Merge pooled unit into data
	use _DD_`i', clear
	
	summarize ti
	local ti_min = r(min)
	local ti_max = r(max)

	merge 1:1 cid ti using _pooled_unit
	drop _merge
	keep if !(cid == 9999 & (ti < `ti_min' | ti > `ti_max'))
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tName_`i'
	local tmp = tName_`i'
	* Name for title in Graphic
	
	sum tPol_`i'
	local pol = tPol_`i'
	* Identifyer for Political Leaning
	
	* drop treated unit so it wont show up in the donor pool
	drop if cid == tcid_`i'
	
	xtset cid ti
	* For panel analysis
	
	if inlist(`i', 3, 14, 21, 25) {
		xtset cid ti
		* For panel analysis
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(9999) unitnames(country) k(_data, replace)
		
	}

	else {
		xtset cid ti
		* For panel analysis
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(9999) unitnames(country) k(_data, replace) nested
		
	}
	
******************************************************************************************
* Creating pooled weights datasets for each TakeID 
	use _data, clear 
	* use synthetic control data
	
*	rename _time ti
	rename _W_Weight w_pooled
	rename _Co_Number country
	
	drop _*
	drop if missing(country)
		
	save _w_pooled_`i', replace	
	* Creates a save for each treatment and calls it _year_cid
	
******************************************************************************************
* Creating individual weights datasets for each TakeID 

    use _individual_`i', clear
    rename _W_Weight w_indv
    rename _Co_Number country
    drop _* time_rel ca
	drop if missing(country)
    save _w_indv_`i', replace

	
******************************************************************************************
* Construct partially pooled weights

		use _w_pooled_`i', clear
		merge 1:1 country using _w_indv_`i'
		drop _merge

		* clean up
		replace w_indv = 0 if missing(w_indv)
		replace w_pooled = 0 if missing(w_pooled)
	
		* pooling parameter used to generate partially pooled weight
		* for 0.3, 0.5, and 0.7
		foreach lambda in 0.3 0.5 0.7 {
		local lname = subinstr("`lambda'", ".", "", .)   // strip the dot: 0.3 → 03
		gen w`lname'_ppscm = (1-`lambda')*w_indv + `lambda'*w_pooled
		}
	
		* Expand each country row 36 times (for ti = 0 to 35)
		expand 36

		* Generate ti variable
		bysort country : gen ti = _n - 1
	
		* cleanup
		drop w_pooled w_indv
		decode country, gen(country_str)
		drop country
		rename country_str country
		
		save _w_ppscm_`i', replace
	
******************************************************************************************
* Construct partially pooled doppelganger

		use _DD_`i', clear
	
		sum treatedcid_`i'
		local c = r(mean)
		* Store specific treated country cid in local c
	
		sum treatedyear_`i'
		local y = r(mean)
		* Story specific treated year in local y
	
		quietly {
		levelsof tPol_`i', local(pol) clean
		}
		* Identifyer for Political Leaning
	
		summarize ti
		local ti_min = r(min)
		local ti_max = r(max)
	
		merge 1:1 country ti using _w_ppscm_`i'
		drop _merge
		keep if !(ti < `ti_min' | ti > `ti_max')
	
		gen _Y_Treated = d*100 if cid == tcid_`i'
		gen _Y_03_Synth = d*w03_ppscm*100
		gen _Y_05_Synth = d*w05_ppscm*100
		gen _Y_07_Synth = d*w07_ppscm*100
	
		collapse (sum) _Y_03_Synth _Y_05_Synth _Y_07_Synth _Y_Treated, by(ti)
		
		* Create ca variable
		gen ca = "`y'_`c'"
		save _Y_`i'_`pol'_data, replace
	restore
}

* cap !del _data
* cap !rm _data.dta

cap !del _individual_*.dta _w_indv_*.dta _w_pooled_*.dta _Y_data_*.dta _DD_*.dta _w_ppscm_*.dta _pooled_unit.dta _data.dta
cap !rm _individual_*.dta _w_indv_*.dta _w_pooled_*.dta _Y_data_*.dta _DD_*.dta _w_ppscm_*.dta _pooled_unit.dta _data.dta

clear


******************************************************************************************
******************************************************************************************
* append into one set

* All Core Cases
local allfiles : dir . files "_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _temp, replace
				restore
				sleep 5
		append using _temp, force
} 

save _append_synth, replace

cap !del _temp
cap !rm _temp.dta

clear

******************************************************************************************
* All Left Core Cases
local allfiles : dir . files "*_L_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _L_temp, replace
				restore
				sleep 5
		append using _L_temp, force
} 

save _L_append_synth, replace

cap !del _L_temp
cap !rm _L_temp.dta

clear

******************************************************************************************
* All Right Core Cases
local allfiles : dir . files "*_R_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _R_temp, replace
				restore
				sleep 5
		append using _R_temp, force
} 

save _R_append_synth, replace

cap !del _R_temp
cap !rm _R_temp.dta

cap !del _Y_*.dta
cap !rm _Y_*.dta

clear

* Done - now business as usual

******************************************************************************************
******************************************************************************************
* Averages All Core
use _append_synth, clear

* Mean all SCMs
egen _Y_03_mean = mean(_Y_03_Synth), by(ti)
egen _Y_05_mean = mean(_Y_05_Synth), by(ti)
egen _Y_07_mean	= mean(_Y_07_Synth), by(ti)
egen _Y_treat_mean = mean(_Y_Treated), by(ti)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap03 = _Y_Treated - _Y_03_Synth
gen _gap05 = _Y_Treated - _Y_05_Synth
gen _gap07 = _Y_Treated - _Y_07_Synth

egen _gapmean03 = mean(_gap03), by(ti)
egen _gapmean05 = mean(_gap05), by(ti)
egen _gapmean07 = mean(_gap07), by(ti)

egen _gapsd03 = sd(_gap03) if ti >=0 & ti<=15, by(ca)
egen _gapsd05 = sd(_gap05) if ti >=0 & ti<=15, by(ca)
egen _gapsd07 = sd(_gap07) if ti >=0 & ti<=15, by(ca)

egen _gap03_meansd = mean(_gapsd03)
egen _gap05_meansd = mean(_gapsd05)
egen _gap07_meansd = mean(_gapsd07)

gen _low_gap03_sd = _gapmean03 - _gap03_meansd
gen _low_gap05_sd = _gapmean05 - _gap05_meansd
gen _low_gap07_sd = _gapmean07 - _gap07_meansd

gen _high_gap03_sd = _gapmean03 + _gap03_meansd
gen _high_gap05_sd = _gapmean05 + _gap05_meansd
gen _high_gap07_sd = _gapmean07 + _gap07_meansd
* Create means over all doppelganger gaps with standard deviations

******************************************************************************************
* only one
drop if ca!="1998_42"

gen time_rel = ti - 20

******************************************************************************************
* Create Graph of Average Treatment Trend effect with standard deviation
twoway ///
(line _Y_treat_mean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _Y_03_mean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_03PPSCM_Core_GDPpc_average.gph", replace

twoway ///
(line _Y_treat_mean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _Y_05_mean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_05PPSCM_Core_GDPpc_average.gph", replace

twoway ///
(line _Y_treat_mean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _Y_07_mean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("All populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_07PPSCM_Core_GDPpc_average.gph", replace

******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gap03_sd _low_gap03_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean03 time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_03PPSCM_Core_GDPpc_gap_average.gph", replace

twoway /// 
(rarea _high_gap05_sd _low_gap05_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean05 time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_05PPSCM_Core_GDPpc_gap_average.gph", replace

twoway /// 
(rarea _high_gap07_sd _low_gap07_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean07 time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("All populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_07PPSCM_Core_GDPpc_gap_average.gph", replace

******************************************************************************************
* Delete temporary data
cap !del _append_synth
cap !rm _append_synth.dta
clear

******************************************************************************************
******************************************************************************************
use _L_append_synth, clear

* Mean all SCMs
egen _Y_03_mean = mean(_Y_03_Synth), by(ti)
egen _Y_05_mean = mean(_Y_05_Synth), by(ti)
egen _Y_07_mean	= mean(_Y_07_Synth), by(ti)
egen _Y_treat_mean = mean(_Y_Treated), by(ti)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap03 = _Y_Treated - _Y_03_Synth
gen _gap05 = _Y_Treated - _Y_05_Synth
gen _gap07 = _Y_Treated - _Y_07_Synth

egen _gapmean03 = mean(_gap03), by(ti)
egen _gapmean05 = mean(_gap05), by(ti)
egen _gapmean07 = mean(_gap07), by(ti)

egen _gapsd03 = sd(_gap03) if ti >=0 & ti<=15, by(ca)
egen _gapsd05 = sd(_gap05) if ti >=0 & ti<=15, by(ca)
egen _gapsd07 = sd(_gap07) if ti >=0 & ti<=15, by(ca)

egen _gap03_meansd = mean(_gapsd03)
egen _gap05_meansd = mean(_gapsd05)
egen _gap07_meansd = mean(_gapsd07)

gen _low_gap03_sd = _gapmean03 - _gap03_meansd
gen _low_gap05_sd = _gapmean05 - _gap05_meansd
gen _low_gap07_sd = _gapmean07 - _gap07_meansd

gen _high_gap03_sd = _gapmean03 + _gap03_meansd
gen _high_gap05_sd = _gapmean05 + _gap05_meansd
gen _high_gap07_sd = _gapmean07 + _gap07_meansd
* Create means over all doppelganger gaps with standard deviations

******************************************************************************************
* only one
drop if ca!="1998_42"

gen time_rel = ti - 20

******************************************************************************************
* Create Graph of Average Treatment Trend effect with standard deviation
twoway ///
(line _Y_treat_mean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _Y_03_mean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_L_03PPSCM_Core_GDPpc_average.gph", replace

twoway ///
(line _Y_treat_mean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _Y_05_mean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_L_05PPSCM_Core_GDPpc_average.gph", replace

twoway ///
(line _Y_treat_mean time_rel, lcolor(blue) lwidth(thick) lpattern(solid)) ///
(line _Y_07_mean time_rel, lcolor(blue) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Left-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_L_07PPSCM_Core_GDPpc_average.gph", replace

******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gap03_sd _low_gap03_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean03 time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_L_03PPSCM_Core_GDPpc_gap_average.gph", replace

twoway /// 
(rarea _high_gap05_sd _low_gap05_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean05 time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_L_05PPSCM_Core_GDPpc_gap_average.gph", replace

twoway /// 
(rarea _high_gap07_sd _low_gap07_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean07 time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Left-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_L_07PPSCM_Core_GDPpc_gap_average.gph", replace

******************************************************************************************
* Delete temporary data
cap !del _L_append_synth
cap !rm _L_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
use _R_append_synth, clear

* Mean all SCMs
egen _Y_03_mean = mean(_Y_03_Synth), by(ti)
egen _Y_05_mean = mean(_Y_05_Synth), by(ti)
egen _Y_07_mean	= mean(_Y_07_Synth), by(ti)
egen _Y_treat_mean = mean(_Y_Treated), by(ti)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap03 = _Y_Treated - _Y_03_Synth
gen _gap05 = _Y_Treated - _Y_05_Synth
gen _gap07 = _Y_Treated - _Y_07_Synth

egen _gapmean03 = mean(_gap03), by(ti)
egen _gapmean05 = mean(_gap05), by(ti)
egen _gapmean07 = mean(_gap07), by(ti)

egen _gapsd03 = sd(_gap03) if ti >=0 & ti<=15, by(ca)
egen _gapsd05 = sd(_gap05) if ti >=0 & ti<=15, by(ca)
egen _gapsd07 = sd(_gap07) if ti >=0 & ti<=15, by(ca)

egen _gap03_meansd = mean(_gapsd03)
egen _gap05_meansd = mean(_gapsd05)
egen _gap07_meansd = mean(_gapsd07)

gen _low_gap03_sd = _gapmean03 - _gap03_meansd
gen _low_gap05_sd = _gapmean05 - _gap05_meansd
gen _low_gap07_sd = _gapmean07 - _gap07_meansd

gen _high_gap03_sd = _gapmean03 + _gap03_meansd
gen _high_gap05_sd = _gapmean05 + _gap05_meansd
gen _high_gap07_sd = _gapmean07 + _gap07_meansd
* Create means over all doppelganger gaps with standard deviations

******************************************************************************************
* only one
drop if ca!="1994_29"

gen time_rel = ti - 20

******************************************************************************************
* Create Graph of Average Treatment Trend effect with standard deviation
twoway ///
(line _Y_treat_mean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _Y_03_mean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_R_03PPSCM_Core_GDPpc_average.gph", replace

twoway ///
(line _Y_treat_mean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _Y_05_mean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_R_05PPSCM_Core_GDPpc_average.gph", replace

twoway ///
(line _Y_treat_mean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _Y_07_mean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("Right-wing populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)
graph save "7_R_07PPSCM_Core_GDPpc_average.gph", replace

******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gap03_sd _low_gap03_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean03 time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_R_03PPSCM_Core_GDPpc_gap_average.gph", replace

twoway /// 
(rarea _high_gap05_sd _low_gap05_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean05 time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_R_05PPSCM_Core_GDPpc_gap_average.gph", replace

twoway /// 
(rarea _high_gap07_sd _low_gap07_sd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean07 time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Right-wing populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))
graph save "7_R_07PPSCM_Core_GDPpc_gap_average.gph", replace

******************************************************************************************
* Delete temporary data
cap !del _R_append_synth
cap !rm _R_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Combine Graphs

graph combine "7_03PPSCM_Core_GDPpc_average.gph" "7_L_03PPSCM_Core_GDPpc_average.gph" "7_R_03PPSCM_Core_GDPpc_average.gph" ///
"7_03PPSCM_Core_GDPpc_gap_average.gph" "7_L_03PPSCM_Core_GDPpc_gap_average.gph" "7_R_03PPSCM_Core_GDPpc_gap_average.gph"
gr export Figures/Append_11_03PPSCM_Core_GDPpc.pdf, replace

cap erase "7_03PPSCM_Core_GDPpc_average.gph"
cap erase "7_L_03PPSCM_Core_GDPpc_average.gph"
cap erase "7_R_03PPSCM_Core_GDPpc_average.gph"
cap erase "7_03PPSCM_Core_GDPpc_gap_average.gph"
cap erase "7_L_03PPSCM_Core_GDPpc_gap_average.gph"
cap erase "7_R_03PPSCM_Core_GDPpc_gap_average.gph"

clear

graph combine "7_05PPSCM_Core_GDPpc_average.gph" "7_L_05PPSCM_Core_GDPpc_average.gph" "7_R_05PPSCM_Core_GDPpc_average.gph" ///
"7_05PPSCM_Core_GDPpc_gap_average.gph" "7_L_05PPSCM_Core_GDPpc_gap_average.gph" "7_R_05PPSCM_Core_GDPpc_gap_average.gph"
gr export Figures/7_05PPSCM_Core_GDPpc.pdf, replace

cap erase "7_05PPSCM_Core_GDPpc_average.gph"
cap erase "7_L_05PPSCM_Core_GDPpc_average.gph"
cap erase "7_R_05PPSCM_Core_GDPpc_average.gph"
cap erase "7_05PPSCM_Core_GDPpc_gap_average.gph"
cap erase "7_L_05PPSCM_Core_GDPpc_gap_average.gph"
cap erase "7_R_05PPSCM_Core_GDPpc_gap_average.gph"

clear

graph combine "7_07PPSCM_Core_GDPpc_average.gph" "7_L_07PPSCM_Core_GDPpc_average.gph" "7_R_07PPSCM_Core_GDPpc_average.gph" ///
"7_07PPSCM_Core_GDPpc_gap_average.gph" "7_L_07PPSCM_Core_GDPpc_gap_average.gph" "7_R_07PPSCM_Core_GDPpc_gap_average.gph"
gr export Figures/Append_12_07PPSCM_Core_GDPpc.pdf, replace

cap erase "7_07PPSCM_Core_GDPpc_average.gph"
cap erase "7_L_07PPSCM_Core_GDPpc_average.gph"
cap erase "7_R_07PPSCM_Core_GDPpc_average.gph"
cap erase "7_07PPSCM_Core_GDPpc_gap_average.gph"
cap erase "7_L_07PPSCM_Core_GDPpc_gap_average.gph"
cap erase "7_R_07PPSCM_Core_GDPpc_gap_average.gph"

clear

