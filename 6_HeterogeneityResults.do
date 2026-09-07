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
* GDPpc Results (Core - Europe, South America, and Rest)
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
	gen Con_`i' = "RE" if CoreTake == 1
	replace Con_`i' = "E" if Continent=="Europe"
	replace Con_`i' ="SA" if Continent=="South America"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Con_`i' ="" if episode_ID !=`i'
	replace Con_`i' ="" if treatedcid_`i' == .

	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tCon_`i' = mode(Con_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
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
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tCon_`i'
	local p = tCon_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 3, 14, 19, 21, 25) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
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

* All Core Europe Cases
local allfiles : dir . files "_E_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _E_temp, replace
				restore
				sleep 5
		append using _E_temp, force
} 

save _E_append_synth, replace

cap !del _E_temp
cap !rm _E_temp.dta

clear

******************************************************************************************
* All Core South America Cases
local allfiles : dir . files "_SA_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _SA_temp, replace
				restore
				sleep 5
		append using _SA_temp, force
} 

save _SA_append_synth, replace

cap !del _SA_temp
cap !rm _SA_temp.dta

clear

******************************************************************************************
* All Core South America Cases
local allfiles : dir . files "_RE_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _RE_temp, replace
				restore
				sleep 5
		append using _RE_temp, force
} 

save _RE_append_synth, replace

cap !del _RE_temp
cap !rm _RE_temp.dta

clear


