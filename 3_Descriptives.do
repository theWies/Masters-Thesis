******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Descriptives
******************************************************************************************
******************************************************************************************
******************************************************************************************

* This .do is used to produce the descriptives from the data


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Table 1 - Number of Populists (not combined)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear

* 1) Core sample (CorePop == 1)
preserve

keep if !missing(Leaders) & CorePop == 1
bysort Leaders (year): keep if _n == 1

count if CorePop == 1
local core_all = r(N)
count if LeftCorePop == 1
local core_left = r(N)
count if RightCorePop == 1
local core_right = r(N)

restore


* 2) Borderline sample (BorderPop == 1)
preserve

keep if !missing(Leaders) & BorderPop == 1
bysort Leaders (year): keep if _n == 1

count
local border_all = r(N)
count if LeftBorderPop == 1
local border_left = r(N)
count if RightBorderPop == 1
local border_right = r(N)

restore

* 3) Extended sample (ExtPop == 1)
preserve

keep if !missing(Leaders) & ExtPop == 1
bysort Leaders (year): keep if _n == 1

count
local ext_all = r(N)
count if LeftExtPop == 1
local ext_left = r(N)
count if RightExtPop == 1
local ext_right = r(N)

restore


* 4) Create matrix with results
matrix PopCount = J(3, 3, 0)

* Fill the matrix with local macros
matrix PopCount[1,1] = `core_all'
matrix PopCount[1,2] = `core_left'
matrix PopCount[1,3] = `core_right'

matrix PopCount[2,1] = `border_all'
matrix PopCount[2,2] = `border_left'
matrix PopCount[2,3] = `border_right'

matrix PopCount[3,1] = `ext_all'
matrix PopCount[3,2] = `ext_left'
matrix PopCount[3,3] = `ext_right'

* Assign row and column names
matrix rownames PopCount = Core Borderline Extended
matrix colnames PopCount = All Left Right

* Display the matrix
matrix list PopCount

* 5) Save Matrix as .log
log using "Tables/1_PopCount.log", replace text
matrix list PopCount
log close

clear


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Figure 1 - Number of Populists across time (not combined)(copied from Replication)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear

* 1) Prepare the data for future extrapolation
bysort cid : gen order = _n
by cid : gen last = _n == _N

* 2) Expand last observation 3 times to project forward
expand 3 if last
sort iso year

* 3) Update years for duplicated 2019
bysort iso : replace year = 2020 if year == 2019 & year[_n-1] == 2019
bysort iso : replace year = 2021 if year == 2019 & year[_n-1] == 2020

* 4) Handle missing or special cases
replace ExtPop = . if year == 2021
replace ExtPop = 0 if year == 2020 & inlist(iso,"GRC","BOL")
replace LeftExtPop = 0 if year == 2020 & inlist(iso,"GRC","BOL")

* 5) Aggregate to total by year
foreach v in independent ExtPop LeftExtPop RightExtPop {
    egen `v'by = sum(`v'), by(year)
}

* 6) Calculate percentage shares
gen sh  = ExtPopby / independentby * 100
gen shl = LeftExtPopby / independentby * 100
gen shr = RightExtPopby / independentby * 100

* 7) Prepare label variable for left vs right populism
gen lrstr = ""
replace lrstr = "Left-wing populism" if LeftExtPop == 1
replace lrstr = "Right-wing populism" if RightExtPop == 1
gen zero=0

* 8) Prepare for future marking
egen ExtPop_id = max(ExtPop == 1), by(country)
replace ExtPop = 1 if year == 2021 & ExtPop_id == 1
replace lrstr = "2021" if year == 2021 & ExtPop_id == 1

* 9) Create the Plot
tw ///
	(rarea shl sh year, color(gs5) lcolor(gs6) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
	(rarea shl zero year, col(gs11) lcolor(gs11) lp(solid) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) /// 
	(line sh year, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort) /// 
	if year>=1900 & year <=2020, ///
	xlabel(1900 1920 1940 1960 1980 2000 2020, labsize(medium)) ///
	ylabel(0 5 10 15 20 25 30, angle(0) labsize(medium) nogrid) /// 
	xtitle("", size(medsmall) margin(medium)) ///
	ytitle("Share of independent countries with populist government (%)", size(small) margin(medium)) ///
	scheme(s1mono) ///
	graphregion(color(white) ///
	lcolor(white) ///
	margin(b-3 l-5)) ///
	ysize(6) ///
	xsize(9) ///
	legend(rows(1) order(3 "Populist governments" 1 "Right-wing populism" 2 "Left-wing populism") ///
	symxsize(*0.3) ///
	symysize(*0.3) ///
	region(lwidth(none)) ///
	forcesize size(medlarge)) 

* 10) Save the Plot as pdf
graph export "Figures/1_PopOverTime.pdf", replace

clear



