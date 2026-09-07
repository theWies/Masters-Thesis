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
* Inflation Results (Core - Omit hyperinflation of 100% CPI growth rate) - Ready and Nested
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* Naming
gen var = Inflation * 100

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
	gen Con_`i' = "RE" if CoreTake == 1
	replace Con_`i' = "E" if Continent=="Europe"
	replace Con_`i' ="SA" if Continent=="South America"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	replace Con_`i' ="" if episode_ID !=`i'
	replace Con_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	egen tCon_`i' = mode(Con_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	cap restore
	
	if tCon_`i' == "E" continue
	* Omitted since no 15-10 year pre period
	
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
	* Creates Inflation rate and drops if the last value is missing and cid is NOT treated 
	
	gen tHI_flag = .
	replace tHI_flag = 1 if abs(d) >= 100 & cid == tcid_`i' & ti <= 15
	egen tHI = max(tHI_flag)
	if tHI==1 continue	
	* exclude treated countries with HyperInflation of d_I>=100 in prePeriod
	
	gen HI_flag = .
	replace HI_flag = 1 if abs(d) >= 100 & ti <= 15
	bysort cid (year): egen HI = max(HI_flag)
	drop if HI == 1
	* exclude non treated countries with HyperInflation of d_I>=100 in prePeriod
	
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
	
	if inlist(`i', 25) {
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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pp" -10 "-10 pp" 0 "0 pp" 10 "+10 pp" 20 "+20 pp" +30 "+30 pp" +40 "+40 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_Core_Inflation_gap_average.gph", replace


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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pp" -10 "-10 pp" 0 "0 pp" 10 "+10 pp" 20 "+20 pp" +30 "+30 pp" +40 "+40 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_LeftCore_Inflation_gap_average.gph", replace


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
drop if ca!="1968_16"


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pp" -10 "-10 pp" 0 "0 pp" 10 "+10 pp" 20 "+20 pp" +30 "+30 pp" +40 "+40 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_RightCore_Inflation_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "X_NoEU_Core_Inflation_gap_average" "X_NoEU_LeftCore_Inflation_gap_average" "X_NoEU_RightCore_Inflation_gap_average", ///
    rows(1) cols(3) ///
    xsize(18) ysize(4) ///
    iscale(1) ///
    graphregion(margin(1)) 
	
gr export "Figures/Append_6_NoEU_Core_Inflation.pdf", replace

cap erase "X_NoEU_Core_Inflation_gap_average.gph"
cap erase "X_NoEU_LeftCore_Inflation_gap_average.gph"
cap erase "X_NoEU_RightCore_Inflation_gap_average.gph"

clear

sleep 10

******************************************************************************************
******************************************************************************************
* Tariff Rate (Core) - Ready and Nested
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* TariffRate already as a percentage
gen var = Tariffs