******************************************************************************************
******************************************************************************************
* Averages All Core
use _E_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-15 & time_rel<=-5, by(ca)
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
(line _treatmean time_rel, lcolor(black) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(black) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("European populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "Z_Core_E_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("European populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "Z_Core_E_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _E_append_synth
cap !rm _E_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _SA_append_synth, clear

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
drop if ca!="1996_16"


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
title("South American populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "Z_Core_SA_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("South American populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "Z_Core_SA_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _SA_append_synth
cap !rm _SA_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _RE_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-15 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1996_28"


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
title("Rest of the world") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "Z_Core_RE_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Rest of the world") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "Z_Core_RE_GDPpc_gap_average.gph", replace

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "Z_Core_E_GDPpc_average" "Z_Core_SA_GDPpc_average" "Z_Core_RE_GDPpc_average.gph" ///
"Z_Core_E_GDPpc_gap_average" "Z_Core_SA_GDPpc_gap_average" "Z_Core_RE_GDPpc_gap_average.gph"

gr export "Figures/20_Core_EvSA_GDPpc.pdf", replace

cap erase "Z_Core_E_GDPpc_average.gph"
cap erase "Z_Core_SA_GDPpc_average.gph"
cap erase "Z_Core_RE_GDPpc_average.gph"
cap erase "Z_Core_E_GDPpc_gap_average.gph"
cap erase "Z_Core_SA_GDPpc_gap_average.gph"
cap erase "Z_Core_RE_GDPpc_gap_average.gph"

clear

sleep 10

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* GDPpc Results (Core - Pre and Post 1990)
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
	gen Age_`i' = "Pre" if year <= 1990
	
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Age_`i' ="Post" if year > 1990
	replace Age_`i' ="" if episode_ID !=`i'
	replace Age_`i' ="" if treatedcid_`i' == .

	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tAge_`i' = mode(Age_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
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
	* Creates Growthrate and drops if the last value is missing and cid is NOT treated 
	
	sum treatedcid_`i'
	local c = r(mean)
	* Store specific treated country cid in local c
	
	sum treatedyear_`i'
	local y = r(mean)
	* Story specific treated year in local y
	
	sum tAge_`i'
	local p = tAge_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 3, 14, 21, 25) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(15) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(15) tru(`c') unitnames(country) k(_data, replace) nested
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

* All Core Europe Cases
local allfiles : dir . files "_Pre_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _Pre_temp, replace
				restore
				sleep 5
		append using _Pre_temp, force
} 

save _Pre_append_synth, replace

cap !del _Pre_temp
cap !rm _Pre_temp.dta

clear

******************************************************************************************
* All Core South America Cases
local allfiles : dir . files "_Post_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _Post_temp, replace
				restore
				sleep 5
		append using _Post_temp, force
} 

save _Post_append_synth, replace

cap !del _Post_temp
cap !rm _Post_temp.dta

clear


******************************************************************************************
******************************************************************************************
* Averages All Core
use _Pre_append_synth, clear

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
drop if ca!="1951_6"


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
title("Pre-1990 populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "Z_Core_Pre_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(black) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Pre-1990 populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "Z_Core_Pre_GDPpc_gap_average.gph", replace



******************************************************************************************
* Delete temporary data
cap !del _Pre_append_synth
cap !rm _Pre_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _Post_append_synth, clear

* Mean all SCMs
egen _treatmean = mean(_Y_treated), by(_time)
egen _synthmean = mean(_Y_synthetic), by(_time)
* Create means over all doppelgangers with standard deviations


******************************************************************************************
* Create doppelganger gap data
gen _gap = _Y_treated - _Y_synthetic
egen _gapmean = mean(_gap), by(_time)
egen _gapsd = sd(_gap) if time_rel >=-15 & time_rel<=-5, by(ca)
egen _gapmeansd = mean(_gapsd)
gen _low_gapsd = _gapmean - _gapmeansd
gen _high_gapsd = _gapmean + _gapmeansd
* Create means over all doppelganger gaps with standard deviations


******************************************************************************************
* only one
drop if ca!="1996_16"


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
title("Post-1990 populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "Z_Core_Post_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Post-1990 populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "Z_Core_Post_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _Post_append_synth
cap !rm _Post_append_synth.dta
clear

******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "Z_Core_Pre_GDPpc_average" "Z_Core_Post_GDPpc_average" ///
"Z_Core_Pre_GDPpc_gap_average" "Z_Core_Post_GDPpc_gap_average" 
gr export "Figures/21_Core_1990_GDPpc.pdf", replace

cap erase "Z_Core_Pre_GDPpc_average.gph"
cap erase "Z_Core_Post_GDPpc_average.gph"
cap erase "Z_Core_Pre_GDPpc_gap_average.gph"
cap erase "Z_Core_Post_GDPpc_gap_average.gph"

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* GDPpc Results (Core - Median Institutions)
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
* Identifier for institutions
bys cid (year): gen PopInst = .
replace PopInst = Institution_Index if CoreTake==1 & CoreTake != .
sum PopInst, detail
local InstMean = r(p50)

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen Inst_`i' = "LO" if CoreTake==1  
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Inst_`i' = "HI" if Institution_Index > `InstMean'
	replace Inst_`i' = "" if episode_ID !=`i'
	replace Inst_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen tInst_`i' = mode(Inst_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
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
	
	sum tInst_`i'
	local p = tInst_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 3, 14, 19, 21, 25) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
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

******************************************************************************************
* All HI Core Cases
local allfiles : dir . files "_HI_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _HI_temp, replace
				restore
				sleep 5
		append using _HI_temp, force
} 

save _HI_append_synth, replace

cap !del _HI_temp
cap !rm _HI_temp.dta

clear

******************************************************************************************
* All LO Core Cases
local allfiles : dir . files "_LO_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _LO_temp, replace
				restore
				sleep 5
		append using _LO_temp, force
} 

save _LO_append_synth, replace

cap !del _HI_temp
cap !rm _HI_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _HI_append_synth, clear

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
drop if ca!="1989_1"


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
title("High institution populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_HI_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("High institution populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_HI_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _HI_append_synth
cap !rm _HI_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _LO_append_synth, clear

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
drop if ca!="1970_36"


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
title("Low institution populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_LO_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Low institution populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_LO_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "X_HI_GDPpc_average" "X_LO_GDPpc_average" ///
"X_HI_GDPpc_gap_average" "X_LO_GDPpc_gap_average"
gr export "Figures/22_Inst_Core_GDPpc.pdf", replace

cap erase "X_HI_GDPpc_average.gph"
cap erase "X_LO_GDPpc_average.gph"
cap erase "X_HI_GDPpc_gap_average.gph"
cap erase "X_LO_GDPpc_gap_average.gph"

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* GDPpc Results (Core Institutions - 75-25)
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
* Identifier for institutions
bys cid (year): gen PopInst = .
replace PopInst = Institution_Index if CoreTake==1 & CoreTake != .
sum PopInst, detail
local Inst75 = r(p75)
local Inst25 = r(p25)

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if CoreTake==1
	gen treatedcid_`i' = cid if CoreTake==1
	gen Name_`i' = Leaders if CoreTake==1
	gen Inst_`i' = "MID"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Name_`i' = "" if episode_ID !=`i'
	replace Inst_`i' = "HI" if Institution_Index > `Inst75'
	replace Inst_`i' = "LO" if Institution_Index < `Inst25'
	replace Inst_`i' = "" if episode_ID !=`i'
	replace Inst_`i' ="" if treatedcid_`i' == .
	
	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tName_`i' = mode(Name_`i')
	egen str10 tInst_`i' = mode(Inst_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if `i' == 30 continue
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
	
	sum tInst_`i'
	local p = tInst_`i'
	* Identifyer for Political Leaning
	
	xtset cid ti
	* For panel analysis
	
	if inlist(`i', 3, 14, 19, 21, 25) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
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

******************************************************************************************
* All HI Core Cases
local allfiles : dir . files "_HI_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _HI_temp, replace
				restore
				sleep 5
		append using _HI_temp, force
} 

save _HI_append_synth, replace

cap !del _HI_temp
cap !rm _HI_temp.dta

clear

******************************************************************************************
* All LO Core Cases
local allfiles : dir . files "_LO_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _LO_temp, replace
				restore
				sleep 5
		append using _LO_temp, force
} 

save _LO_append_synth, replace

cap !del _HI_temp
cap !rm _HI_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _HI_append_synth, clear

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
drop if ca!="1994_29"


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
title("Very High institution populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_75HI_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Very High institution populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_75HI_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _HI_append_synth
cap !rm _HI_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages All Core
use _LO_append_synth, clear

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
drop if ca!="1970_36"


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
title("Very Low institution populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_25LO_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-25 "-25%" -20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Very Low institution populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_25LO_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph

graph combine "X_75HI_GDPpc_average" "X_25LO_GDPpc_average" ///
"X_75HI_GDPpc_gap_average" "X_25LO_GDPpc_gap_average"

gr export "Figures/23_VeryInst_Core_GDPpc.pdf", replace

cap erase "X_75HI_GDPpc_average.gph"
cap erase "X_25LO_GDPpc_average.gph"
cap erase "X_75HI_GDPpc_gap_average.gph"
cap erase "X_25LO_GDPpc_gap_average.gph"

clear

sleep 10

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* GDPpc Results (Omit - European Union)
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
	gen Pol_`i' = "L" if CoreTake==1
	gen Con_`i' = "RE" if CoreTake == 1
	replace Con_`i' = "EU" if Continent=="Europe"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace Con_`i' ="" if episode_ID !=`i'
	replace Con_`i' ="" if treatedcid_`i' == .
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .

	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tCon_`i' = mode(Con_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if tCon_`i' == "EU" continue
	
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
	
	sum tPol_`i'
	local p = tPol_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 3, 14, 19, 21, 25) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
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
drop if ca!="1985_41"


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

graph save "X_Core_GDPpc_average.gph", replace


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

graph save "X_Core_GDPpc_gap_average.gph", replace



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

graph save "X_LeftCore_GDPpc_average.gph", replace


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

graph save "X_LeftCore_GDPpc_gap_average.gph", replace


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
drop if ca!="1990_6"


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

graph save "X_RightCore_GDPpc_average.gph", replace


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

graph save "X_RightCore_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "X_Core_GDPpc_average" "X_LeftCore_GDPpc_average" "X_RightCore_GDPpc_average" ///
"X_Core_GDPpc_gap_average" "X_LeftCore_GDPpc_gap_average" "X_RightCore_GDPpc_gap_average"
gr export Figures/24_Core_NoEUROPE_GDPpc.pdf, replace

cap erase "X_Core_GDPpc_average.gph"
cap erase "X_LeftCore_GDPpc_average.gph"
cap erase "X_RightCore_GDPpc_average.gph"
cap erase "X_Core_GDPpc_gap_average.gph"
cap erase "X_LeftCore_GDPpc_gap_average.gph"
cap erase "X_RightCore_GDPpc_gap_average.gph"

clear

sleep 10

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* GDPpc Results (Pre/Non/Ex EU vs EU members)
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
replace episode = 1 if BorderTake == 1 & Continent == "Europe"
replace episode = . if episode == 0
gen episode_ID = sum(episode)
replace episode_ID = . if BorderPop == . | Continent != "Europe"
replace episode_ID = . if episode_ID == 0

levelsof episode_ID, local(TakeID)
* Identification local for loop

******************************************************************************************
* Identificationloop for SCM
foreach i of local TakeID {
	bys cid: gen treatedyear_`i' = year if BorderTake==1 
	gen treatedcid_`i' = cid if BorderTake==1 
	gen Pol_`i' = "L" if BorderTake==1
	gen EU_`i' = "Y" if BorderTake == 1
	replace EU_`i' = "N" if Leaders == "Tudman" 
	replace EU_`i' = "N" if Leaders == "Walesa"
	replace EU_`i' = "N" if Leaders == "Zeman" 
	replace EU_`i' = "N" if Leaders ==  "Repse" 
	replace EU_`i' = "N" if Leaders ==  "Basescu" 
	replace EU_`i' = "N" if Leaders == "Johnson"
	
	replace treatedyear_`i'=. if episode_ID !=`i'
	replace treatedcid_`i'=. if episode_ID !=`i'
	replace EU_`i' ="" if episode_ID !=`i'
	replace EU_`i' ="" if treatedcid_`i' == .
	replace Pol_`i' = "R" if RightCoreTake==1
	replace Pol_`i' = "" if episode_ID !=`i'
	replace Pol_`i' ="" if treatedcid_`i' == .

	egen tyear_`i' = sum(treatedyear_`i')
	egen tcid_`i' = sum(treatedcid_`i')
	egen tEU_`i' = mode(EU_`i')
	egen tPol_`i' = mode(Pol_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if inlist(`i', 18, 19, 23) continue 
	* Omit Meciar due to data availability, Erdogan and Putin since they are not really Europe or EU
	
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
	
	sum tEU_`i'
	local p = tEU_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 8, 12) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) 
	}
	
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
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

* All EU Borderline Cases
local allfiles : dir . files "_Y_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _Y_temp, replace
				restore
				sleep 5
		append using _Y_temp, force
} 

save _Y_append_synth, replace

cap !del _Y_temp
cap !rm _Y_temp.dta

clear

******************************************************************************************
* All Non-EU Borderline Cases
local allfiles : dir . files "_N_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _N_temp, replace
				restore
				sleep 5
		append using _N_temp, force
} 

save _N_append_synth, replace

cap !del _N_temp
cap !rm _N_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages EU
use _Y_append_synth, clear

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
drop if ca!="2006_14"


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
title("EU borderline populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_EU_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("EU borderline populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_EU_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _Y_append_synth
cap !rm _Y_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages Non-EU
use _N_append_synth, clear

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
drop if ca!="2002_31"


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
title("Non-EU borderline populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_NEU_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Non-EU borderline populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_NEU_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "X_EU_GDPpc_average" "X_NEU_GDPpc_average" ///
"X_EU_GDPpc_gap_average" "X_NEU_GDPpc_gap_average"
gr export Figures/25_Core_EuropeanUnion_GDPpc.pdf, replace

cap erase "X_EU_GDPpc_average.gph"
cap erase "X_NEU_GDPpc_average.gph"
cap erase "X_EU_GDPpc_gap_average.gph"
cap erase "X_NEU_GDPpc_gap_average.gph"


clear

sleep 10

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* GDPpc Results (Stability)
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
replace episode = . if episode == 0
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == . 
replace episode_ID = . if episode_ID == 0
replace episode_ID = . if episode == .

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
	
	gen in_window_`i' = inrange(year, tyear_`i' - 5, tyear_`i' + 5)
	replace in_window_`i'= . if cid != tcid_`i'
	bys cid: gen range_Conflict_`i' = Conflicts if in_window_`i' == 1
	egen t_Conflict_`i'= sum(range_Conflict_`i')
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

preserve
    keep episode_ID t_Conflict_*
	drop if episode_ID == .
	reshape long t_Conflict_, i(episode_ID) j(epnum)
	drop if episode_ID != 1
	replace episode_ID = epnum
	drop epnum
    sum t_Conflict_, detail
    local med_Conflict = r(p50)
restore

display `med_Conflict'

gen median_Conflict = .
replace median_Conflict = `med_Conflict'

foreach i of local TakeID {
	gen Stab_`i' = ""
	replace Stab_`i' = "Y" if t_Conflict_`i' >= median_Conflict
	replace Stab_`i' = "N" if t_Conflict_`i' < median_Conflict	
	replace Stab_`i' = "" if cid != tcid_`i'
	
	egen tStab_`i' = mode(Stab_`i')
}

******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if inlist(`i', 30) continue 
	* Omit Meciar due to data availability

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
	
	sum tStab_`i'
	local p = tStab_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 3, 14, 19, 21, 25) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}		
	
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
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

* All HighStab Cases
local allfiles : dir . files "_Y_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _Y_temp, replace
				restore
				sleep 5
		append using _Y_temp, force
} 

save _Y_append_synth, replace

cap !del _Y_temp
cap !rm _Y_temp.dta

clear

******************************************************************************************
* All LowStab Borderline Cases
local allfiles : dir . files "_N_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _N_temp, replace
				restore
				sleep 5
		append using _N_temp, force
} 

save _N_append_synth, replace

cap !del _N_temp
cap !rm _N_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages EU
use _Y_append_synth, clear

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
drop if ca!="1951_6"


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
title("Low Conflict populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_LowConflict_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Low Conflict populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_LowConflict_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _Y_append_synth
cap !rm _Y_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages Non-EU
use _N_append_synth, clear

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
* Create Graph of Average Treatment effect with standard deviation
twoway ///
(line _treatmean time_rel, lcolor(red) lwidth(thick) lpattern(solid)) ///
(line _synthmean time_rel, lcolor(red) lwidth(thick) lpattern(dash)), /// 
legend(rows(1) order(1 "Populist avg." 2 "Synthetic avg.") region(lstyle(none))) ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium) nogrid) ///
ylabel(-40 "-40%" -20 "-20%" 0 "0%" 20 "+20%" 40 "+40%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") /// 
title("High Conflict populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_HighConflict_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("High Conflict populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_HighConflict_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "X_LowConflict_GDPpc_average" "X_HighConflict_GDPpc_average" ///
"X_LowConflict_GDPpc_gap_average" "X_HighConflict_GDPpc_gap_average"
gr export Figures/26_Core_Conflict_GDPpc.pdf, replace

cap erase "X_LowConflict_GDPpc_average.gph"
cap erase "X_HighConflict_GDPpc_average.gph"
cap erase "X_LowConflict_GDPpc_gap_average.gph"
cap erase "X_HighConflict_GDPpc_gap_average.gph"


clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* GDPpc Results (Coup)
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
replace episode = . if episode == 0
gen episode_ID = sum(episode)
replace episode_ID = . if CorePop == . 
replace episode_ID = . if episode_ID == 0
replace episode_ID = . if episode == .

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
	
	gen in_window_`i' = inrange(year, tyear_`i' - 5, tyear_`i' + 5)
	replace in_window_`i'= . if cid != tcid_`i'
	gen range_Coup_`i' = "Y" if in_window_`i'==1 & Coup==1
	egen t_Coup_`i'= mode(range_Coup_`i')
	replace t_Coup_`i' ="N" if t_Coup_`i'==""
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}