******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Info - Number of Countries with Populist Takeovers
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Identify Core Treated Countries
use Master_Data, clear
bys cid (year): gen C_TreatCountry = 0
replace C_TreatCountry = 1 if CorePop == 1 
bysort cid (year): egen C_TreatCountryCID = max(C_TreatCountry)
bys cid (year): gen CL_TreatCountry = 0
replace CL_TreatCountry = 1 if LeftCorePop == 1 
bysort cid (year): egen CL_TreatCountryCID = max(CL_TreatCountry)
bys cid (year): gen CR_TreatCountry = 0
replace CR_TreatCountry = 1 if RightCorePop == 1 
bysort cid (year): egen CR_TreatCountryCID = max(CR_TreatCountry)

keep if year==2000

* 1) Count for Consensus (Core) sample
count if C_TreatCountryCID == 1
local core_all = r(N)
count if CL_TreatCountryCID == 1
local core_left = r(N)
count if CR_TreatCountryCID == 1
local core_right = r(N)

******************************************************************************************
* Identify Borderline Treated Countries
use Master_Data, clear
bys cid (year): gen B_TreatCountry = 0
replace B_TreatCountry = 1 if BorderPop == 1 
bysort cid (year): egen B_TreatCountryCID = max(B_TreatCountry)
bys cid (year): gen BL_TreatCountry = 0
replace BL_TreatCountry = 1 if LeftBorderPop == 1 
bysort cid (year): egen BL_TreatCountryCID = max(BL_TreatCountry)
bys cid (year): gen BR_TreatCountry = 0
replace BR_TreatCountry = 1 if RightBorderPop == 1 
bysort cid (year): egen BR_TreatCountryCID = max(BR_TreatCountry)

keep if year==2000

* 2) Count for Consensus (Core) sample
count if B_TreatCountryCID == 1
local border_all = r(N)
count if BL_TreatCountryCID == 1
local border_left = r(N)
count if BR_TreatCountryCID == 1
local border_right = r(N)

******************************************************************************************
* Identify Extended Treated Countries
use Master_Data, clear
bys cid (year): gen E_TreatCountry = 0
replace E_TreatCountry = 1 if ExtPop == 1 
bysort cid (year): egen E_TreatCountryCID = max(E_TreatCountry)
bys cid (year): gen EL_TreatCountry = 0
replace EL_TreatCountry = 1 if LeftExtPop == 1 
bysort cid (year): egen EL_TreatCountryCID = max(EL_TreatCountry)
bys cid (year): gen ER_TreatCountry = 0
replace ER_TreatCountry = 1 if RightExtPop == 1 
bysort cid (year): egen ER_TreatCountryCID = max(ER_TreatCountry)

keep if year==2000


* 3) Count for Consensus (Core) sample
count if E_TreatCountryCID == 1
local ext_all = r(N)
count if EL_TreatCountryCID == 1
local ext_left = r(N)
count if ER_TreatCountryCID == 1
local ext_right = r(N)

clear

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Table 2 - Number of Populist Takeovers (combined consecutive/nearly consecutive terms)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************


use Master_Data, clear

* 1) Count for Consensus (Core) sample
count if CoreTake == 1
local core_all = r(N)

count if LeftCoreTake == 1
local core_left = r(N)

count if RightCoreTake == 1
local core_right = r(N)

* 2) Count for Borderline sample
count if BorderTake == 1
local border_all = r(N)

count if LeftBorderTake == 1
local border_left = r(N)

count if RightBorderTake == 1
local border_right = r(N)

* 3) Count for Extended sample
count if ExtTake == 1
local ext_all = r(N)

count if LeftExtTake == 1
local ext_left = r(N)

count if RightExtTake == 1
local ext_right = r(N)

* 4) Create matrix with results
matrix CountPopTake = J(3, 3, 0)

* Fill the matrix with local macros
matrix CountPopTake[1,1] = `core_all'
matrix CountPopTake[1,2] = `core_left'
matrix CountPopTake[1,3] = `core_right'

matrix CountPopTake[2,1] = `border_all'
matrix CountPopTake[2,2] = `border_left'
matrix CountPopTake[2,3] = `border_right'