drop if year >=2023

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
	gen Con_`i' = "RE" if CoreTake == 1
	replace Con_`i' = "E" if Continent=="Europe"
	replace Con_`i' ="SA" if Continent=="South America"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	replace Con_`i' ="" if episode_ID !=`i'
	replace Con_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	egen tCon_`i' = mode(Con_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	 
	if tCon_`i' == "E" | tyear_`i'<=1970 | inlist(`i', 2, 3, 12, 30, 31, 35, 37) continue
	* Omitted 
	* bad data			tcid: 2 3 12 30 31 35 37
	
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
	* Creates Inflation rate and drops if the last value is missing and cid is NOT treated 
	
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
	
	if `i' == 4 {
		drop if ti <= 8
		xtset cid ti	
		cap synth d d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}	
	else if `i' == 7 {
		drop if ti <= 2
		xtset cid ti		
		cap synth d d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	else if `i' == 13 {
		drop if ti <= 5
		xtset cid ti	
		cap synth d d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	else if `i' == 22 {
		drop if ti <= 6
		xtset cid ti	
		cap synth d d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	else if `i' == 33 {
		drop if ti <= 1
		drop if ti == 35
		xtset cid ti	
		cap synth d d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	}
	else if inlist(`i', 9, 14, 15, 21, 25, 29) {		
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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-10 "-10 pp" -5 "-5 pp" 0 "0 pp" 5 "+5 pp" 10 "+10 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEu_Core_TariffRate_gap_average.gph", replace


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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-10 "-10 pp" -5 "-5 pp" 0 "0 pp" 5 "+5 pp" 10 "+10 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEu_LeftCore_TariffRate_gap_average.gph", replace


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
drop if ca!="1996_28"


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-10 "-10 pp" -5 "-5 pp" 0 "0 pp" 5 "+5 pp" 10 "+10 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEu_RightCore_TariffRate_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "X_NoEu_Core_TariffRate_gap_average" "X_NoEu_LeftCore_TariffRate_gap_average" "X_NoEu_RightCore_TariffRate_gap_average", ///
    rows(1) cols(3) ///
    xsize(18) ysize(4) ///
    iscale(1) ///
    graphregion(margin(1)) 
	
gr export "Figures/Append_7_NoEu_Core_TariffRate.pdf", replace

cap erase "X_NoEu_Core_TariffRate_gap_average.gph"
cap erase "X_NoEu_LeftCore_TariffRate_gap_average.gph"
cap erase "X_NoEu_RightCore_TariffRate_gap_average.gph"


clear

sleep 10

******************************************************************************************
******************************************************************************************
* TradeShare of real GDP (Core) - Ready and Nested
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* TradeShare already as a percentage
gen var = TradeShare

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
	gen Con_`i' = "RE" if CoreTake == 1
	replace Con_`i' = "E" if Continent=="Europe"
	replace Con_`i' ="SA" if Continent=="South America"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	replace Con_`i' ="" if episode_ID !=`i'
	replace Con_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	egen tCon_`i' = mode(Con_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	 
	if tCon_`i' == "E" | tyear_`i'<=1970 | inlist(`i', 30, 31) continue
	* Omitted since no 15-10 year pre period or Gini data availability
	
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
	* Creates Inflation rate and drops if the last value is missing and cid is NOT treated 
	
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

	cap synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
	* ereturn list
	* SCM
	
	use _data, clear 
	* use synthetic control data
	
	gen time_rel = _time - 20
	* create time code for Graphic
	
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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pp" -15 "-15 pp" -10 "-10 pp" -5 "-5 pp" 0 "0 pp" 5 "+5 pp" 10 "+10 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_Core_TradeShare_gap_average.gph", replace


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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pp" -15 "-15 pp" -10 "-10 pp" -5 "-5 pp" 0 "0 pp" 5 "+5 pp" 10 "+10 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_LeftCore_TradeShare_gap_average.gph", replace


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
drop if ca!="1989_1"


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pp" -15 "-15 pp" -10 "-10 pp" -5 "-5 pp" 0 "0 pp" 5 "+5 pp" 10 "+10 pp", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_RightCore_TradeShare_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "X_NoEU_Core_TradeShare_gap_average" "X_NoEU_LeftCore_TradeShare_gap_average" "X_NoEU_RightCore_TradeShare_gap_average", ///
    rows(1) cols(3) ///
    xsize(18) ysize(4) ///
    iscale(1) ///
    graphregion(margin(1)) 
	
gr export "Figures/Append_8_NoEU_Core_TradeShare.pdf", replace

cap erase "X_NoEU_Core_TradeShare_gap_average.gph"
cap erase "X_NoEU_LeftCore_TradeShare_gap_average.gph"
cap erase "X_NoEU_RightCore_TradeShare_gap_average.gph"


clear

sleep 10

******************************************************************************************
******************************************************************************************
* Trade Openness (Core) - Ready and Nested
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* Trade Openness as an Index
gen var = TradeOpen