******************************************************************************************
******************************************************************************************
* Synthetic Control for each leader individually
foreach i of local TakeID {
	
	if inlist(`i', 30) continue 
	* Omit Meciar due to data availability

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
	
	sum t_Coup_`i'
	local p = t_Coup_`i'
	* Identifyer for Political Leaning
	
	if inlist(`i', 3, 14, 19, 21, 25) {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace)
	}		
	
	else {
		xtset cid ti
		synth d d(0) d(1) d(2) d(3) d(4) d(5) d(6) d(7) d(8) d(9) d(10) d(11) d(12) d(13) d(14), trp(20) tru(`c') unitnames(country) k(_data, replace) nested
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

* All HighStab Cases
local allfiles : dir . files "_Y_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _Y_temp, replace
				restore
				sleep 5
		append using _Y_temp, force
} 

save _Y_append_synth, replace

cap !del _Y_temp
cap !rm _Y_temp.dta

clear

******************************************************************************************
* All LowStab Borderline Cases
local allfiles : dir . files "_N_*.dta"
		foreach file of local allfiles {
				preserve
				use `file', clear
				sleep 5
				save _N_temp, replace
				restore
				sleep 5
		append using _N_temp, force
} 

save _N_append_synth, replace

cap !del _N_temp
cap !rm _N_temp.dta

clear

******************************************************************************************
******************************************************************************************
* Averages EU
use _Y_append_synth, clear

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
drop if ca!="1946_1"


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
title("Coup populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_Coup_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(blue) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("Coup populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_Coup_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _Y_append_synth
cap !rm _Y_append_synth.dta
clear

******************************************************************************************
******************************************************************************************
* Averages Non-EU
use _N_append_synth, clear

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
drop if ca!="1952_9"


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
title("No coup populists") ///
xline(0, lpattern(dot) lcolor(black)) ///
xline(-5, lpattern(dot) lcolor(black)) scheme(s1color)

graph save "X_NoCoup_GDPpc_average.gph", replace


******************************************************************************************
* Create Graph of average doppelganger gap with standard deviation
twoway /// 
(rarea _high_gapsd _low_gapsd time_rel, color(gs8%20) lcolor(gs8%20) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
(line _gapmean time_rel, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort), ///
xlabel(-20 -15 -10 -5 0 5 10 15, labsize(medium)) /// 
ylabel(-20 "-20%" -15 "-15%" -10 "-10%" -5 "-5%" 0 "0%" 5 "+5%", angle(0) labsize(medium) nogrid) ///
ytitle("", size(medsmall) margin(medium)) ///
xtitle("") ///
title("No coup populists") ///
yline(0, lpattern(dot) lcolor(black)) ///
xline(0, lpattern(dot) lcolor(black)) /// 
xline(-5, lpattern(dot) lcolor(black)) ///
scheme(s1mono) ///
graphregion(color(white) /// 
lcolor(white) ///
margin(b-3 l-5)) ///
legend(rows(1) order(2 "Doppelgangergap avg.") region(lstyle(none)))

graph save "X_NoCoup_GDPpc_gap_average.gph", replace


******************************************************************************************
* Delete temporary data
cap !del _*
cap !rm _*.dta

clear

******************************************************************************************
******************************************************************************************
* Create whole graph for average effect

graph combine "X_Coup_GDPpc_average" "X_NoCoup_GDPpc_average" ///
"X_Coup_GDPpc_gap_average" "X_NoCoup_GDPpc_gap_average"
gr export Figures/27_Core_Coup_GDPpc.pdf, replace

cap erase "X_Coup_GDPpc_average.gph"
cap erase "X_NoCoup_GDPpc_average.gph"
cap erase "X_Coup_GDPpc_gap_average.gph"
cap erase "X_NoCoup_GDPpc_gap_average.gph"


clear

sleep 10