matrix CountPopTake[3,1] = `ext_all'
matrix CountPopTake[3,2] = `ext_left'
matrix CountPopTake[3,3] = `ext_right'

* Assign row and column names
matrix rownames CountPopTake = Core Borderline Extended
matrix colnames CountPopTake = All Left Right

* Display the matrix
matrix list CountPopTake

* Save Matrix as .log
log using "Tables/2_PopTakeCount.log", replace text
matrix list CountPopTake
log close

clear


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Table 3 - Length of Populist Periods (combined consecutive/nearly consecutive terms)
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear

sort cid year

******************************************************************************************
* Identify the start of a new episode for all Populists
gen episode = 0
replace episode = 1 if ExtTake == 1 

* Now we can cumulatively number these episodes:
by cid (year): gen episode_ID = sum(episode)
replace episode_ID = . if ExtPop == .

* Next, total up the length of each episode:
egen episode_length = total(1), by(cid episode_ID)
replace episode_length = . if ExtPop == .

******************************************************************************************
* Average Length of Populist Episodes for each political leaning and sample

sum episode_length if CoreTake==1
local lCore = r(mean)
sum episode_length if LeftCoreTake==1
local lLeftCore = r(mean)
sum episode_length if RightCoreTake==1
local lRightCore = r(mean)

sum episode_length if BorderTake==1
local lBorder = r(mean)
sum episode_length if LeftBorderTake==1
local lLeftBorder = r(mean)
sum episode_length if RightBorderTake==1
local lRightBorder = r(mean)

sum episode_length if ExtTake==1
local lExt = r(mean)
sum episode_length if LeftExtTake==1
local lLeftExt = r(mean)
sum episode_length if RightExtTake==1
local lRightExt = r(mean)

******************************************************************************************
* Create matrix with results
matrix CountPopLength = J(3, 3, 0)

* Fill the matrix with local macros
matrix CountPopLength[1,1] = `lCore'
matrix CountPopLength[1,2] = `lLeftCore'
matrix CountPopLength[1,3] = `lRightCore'

matrix CountPopLength[2,1] = `lBorder'
matrix CountPopLength[2,2] = `lLeftBorder'
matrix CountPopLength[2,3] = `lRightBorder'

matrix CountPopLength[3,1] = `lExt'
matrix CountPopLength[3,2] = `lLeftExt'
matrix CountPopLength[3,3] = `lRightExt'

* Assign row and column names
matrix rownames CountPopLength = Core Borderline Extended
matrix colnames CountPopLength = All Left Right

* Display the matrix
matrix list CountPopLength

* Save Matrix as .log
log using "Tables/3_CountPopLength.log", replace text
matrix list CountPopLength
log close

clear


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Table 4 - Concentration of populist leaders on continents
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear

* 1) All Core Cases on their Continents
count if CoreTake == 1 & Continent == "Europe"
local CoreEurope = r(N)
count if CoreTake == 1 & Continent == "South America"
local CoreSA = r(N)
count if CoreTake == 1 & Continent == "Asia"
local CoreAsia = r(N)
count if CoreTake == 1 & Continent == "Ozeania"
local CoreOz = r(N)
count if CoreTake == 1 & Continent == "North America"
local CoreNA = r(N)
count if CoreTake == 1 & Continent == "Africa"
local CoreAfrica = r(N)

* 2) Left Core Cases
count if LeftCoreTake == 1 & Continent == "Europe"
local LeftCoreEurope = r(N)
count if LeftCoreTake == 1 & Continent == "South America"
local LeftCoreSA = r(N)
count if LeftCoreTake == 1 & Continent == "Asia"
local LeftCoreAsia = r(N)
count if LeftCoreTake == 1 & Continent == "Ozeania"
local LeftCoreOz = r(N)
count if LeftCoreTake == 1 & Continent == "North America"
local LeftCoreNA = r(N)
count if LeftCoreTake == 1 & Continent == "Africa"
local LeftCoreAfrica = r(N)

* 3) Right Core Cases
count if RightCoreTake == 1 & Continent == "Europe"
local RightCoreEurope = r(N)
count if RightCoreTake == 1 & Continent == "South America"
local RightCoreSA = r(N)
count if RightCoreTake == 1 & Continent == "Asia"
local RightCoreAsia = r(N)
count if RightCoreTake == 1 & Continent == "Ozeania"
local RightCoreOz = r(N)
count if RightCoreTake == 1 & Continent == "North America"
local RightCoreNA = r(N)
count if RightCoreTake == 1 & Continent == "Africa"
local RightCoreAfrica = r(N)

******************************************************************************************
* 4) Repeat with Borderline Populists
count if BorderTake == 1 & Continent == "Europe"
local BorderEurope = r(N)
count if BorderTake == 1 & Continent == "South America"
local BorderSA = r(N)
count if BorderTake == 1 & Continent == "Asia"
local BorderAsia = r(N)
count if BorderTake == 1 & Continent == "Ozeania"
local BorderOz = r(N)
count if BorderTake == 1 & Continent == "North America"
local BorderNA = r(N)
count if BorderTake == 1 & Continent == "Africa"
local BorderAfrica = r(N)

count if LeftBorderTake == 1 & Continent == "Europe"
local LeftBorderEurope = r(N)
count if LeftBorderTake == 1 & Continent == "South America"
local LeftBorderSA = r(N)
count if LeftBorderTake == 1 & Continent == "Asia"
local LeftBorderAsia = r(N)
count if LeftBorderTake == 1 & Continent == "Ozeania"
local LeftBorderOz = r(N)
count if LeftBorderTake == 1 & Continent == "North America"
local LeftBorderNA = r(N)
count if LeftBorderTake == 1 & Continent == "Africa"
local LeftBorderAfrica = r(N)