drop if year >=2023

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
	gen Con_`i' = "RE" if CoreTake == 1
	replace Con_`i' = "E" if Continent=="Europe"
	replace Con_`i' ="SA" if Continent=="South America"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	replace Con_`i' ="" if episode_ID !=`i'
	replace Con_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	egen tCon_`i' = mode(Con_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	 
	if tCon_`i' == "E" | tyear_`i'<=1990 | inlist(`i', 30, 31, 33) continue
	* Omitted since no 15-10 year pre period or Gini data availability
	
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
	* Creates Inflation rate and drops if the last value is missing and cid is NOT treated 
	
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
	
	if `i'==37 {
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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pt" -15 "-15 pt" -10 "-10 pt" -5 "-5 pt" 0 "0 pt" 5 "+5 pt" 10 "+10 pt", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_Core_TradeOpen_gap_average.gph", replace


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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pt" -15 "-15 pt" -10 "-10 pt" -5 "-5 pt" 0 "0 pt" 5 "+5 pt" 10 "+10 pt", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_LeftCore_TradeOpen_gap_average.gph", replace


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
drop if ca!="1996_16"


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pt" -15 "-15 pt" -10 "-10 pt" -5 "-5 pt" 0 "0 pt" 5 "+5 pt" 10 "+10 pt", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_RightCore_TradeOpen_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "X_NoEU_Core_TradeOpen_gap_average" "X_NoEU_LeftCore_TradeOpen_gap_average" "X_NoEU_RightCore_TradeOpen_gap_average", ///
    rows(1) cols(3) ///
    xsize(18) ysize(4) ///
    iscale(1) ///
    graphregion(margin(1)) 

gr export "Figures/Append_9_NoEU_Core_TradeOpen.pdf", replace

cap erase "X_NoEU_Core_TradeOpen_gap_average.gph"
cap erase "X_NoEU_LeftCore_TradeOpen_gap_average.gph"
cap erase "X_NoEU_RightCore_TradeOpen_gap_average.gph"


clear

sleep 10

******************************************************************************************
******************************************************************************************
* Financial Openness (Core) - Ready and Nested
******************************************************************************************
******************************************************************************************

cap restore
* to get rid of eventual preserved data

use Master_Data, clear

******************************************************************************************
* Financial Openness as an Index
gen var = FinOpen

drop if year >=2023

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
	gen Con_`i' = "RE" if CoreTake == 1
	replace Con_`i' = "E" if Continent=="Europe"
	replace Con_`i' ="SA" if Continent=="South America"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .
	replace Con_`i' ="" if episode_ID !=`i'
	replace Con_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tPol_`i' = mode(Pol_`i')
	egen tCon_`i' = mode(Con_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	 
	if tCon_`i' == "E" | tyear_`i'<=1990 | inlist(`i', 30, 31, 33) continue
	* Omitted since no 15-10 year pre period or Gini data availability
	
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
	* Creates Inflation rate and drops if the last value is missing and cid is NOT treated 
	
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
	
	if inlist(`i', 13, 17) {
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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pt" -15 "-15 pt" -10 "-10 pt" -5 "-5 pt" 0 "0 pt" 5 "+5 pt" 10 "+10 pt", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_Core_FinOpen_gap_average.gph", replace


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
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pt" -15 "-15 pt" -10 "-10 pt" -5 "-5 pt" 0 "0 pt" 5 "+5 pt" 10 "+10 pt", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_LeftCore_FinOpen_gap_average.gph", replace


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
drop if ca!="1996_16"


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20 pt" -15 "-15 pt" -10 "-10 pt" -5 "-5 pt" 0 "0 pt" 5 "+5 pt" 10 "+10 pt", angle(0) labsize(medium) nogrid) ///
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

graph save "X_NoEU_RightCore_FinOpen_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "X_NoEU_Core_FinOpen_gap_average" "X_NoEU_LeftCore_FinOpen_gap_average" "X_NoEU_RightCore_FinOpen_gap_average", ///
    rows(1) cols(3) ///
    xsize(18) ysize(4) ///
    iscale(1) ///
    graphregion(margin(1)) 

gr export "Figures/Append_10_NoEU_Core_FinOpen.pdf", replace

cap erase "X_NoEU_Core_FinOpen_gap_average.gph"
cap erase "X_NoEU_LeftCore_FinOpen_gap_average.gph"
cap erase "X_NoEU_RightCore_FinOpen_gap_average.gph"


clear

sleep 10