count if RightBorderTake == 1 & Continent == "Europe"
local RightBorderEurope = r(N)
count if RightBorderTake == 1 & Continent == "South America"
local RightBorderSA = r(N)
count if RightBorderTake == 1 & Continent == "Asia"
local RightBorderAsia = r(N)
count if RightBorderTake == 1 & Continent == "Ozeania"
local RightBorderOz = r(N)
count if RightBorderTake == 1 & Continent == "North America"
local RightBorderNA = r(N)
count if RightBorderTake == 1 & Continent == "Africa"
local RightBorderAfrica = r(N)


******************************************************************************************
* 5) Repeat with Extended Populists

count if ExtTake == 1 & Continent == "Europe"
local ExtEurope = r(N)
count if ExtTake == 1 & Continent == "South America"
local ExtSA = r(N)
count if ExtTake == 1 & Continent == "Asia"
local ExtAsia = r(N)
count if ExtTake == 1 & Continent == "Ozeania"
local ExtOz = r(N)
count if ExtTake == 1 & Continent == "North America"
local ExtNA = r(N)
count if ExtTake == 1 & Continent == "Africa"
local ExtAfrica = r(N)

count if LeftExtTake == 1 & Continent == "Europe"
local LeftExtEurope = r(N)
count if LeftExtTake == 1 & Continent == "South America"
local LeftExtSA = r(N)
count if LeftExtTake == 1 & Continent == "Asia"
local LeftExtAsia = r(N)
count if LeftExtTake == 1 & Continent == "Ozeania"
local LeftExtOz = r(N)
count if LeftExtTake == 1 & Continent == "North America"
local LeftExtNA = r(N)
count if LeftExtTake == 1 & Continent == "Africa"
local LeftExtAfrica = r(N)

count if RightExtTake == 1 & Continent == "Europe"
local RightExtEurope = r(N)
count if RightExtTake == 1 & Continent == "South America"
local RightExtSA = r(N)
count if RightExtTake == 1 & Continent == "Asia"
local RightExtAsia = r(N)
count if RightExtTake == 1 & Continent == "Ozeania"
local RightExtOz = r(N)
count if RightExtTake == 1 & Continent == "North America"
local RightExtNA = r(N)
count if RightExtTake == 1 & Continent == "Africa"
local RightExtAfrica = r(N)


******************************************************************************************
* 6) Computing Matrix

matrix CountPopContinent = J(9, 6, 0)

* Fill the matrix with local macros
matrix CountPopContinent[1,1] = `CoreEurope'
matrix CountPopContinent[1,2] = `CoreSA'
matrix CountPopContinent[1,3] = `CoreAsia'
matrix CountPopContinent[1,4] = `CoreNA'
matrix CountPopContinent[1,5] = `CoreOz'
matrix CountPopContinent[1,6] = `CoreAfrica'

matrix CountPopContinent[2,1] = `LeftCoreEurope'
matrix CountPopContinent[2,2] = `LeftCoreSA'
matrix CountPopContinent[2,3] = `LeftCoreAsia'
matrix CountPopContinent[2,4] = `LeftCoreNA'
matrix CountPopContinent[2,5] = `LeftCoreOz'
matrix CountPopContinent[2,6] = `LeftCoreAfrica'

matrix CountPopContinent[3,1] = `RightCoreEurope'
matrix CountPopContinent[3,2] = `RightCoreSA'
matrix CountPopContinent[3,3] = `RightCoreAsia'
matrix CountPopContinent[3,4] = `RightCoreNA'
matrix CountPopContinent[3,5] = `RightCoreOz'
matrix CountPopContinent[3,6] = `RightCoreAfrica'

matrix CountPopContinent[4,1] = `BorderEurope'
matrix CountPopContinent[4,2] = `BorderSA'
matrix CountPopContinent[4,3] = `BorderAsia'
matrix CountPopContinent[4,4] = `BorderNA'
matrix CountPopContinent[4,5] = `BorderOz'
matrix CountPopContinent[4,6] = `BorderAfrica'

matrix CountPopContinent[5,1] = `LeftBorderEurope'
matrix CountPopContinent[5,2] = `LeftBorderSA'
matrix CountPopContinent[5,3] = `LeftBorderAsia'
matrix CountPopContinent[5,4] = `LeftBorderNA'
matrix CountPopContinent[5,5] = `LeftBorderOz'
matrix CountPopContinent[5,6] = `LeftBorderAfrica'

matrix CountPopContinent[6,1] = `RightBorderEurope'
matrix CountPopContinent[6,2] = `RightBorderSA'
matrix CountPopContinent[6,3] = `RightBorderAsia'
matrix CountPopContinent[6,4] = `RightBorderNA'
matrix CountPopContinent[6,5] = `RightBorderOz'
matrix CountPopContinent[6,6] = `RightBorderAfrica'

matrix CountPopContinent[7,1] = `ExtEurope'
matrix CountPopContinent[7,2] = `ExtSA'
matrix CountPopContinent[7,3] = `ExtAsia'
matrix CountPopContinent[7,4] = `ExtNA'
matrix CountPopContinent[7,5] = `ExtOz'
matrix CountPopContinent[7,6] = `ExtAfrica'

matrix CountPopContinent[8,1] = `LeftExtEurope'
matrix CountPopContinent[8,2] = `LeftExtSA'
matrix CountPopContinent[8,3] = `LeftExtAsia'
matrix CountPopContinent[8,4] = `LeftExtNA'
matrix CountPopContinent[8,5] = `LeftExtOz'
matrix CountPopContinent[8,6] = `LeftExtAfrica'

matrix CountPopContinent[9,1] = `RightExtEurope'
matrix CountPopContinent[9,2] = `RightExtSA'
matrix CountPopContinent[9,3] = `RightExtAsia'
matrix CountPopContinent[9,4] = `RightExtNA'
matrix CountPopContinent[9,5] = `RightExtOz'
matrix CountPopContinent[9,6] = `RightExtAfrica'

* Assign row and column names
matrix rownames CountPopContinent = Core Left_Core Right_Core Borderline Left_Borderline Right_Borderline Extended Left_Extended Right_Extended
matrix colnames CountPopContinent = Europe SouthAmerica Asia NorthAmerica Ozeania Africa

matrix list CountPopContinent

* Save Matrix as .log
log using "Tables/4_PopCountContinent.log", replace text
matrix list CountPopContinent
log close

clear


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Table 5 - Concentration of populist leaders on continents before and after 1990
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear

* 1) All Core Cases on their Continents and Time
count if CoreTake == 1 & Continent == "Europe" & year <= 1990
local B_CoreEurope = r(N)
count if CoreTake == 1 & Continent == "Europe" & year > 1990
local A_CoreEurope = r(N)
count if CoreTake == 1 & Continent == "South America" & year <= 1990
local B_CoreSA = r(N)
count if CoreTake == 1 & Continent == "South America" & year > 1990
local A_CoreSA = r(N)

* 2) All Borderline Cases on ther Continents and Time
count if BorderTake == 1 & Continent == "Europe"  & year <= 1990
local B_BorderEurope = r(N)
count if BorderTake == 1 & Continent == "Europe"  & year > 1990
local A_BorderEurope = r(N)
count if BorderTake == 1 & Continent == "South America" & year <= 1990
local B_BorderSA = r(N)
count if BorderTake == 1 & Continent == "South America" & year > 1990
local A_BorderSA = r(N)

* 3) All Core Cases on their Continents and Time
count if ExtTake == 1 & Continent == "Europe" & year <= 1990
local B_ExtEurope = r(N)
count if ExtTake == 1 & Continent == "Europe" & year > 1990
local A_ExtEurope = r(N)
count if ExtTake == 1 & Continent == "South America" & year <= 1990
local B_ExtSA = r(N)
count if ExtTake == 1 & Continent == "South America" & year > 1990
local A_ExtSA = r(N)


* 4) Constructing Matrix
matrix CountPopConTime = J(3, 4, 0)

* Fill the matrix with local macros
matrix CountPopConTime[1,1] = `B_CoreEurope'
matrix CountPopConTime[1,2] = `A_CoreEurope'
matrix CountPopConTime[1,3] = `B_CoreSA'
matrix CountPopConTime[1,4] = `A_CoreSA '

matrix CountPopConTime[2,1] = `B_BorderEurope'
matrix CountPopConTime[2,2] = `A_BorderEurope'
matrix CountPopConTime[2,3] = `B_BorderSA'
matrix CountPopConTime[2,4] = `A_BorderSA'

matrix CountPopConTime[3,1] = `B_ExtEurope'
matrix CountPopConTime[3,2] = `A_ExtEurope'
matrix CountPopConTime[3,3] = `B_ExtSA'
matrix CountPopConTime[3,4] = `A_ExtSA'

* Assign row and column names
matrix rownames CountPopConTime = Core Borderline Extended
matrix colnames CountPopConTime = Europe_B1990 Europe_A1990 SA_B1990 SA_A1990

* Display the matrix
matrix list CountPopConTime

* Save Matrix as .log
log using "Tables/5_PopContTime.log", replace text
matrix list CountPopConTime
log close

clear



******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Table 6 - Number of high Institutional Populists by Continent
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear
* Use MasterData

******************************************************************************************
* Identify Treated Countries
 bys cid (year): gen C_TreatCountry = 0
replace C_TreatCountry = 1 if CorePop == 1 
bysort cid (year): egen C_TreatCountryCID = max(C_TreatCountry)
bys cid (year): gen B_TreatCountry = 0
replace B_TreatCountry = 1 if BorderPop == 1 
bysort cid (year): egen B_TreatCountryCID = max(B_TreatCountry)
bys cid (year): gen E_TreatCountry = 0
replace E_TreatCountry = 1 if ExtPop == 1 
bysort cid (year): egen E_TreatCountryCID = max(E_TreatCountry)

******************************************************************************************
* Institutions of Populists coming to Power
bys cid (year): gen C_PopInst = .
replace C_PopInst = Institution_Index if CoreTake==1 & CoreTake != .
sum C_PopInst, detail
local C_InstMedian = r(p50)

bys cid (year): gen B_PopInst = .
replace B_PopInst = Institution_Index if BorderTake==1 & BorderTake != .
sum B_PopInst, detail
local B_InstMedian = r(p50)

bys cid (year): gen E_PopInst = .
replace E_PopInst = Institution_Index if ExtTake==1 & ExtTake != .
sum E_PopInst, detail
local E_InstMedian = r(p50)

******************************************************************************************
* Create high and low institution takeovers based on mean
gen C_High_Inst = .
replace C_High_Inst =1 if C_PopInst > `C_InstMedian' & C_PopInst != .
gen C_Low_Inst = .
replace C_Low_Inst =1 if C_PopInst <= `C_InstMedian' & C_PopInst != .

gen B_High_Inst = .
replace B_High_Inst =1 if B_PopInst > `B_InstMedian' & B_PopInst != .
gen B_Low_Inst = .
replace B_Low_Inst =1 if B_PopInst <= `B_InstMedian' & B_PopInst != .

gen E_High_Inst = .
replace E_High_Inst =1 if E_PopInst > `E_InstMedian' & E_PopInst != .
gen E_Low_Inst = .
replace E_Low_Inst =1 if E_PopInst <= `E_InstMedian' & E_PopInst != .

******************************************************************************************
* Core
count if C_High_Inst==1 & C_TreatCountryCID==1
local C_H = r(N)
count if C_Low_Inst==1 & C_TreatCountryCID==1
local C_L = r(N)
count if C_High_Inst==1 & C_TreatCountryCID==1 & Continent=="Europe"
local C_HE = r(N)
count if C_High_Inst==1 & C_TreatCountryCID==1 & Continent=="South America"
local C_HS = r(N)
count if C_Low_Inst==1 & C_TreatCountryCID==1 & Continent=="Europe"
local C_LE = r(N)
count if C_Low_Inst==1 & C_TreatCountryCID==1 & Continent=="South America"
local C_LS = r(N)

******************************************************************************************
* Border
count if B_High_Inst==1 & B_TreatCountryCID==1
local B_H = r(N)
count if B_Low_Inst==1 & B_TreatCountryCID==1
local B_L = r(N)
count if B_High_Inst==1 & B_TreatCountryCID==1 & Continent=="Europe"
local B_HE = r(N)
count if B_High_Inst==1 & B_TreatCountryCID==1 & Continent=="South America"
local B_HS = r(N)
count if C_Low_Inst==1 & B_TreatCountryCID==1 & Continent=="Europe"
local B_LE = r(N)
count if C_Low_Inst==1 & B_TreatCountryCID==1 & Continent=="South America"
local B_LS = r(N)

******************************************************************************************
* Extended
count if E_High_Inst==1 & E_TreatCountryCID==1
local E_H = r(N)
count if E_Low_Inst==1 & E_TreatCountryCID==1
local E_L = r(N)
count if E_High_Inst==1 & E_TreatCountryCID==1 & Continent=="Europe"
local E_HE = r(N)
count if E_High_Inst==1 & E_TreatCountryCID==1 & Continent=="South America"
local E_HS = r(N)
count if E_Low_Inst==1 & E_TreatCountryCID==1 & Continent=="Europe"
local E_LE = r(N)
count if E_Low_Inst==1 & E_TreatCountryCID==1 & Continent=="South America"
local E_LS = r(N)

******************************************************************************************
* Constructing Matrix 
matrix HighLowInstTakeOver = J(6, 4, 0)

* Fill the matrix with local macros
matrix HighLowInstTakeOver[1,1] = `C_H'
matrix HighLowInstTakeOver[1,2] = `C_HE'
matrix HighLowInstTakeOver[1,3] = `C_HS'
matrix HighLowInstTakeOver[1,4] = `C_InstMedian'

matrix HighLowInstTakeOver[2,1] = `C_L'
matrix HighLowInstTakeOver[2,2] = `C_LE'
matrix HighLowInstTakeOver[2,3] = `C_LS'
matrix HighLowInstTakeOver[2,4] = `C_InstMedian'

matrix HighLowInstTakeOver[3,1] = `B_H'
matrix HighLowInstTakeOver[3,2] = `B_HE'
matrix HighLowInstTakeOver[3,3] = `B_HS'
matrix HighLowInstTakeOver[3,4] = `B_InstMedian'

matrix HighLowInstTakeOver[4,1] = `B_L'
matrix HighLowInstTakeOver[4,2] = `B_LE'
matrix HighLowInstTakeOver[4,3] = `B_LS'
matrix HighLowInstTakeOver[4,4] = `B_InstMedian'

matrix HighLowInstTakeOver[5,1] = `E_H'
matrix HighLowInstTakeOver[5,2] = `E_HE'
matrix HighLowInstTakeOver[5,3] = `E_HS'
matrix HighLowInstTakeOver[5,4] = `E_InstMedian'

matrix HighLowInstTakeOver[6,1] = `E_L'
matrix HighLowInstTakeOver[6,2] = `E_LE'
matrix HighLowInstTakeOver[6,3] = `E_LS'
matrix HighLowInstTakeOver[6,4] = `E_InstMedian'

* Assign row and column names
matrix rownames HighLowInstTakeOver = HighCore LowCore HighBorderline LowBorderline HighExtended LowExtended
matrix colnames HighLowInstTakeOver = All Europe SouthAmerica Mean

* Display the matrix
matrix list HighLowInstTakeOver

* Save Matrix as .log
log using "Tables/6_HighLowInstTakeOver.log", replace text
matrix list HighLowInstTakeOver
log close

clear


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Conflicts
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear

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

* Create temporary conflict dataset
keep episode_ID t_Conflict_*
drop if episode_ID == .
reshape long t_Conflict_, i(episode_ID) j(epnum)
drop if episode_ID != 1
replace episode_ID = epnum
drop epnum
sum t_Conflict_, detail
local med_Conflict = r(p50)

save _Conflicts, replace
clear

******************************************************************************************
******************************************************************************************
use Master_Data, clear

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

keep if CoreTake==1

keep country year Continent episode_ID

merge 1:1 episode_ID using _Conflicts
drop _merge episode_ID

rename t_Conflict_ Conflict

sum Conflict, detail
local med_Conflict = r(p50)

gen HighStab = 1 if Conflict < `med_Conflict'
gen EuroHighStab = 1 if Conflict <= `med_Conflict' & Continent=="Europe"
egen HighStabNumber = sum(HighStab)
egen EuroHighStabNumber = sum(EuroHighStab)
gen RestHighStabNumber = HighStabNumber - EuroHighStabNumber

gen LowStab = 1 if Conflict >= `med_Conflict'
gen EuroLowStab = 1 if Conflict <= `med_Conflict' & Continent=="Europe"
egen LowStabNumber = sum(LowStab)
egen EuroLowStabNumber = sum(EuroLowStab)
gen RestLowStabNumber = LowStabNumber - EuroLowStabNumber

drop if country != "Bolivia"
keep *Number

save Tables/8_CoreStability.dta, replace

cap !del _*
cap !rm _*.dta

clear

sleep 10

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Coup d'Etat
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Master_Data, clear

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
	gen range_Coup_`i' = 1 if in_window_`i'==1 & Coup==1
	egen t_Coup_`i'= max(range_Coup_`i')
	replace t_Coup_`i' = 0 if t_Coup_`i'== .
	
	gen refyear_`i' = (tyear_`i') if year == tyear_`i'
	* Important for normalization of GDPpc growth later
}

* Create temporary conflict dataset
keep episode_ID t_Coup_*
drop if episode_ID == .
reshape long t_Coup_, i(episode_ID) j(epnum)
drop if episode_ID != 1
replace episode_ID = epnum
drop epnum
sum t_Coup_, detail

rename t_Coup_ Coup

save _Coup, replace
clear

******************************************************************************************
******************************************************************************************
use Master_Data, clear

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

keep if CoreTake==1

keep country year Continent episode_ID

merge 1:1 episode_ID using _Coup
drop _merge episode_ID

gen byte EuroCoup = 0
replace EuroCoup=1 if Coup==1 & Continent=="Europe"
egen NumberEuroCoup = sum(EuroCoup)

gen byte RestCoup = 0
replace RestCoup=1 if Coup==1 & Continent!="Europe"
egen NumberRestCoup = sum(RestCoup)


save Tables/9_CoreCoup.dta, replace

cap !del _*
cap !rm _*.dta

clear

sleep 10


******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
* Appendix Number of Populists across time for Core and Borderline Sample
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Borderline Populists over time
use Master_Data, clear

* 1) Prepare the data for future extrapolation
bysort cid : gen order = _n
by cid : gen last = _n == _N

* 2) Expand last observation 3 times to project forward
expand 3 if last
sort iso year

* 3) Update years for duplicated 2019
bysort iso : replace year = 2020 if year == 2019 & year[_n-1] == 2019
bysort iso : replace year = 2021 if year == 2019 & year[_n-1] == 2020

* 4) Handle missing or special cases
replace BorderPop = . if year == 2021
replace BorderPop = 0 if year == 2020 & inlist(iso,"GRC","BOL")
replace LeftBorderPop = 0 if year == 2020 & inlist(iso,"GRC","BOL")

* 5) Aggregate to total by year
foreach v in independent BorderPop LeftBorderPop RightBorderPop {
    egen `v'by = sum(`v'), by(year)
}

* 6) Calculate percentage shares
gen sh  = BorderPopby / independentby * 100
gen shl = LeftBorderPopby / independentby * 100
gen shr = RightBorderPopby / independentby * 100

* 7) Prepare label variable for left vs right populism
gen lrstr = ""
replace lrstr = "Left-wing populism" if LeftBorderPop == 1
replace lrstr = "Right-wing populism" if RightBorderPop == 1
gen zero=0

* 8) Prepare for future marking
egen BorderPop_id = max(BorderPop == 1), by(country)
replace BorderPop = 1 if year == 2021 & BorderPop_id == 1
replace lrstr = "2021" if year == 2021 & BorderPop_id == 1

* 9) Create the Plot
tw ///
	(rarea shl sh year, color(gs5) lcolor(gs6) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
	(rarea shl zero year, col(gs11) lcolor(gs11) lp(solid) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
	(line sh year, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort) ///
	if year>=1900 & year <=2020, ///
	xlabel(1900 1920 1940 1960 1980 2000 2020, labsize(medium)) ///
	ylabel(0 5 10 15 20 25 30, angle(0) labsize(medium) nogrid) ///
	xtitle("", size(medsmall) margin(medium)) ///
	ytitle("Share of independent countries with populist government (%)", size(small) margin(medium)) ///
	scheme(s1mono) ///
	graphregion(color(white) lcolor(white) margin(b-3 l-5)) ///
	ysize(6) ///
	xsize(9) ///
	legend(rows(1) order(3 "Populist governments" 1 "Right-wing populism" 2 "Left-wing populism") ///
	symxsize(*0.3) ///
	symysize(*0.3) ///
	region(lwidth(none)) ///
	forcesize ///
	size(medlarge)) 

* 10) Save the Plot as pdf
graph export "Figures/Append_2_BorderPopOverTime.pdf", replace

clear


******************************************************************************************
* Core Populists over time
use Master_Data, clear

* 1) Prepare the data for future extrapolation
bysort cid : gen order = _n
by cid : gen last = _n == _N

* 2) Expand last observation 3 times to project forward
expand 3 if last
sort iso year

* 3) Update years for duplicated 2019
bysort iso : replace year = 2020 if year == 2019 & year[_n-1] == 2019
bysort iso : replace year = 2021 if year == 2019 & year[_n-1] == 2020

* 4) Handle missing or special cases
replace CorePop = . if year == 2021
replace CorePop = 0 if year == 2020 & inlist(iso,"GRC","BOL")
replace LeftCorePop = 0 if year == 2020 & inlist(iso,"GRC","BOL")

* 5) Aggregate to total by year
foreach v in independent CorePop LeftCorePop RightCorePop {
    egen `v'by = sum(`v'), by(year)
}

* 6) Calculate percentage shares
gen sh  = CorePopby / independentby * 100
gen shl = LeftCorePopby / independentby * 100
gen shr = RightCorePopby / independentby * 100

* 7) Prepare label variable for left vs right populism
gen lrstr = ""
replace lrstr = "Left-wing populism" if LeftCorePop == 1
replace lrstr = "Right-wing populism" if RightCorePop == 1
gen zero=0

* 8) Prepare for future marking
egen CorePop_id = max(CorePop == 1), by(country)
replace CorePop = 1 if year == 2021 & CorePop_id == 1
replace lrstr = "2021" if year == 2021 & CorePop_id == 1

* 9) Create the Plot
tw ///
	(rarea shl sh year, color(gs5) lcolor(gs6) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
	(rarea shl zero year, col(gs11) lcolor(gs11) lp(solid) lp(solid) lwidth(vvthin) plotr(m(vsmall)) sort) ///
	(line sh year, lcolor(red) lp(solid) lwidth(thick) plotr(m(vsmall)) sort) ///
	if year>=1900 & year <=2020, ///
	xlabel(1900 1920 1940 1960 1980 2000 2020, labsize(medium)) ///
	ylabel(0 5 10 15 20 25 30, angle(0) labsize(medium) nogrid) ///
	xtitle("", size(medsmall) margin(medium)) ///
	ytitle("Share of independent countries with populist government (%)", size(small) margin(medium)) ///
	scheme(s1mono) ///
	graphregion(color(white) lcolor(white) margin(b-3 l-5)) ///
	ysize(6) ///
	xsize(9) ///
	legend(rows(1) order(3 "Populist governments" 1 "Right-wing populism" 2 "Left-wing populism") ///
	symxsize(*0.3) ///
	symysize(*0.3) ///
	region(lwidth(none)) ///
	forcesize size(medlarge)) 

* 10) Save the Plot as pdf
graph export "Figures/Append_1_CorePopOverTime.pdf", replace

clear


* Für alle Tables: Vielleicht schöner erstellen und gucken, dass es auch über Run_Replication klappt!



