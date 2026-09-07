******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Create Dataset with following Variables
******************************************************************************************
******************************************************************************************
******************************************************************************************

* country (Contains CountryName)
* iso (3 Digit Short for CountryName)
* year (Year from 1900 to 2023)
* cid (Country ID)
* realGDPpc (Real GDPpc from Multiple Sources Indexed to 2005)
* Institution_Index1 (1. Principle Component Indicator of Dem_Index, clean_elec, JuConEx)
* Institution_Index2 (1. PC Indicator also including LegConEx)
* Dem_Index (Democracy Index from -10 to +10 from Polity5)
* clean_elec (Free and Fair Elections Index from 0 to 1 from V-Dem - 1 high and 0 low)
* JuConEx (Judicial Constraints on Executive Index from 0 to 1 from V-Dem)
* LegConEx (Legal Constraints on Executive Index from 0 to 1 from V-Dem)
* MulParElec (Multiparty Elections allowed from 0 to 4 from V-Dem - 0 bad and 4 perfect)
* BarPar (Other Parties barred from Elections from 0 to 4 from V-Dem)
* RespCon (Executive Respects Constitution from 0 to 4 from V-Dem)
* PubCor (Public Sector Corruption from 0 to 4 from V-Dem)
* Censorship (Media Censorship from 0 to 4 from V-Dem)
* FreeMedia (Access to alternative Media / Free Media Index from 0 to 1 from V-Dem)
* BankCrisis (Start of Systemic Banking Crises dummy 0-1 from 1900 to 2019)
* CurrencyCrisis (Start of Currency Crises dummy 0-1 from 1900 to 2019)
* DebtCrisis (Start of Debt Crises dummy 0-1 from 1900 to 2019)
* Coup (Year with successfull or attempted Coup 0 or 1 from 1900 to 2019)
* Inflation (CPI From 1900 to 2023 Indexed to 2010)
* TradeShare (Export Share + Import Share = Trade Share of real GDP from 1900 to 2023)
* Gini (From disposible (after tax) income from 1960 to 2022/2023)
* DebtShare (Debt Share of real GDP from 1900 to 2023)
* LaborShare (Labor Share of real GDP from 1950 to 2023 through PennWorldTable)
* Tariffs (Matched from FOHR and WDI to gain data indexed to 2013 from 1960s to 2023)
* FinOpen (Financial Openness Index from 1970 to 2022)
* TradeOpen (Trade Openness Index from 1970 to 2022)
* UnemploymentRate (From 1950s to 2023)
* Conflicts (Number of Social Conflics including Riots, General Strikes, and Revolts from 1930 to 2020)
* WorldWar (Dummy whether World War is happening (WW1 and WW2))
* Independence (dummy when it gained independence)
* Advanced (Whether a nation is an advanced economy dummy)

* Populists
* PopLeft
* PopRight

* Core
* CoreLeft
* CoreRight
* CoreStable
* CoreUnstable

* Border
* BorderLeft
* BorderRight
* Extend
* ExtendLeft
* ExtendRight
	
******************************************************************************************
******************************************************************************************
******************************************************************************************
****Skeleton panel dataset (Taken from Replication Package)
******************************************************************************************
******************************************************************************************
******************************************************************************************


clear all
* Clears all of Stata code and data
set obs 60
* Creates new skeleton dataset with 60 observations

gen country=""
replace country="Argentina"        in 1 
replace country="Australia"        in 2 
replace country="Austria"          in 3
replace country="Belgium"          in 4 
replace country="Bolivia"          in 5 
replace country="Brazil"           in 6 
replace country="Bulgaria"         in 7 
replace country="Canada"           in 8 
replace country="Chile"            in 9 
replace country="China"            in 10 
replace country="Colombia"         in 11
replace country="Croatia"          in 12
replace country="Cyprus"     	   in 13
replace country="Czech Republic"   in 14
replace country="Denmark"          in 15
replace country="Ecuador"          in 16
replace country="Egypt"            in 17
replace country="Estonia"          in 18
replace country="Finland"          in 19
replace country="France"           in 20
replace country="Germany"          in 21 
replace country="Greece"           in 22
replace country="Hungary"          in 23
replace country="Iceland"          in 24
replace country="India"            in 25
replace country="Indonesia"        in 26
replace country="Ireland"          in 27
replace country="Israel"           in 28
replace country="Italy"            in 29
replace country="Japan"            in 30
replace country="Latvia"           in 31 
replace country="Lithuania"        in 32
replace country="Luxembourg"       in 33 
replace country="Malaysia"         in 34 
replace country="Malta"            in 35 
replace country="Mexico"           in 36
replace country="Netherlands"      in 37 
replace country="New Zealand"      in 38 
replace country="Norway"           in 39 
replace country="Paraguay"         in 40 
replace country="Peru"             in 41
replace country="Philippines"      in 42
replace country="Poland"           in 43
replace country="Portugal"         in 44
replace country="Romania"          in 45
replace country="Russia"           in 46
replace country="Slovakia"         in 47
replace country="Slovenia"         in 48
replace country="South Africa"     in 49 
replace country="South Korea"      in 50
replace country="Spain"            in 51
replace country="Sweden"           in 52
replace country="Switzerland"      in 53
replace country="Taiwan"           in 54
replace country="Thailand"         in 55
replace country="Turkey"           in 56
replace country="United Kingdom"   in 57
replace country="United States"    in 58
replace country="Uruguay"          in 59
replace country="Venezuela"        in 60
* Creates country observations

gen iso=""
replace iso="ARG"        in 1 
replace iso="AUS"        in 2 
replace iso="AUT"        in 3
replace iso="BEL"        in 4 
replace iso="BOL"        in 5 
replace iso="BRA"        in 6 
replace iso="BGR"        in 7 
replace iso="CAN"        in 8 
replace iso="CHL"        in 9 
replace iso="CHN"        in 10 
replace iso="COL"        in 11
replace iso="HRV"        in 12
replace iso="CYP"     	 in 13
replace iso="CZE"        in 14
replace iso="DNK"        in 15
replace iso="ECU"        in 16
replace iso="EGY"        in 17
replace iso="EST"        in 18
replace iso="FIN"        in 19
replace iso="FRA"        in 20
replace iso="DEU"        in 21 
replace iso="GRC"        in 22
replace iso="HUN"        in 23
replace iso="ISL"        in 24
replace iso="IND"        in 25
replace iso="IDN"        in 26
replace iso="IRL"        in 27
replace iso="ISR"        in 28
replace iso="ITA"        in 29
replace iso="JPN"        in 30
replace iso="LVA"        in 31 
replace iso="LTU"        in 32
replace iso="LUX"        in 33 
replace iso="MYS"        in 34 
replace iso="MLT"        in 35 
replace iso="MEX"        in 36
replace iso="NLD"        in 37 
replace iso="NZL"        in 38 
replace iso="NOR"        in 39 
replace iso="PRY"        in 40 
replace iso="PER"        in 41
replace iso="PHL"        in 42
replace iso="POL"        in 43
replace iso="PRT"        in 44
replace iso="ROU"        in 45
replace iso="RUS"        in 46
replace iso="SVK"        in 47
replace iso="SVN"        in 48
replace iso="ZAF"        in 49 
replace iso="KOR"        in 50
replace iso="ESP"        in 51
replace iso="SWE"        in 52
replace iso="CHE"        in 53
replace iso="TWN"        in 54
replace iso="THA"        in 55
replace iso="TUR"        in 56
replace iso="GBR"        in 57
replace iso="USA"        in 58
replace iso="URY"        in 59
replace iso="VEN"        in 60
* Creates ISO codes

expand 124
* Expands for each country by 154 cells
bysort country: gen year = 1900 + [_n-1]
egen cid = group(country)
xtset cid year
* Sorts each country and assigns years to each country from 1900 to 2024


save panel, replace
clear
* Saves skeleton as "panel"

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including real GDP PC Data
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Data/GMD, clear
keep countryname year rGDP_pc 
rename (countryname rGDP_pc) (country GMD_GDPpc)
replace country="Russia" if country == "Russian Federation"
save _GMD_GDPpc, replace

******************************************************************************************

******************************************************************************************

* MacroHistory from Schularik from 1870 to 2010 Indexed to 2005
use Data/MacroHistory, clear
* use only for .dta
* Import Datafile and clear previously used data
keep year iso rgdpbarro
drop if iso==""
rename (rgdpbarro) (Hist_GDPpc)
save _Hist_GDPpc, replace

******************************************************************************************

* Barro-Ursua from 1790 to 2010 Indexed to 2006
import excel using Data/BU_Macro, sheet("GDP") firstrow clear
* sheet("GDP") tells Stata which Escel Sheet it shall use
foreach v of varlist (Argentina-Venezuela) {
	rename `v' id`v'
	}
* Renames variables to idvariables  
reshape long id, j(country) i(GDPpc) string
* string means that country is in text format
drop if GDPpc == "Indexes, 2006=100"
* Drops one row
rename (GDPpc id) (year GDPpc)
destring GDPpc year, replace
* destring removes string command (converts GDPpc and year into numeric)
replace country = "South Korea" if country=="Korea"
* replaces names for easier management
replace country = "New Zealand" if country=="NewZealand"
replace country = "South Africa" if country=="SAfrica"
replace country = "United Kingdom" if country=="UnitedKingdom" 
replace country = "United States" if country=="UnitedStates"
rename GDPpc BU_GDPpc
save _BU_GDPpc, replace

******************************************************************************************

* MaddisonProject from 1000 to 2022 Indexed to 20??
use Data/MaddisonProject2023, clear
drop if countrycode==""
keep countrycode year gdppc
rename (countrycode gdppc) (iso Maddison_GDPpc)
save _Maddison_GDPpc, replace

******************************************************************************************
******************************************************************************************
* Matching Real GDPpc into Skeleton
use panel, clear
merge 1:1 country year using _BU_GDPpc
drop if _merge==2
drop _merge
* Seperate because no iso 
local set1 Maddison_GDPpc Hist_GDPpc
foreach s of local set1 {
	merge 1:1 iso year using _`s'
	drop if _merge==2
	drop _merge
}
merge 1:1 country year using _GMD_GDPpc
drop if _merge==2
drop _merge
* Seperate because they have iso
* Merge all prepared datasets with GDPpc with panel dataset
destring Maddison_GDPpc Hist_GDPpc BU_GDPpc GMD_GDPpc, replace force
* Because WDI_GDPpc is still in string for some reason
local set2 Maddison_GDPpc Hist_GDPpc BU_GDPpc GMD_GDPpc
* Define new set for which the following is done
gen byte base = 1 if year==2005	
* Generate new base-year	
foreach s of local set2 {			
		bys cid (base): gen `s'_i = `s'/`s'[1]*100
        bys cid: egen m`s'i = max(`s'_i)
		}		
* bys cid (base) = sorted by cid with 2005 first (since 2005 = 1 and otherwise = .)
* Defines new variable xi for all GDPpc which is index swapped to 2005 (divide each year value by value in 2005 * 100)
* This swapes the index to 2005 = 100 and all other years are relative
* Defines new variables mxi for all GDPpc used for fallback as the maximum indexed GDP value for each country 
* Maximum value used to check for missing values as fallback
*gen fstgdp = WDI_GDPpc_i if year>=2005
gen fstgdp = GMD_GDPpc_i if year>=2005

* Generate new Variable fstgdp for which WDI_GDPpc_i(Index2005) is used for all years after 2005
replace fstgdp = Hist_GDPpc_i if year<=2004 & mHist_GDPpci!=.
* For fstgdp use Hist_GDPpc_i for all years before 2005 if its maximum value (mHist_GDPpci) is not missing
* This means it uses Hist_GDPpc_i only if its the maximum GDPpc value of all datasets
replace fstgdp = BU_GDPpc_i if year<=2004 & mHist_GDPpci==. & mBU_GDPpci!=.
* Use BU_GDPpc_i only if Hist_GDPpc_i is not the maximum value and BU_GDPpc_i is maximum value
replace fstgdp = Maddison_GDPpc_i if year<=2004 & mHist_GDPpc==. & mBU_GDPpci==. & mMaddison_GDPpci!=.
* Use Maddison_GDPpc_i only if Hist and BU are not maximum values
replace fstgdp = Maddison_GDPpc_i if year>=2005 & iso=="TWN"
* Use Maddison for TWN instead of WDI for all years after 2004
* replace fstgdp = GMD_GDPpc_i if year>=2005 & country=="Venezuela"
* Use GMD data for missing venezuela data 
bys cid: ipolate fstgdp year, gen(fstgdp_ipo)
replace fstgdp = fstgdp_ipo if fstgdp==.
* Interpolate missing values in fstgdp linearly
drop BU* b* m* H* M* *_i* GMD_*
* Drop all but fstgdp
rename fstgdp realGDPpc

save panel, replace 
clear
cap !del _*
cap !rm _*.dta
* Deletes all prepared datasets starting with "_"
* Cap supresses errors if files do not exist


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Democracy/Autocracy Index
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Autocracy (-10) vs. Democracy (+10) Index 
import excel using Data/INSCR_Polity5, sheet("p5v2018") firstrow clear
keep polity2 country year
* Polity2 is the newer indicator 
drop if country==""
drop if (year==1945 | year==1990) & country=="Germany West"
* | means "or"
* Both years are dropped since they also exist with Germany and are non usable data in Germany West
drop if (country=="Ethiopia" | country=="Yugoslavia")
drop if year==1922 & country=="Russia" 
* Unusable data 
* Data can be interpolated later
replace country="South Korea" if (country=="Korea South" | country=="Korea") 
replace country="Czech Republic" if country=="Czechoslovakia"
replace country="Slovakia" if country=="Slovak Republic"
replace country="Germany" if country=="Germany West"
* replace country="United States" if scode=="USA"
* not found any scode USA
replace country="Russia" if country=="USSR"
* For harmonizing country names
save _polity, replace

use panel, clear

merge 1:1 country year using _polity, keepusing(polity2)
* keepusing(x) means that only the variable x is merged into the used dataset
* Merges panel with _polity sets on country and year while only importing the polity2 datapoints
drop if _merge ==2
* Nothing here but still just in case
drop _merge

cap !del _* 
cap !rm _*.dta 

sort country year 
* sorts first be countryname and then by year  
bysort country (year): replace polity2 = polity2[_n-1] if missing(polity2) & year >= 2019 & year <= 2023
* carries 2018 value forward to 2023
replace polity2 = . if polity2 <= -11
* deletes all polity2 values smaller than 10 (unreadable data)
* Nothing here but just in case
bys cid: ipolate polity2 year if iso=="BGR" & year>=1912 & year<=1914, gen(_BGR)
bys cid: ipolate polity2 year if iso=="TUR" & year>=1917 & year<=1922, gen(_TUR)
bys cid: ipolate polity2 year if iso=="CHN" & year>=1936 & year<=1946, gen(_CHN)
bys cid: ipolate polity2 year if iso=="GRC" & year>=1915 & year<=1920, gen(_GRC)
bys cid: ipolate polity2 year if iso=="HUN" & year>=1955 & year<=1957, gen(_HUN)
bys cid: ipolate polity2 year if iso=="JPN" & year>=1944 & year<=1952, gen(_JPN)
bys cid: ipolate polity2 year if iso=="DEU" & year>=1944 & year<=1949, gen(_DEU)
* Interpolates all missing values for certain countries as new variables for merging later
local cous1 BGR TUR CHN GRC HUN JPN DEU
* Creates a macro for all mentioned iso codes
foreach c of local cous1 {
		replace polity2 = _`c' if iso=="`c'" & polity2==. & _`c'!=.	
		}
* replaces the empty variables that were interpolated with the interpolated values for the macro

drop if cid == 0 | missing(cid)
* deletes all countries not in the pre-selected 60

rename polity2 Dem_Index

save panel, replace 
clear

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including different Institutions from V-Dem and Constructing an Institutions Index
******************************************************************************************
******************************************************************************************
******************************************************************************************

*Clean elections index (v2xel_frefair) - 0 to 1 interval index
*Judicial Constraints on the executive index (v2x_jucon) - 0 to 1 interval index
*Alternative sources of information index / Media freedom (v2xme_altinf) - 0 to 1 interval index

* Including V-Dem V15 Dataset for Institutions Measures
use Data/V-Dem-CY-Core-v15.dta, clear
keep country_name year v2xel_frefair v2x_jucon v2xme_altinf
rename (country_name v2xel_frefair v2x_jucon v2xme_altinf) (country CleanElections Judicial FreeMedia)
replace country="United States" if country=="United States of America"
replace country="Turkey" if country=="Türkiye"
replace country="Czech Republic" if country=="Czechia"
save _institutions, replace 
clear

use panel, clear
merge 1:1 country year using _institutions
drop if _merge==2
drop _merge

local vdem1 Judicial CleanElections FreeMedia
local cous2 DEU AUT POL

foreach v of local vdem1 {
	
	bys cid: ipolate `v' year if iso=="DEU" & year>=1944 & year<=1949, gen(_`v'_DEU) 
	bys cid: ipolate `v' year if iso=="AUT" & year>=1938 & year<=1945, gen(_`v'_AUT)
	bys cid: ipolate `v' year if iso=="POL" & year>=1938 & year<=1944, gen(_`v'_POL)

				foreach c of local cous2 {
				replace `v' = _`v'_`c' if iso=="`c'" & `v'==. & _`v'_`c'!=.
				}
		}
* Interpolates missing values fro WW2 for Judicial CleanElections and FreeMedia


pca CleanElections Judicial FreeMedia Dem_Index 
* Legal - Man könnte Legal auch benutzen für den Index
predict Institution_Index

sort iso year
forvalues i=1/8 {
* For values 1 to 8 do the following loop
	replace Institution_Index = Institution_Index[_n+`i'] if iso=="SVK" & (year== 1993-`i')
	}
* Replace institutions for years 1993 - (1 to 8) with institutions from 1993
* Adds missing values for slovakia

drop _*

sort country year

save panel, replace 
clear

cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Preparing Financial Crises Data (Currency, Debt, Systemic Banking)
******************************************************************************************
******************************************************************************************
******************************************************************************************

* This section combines data from A New Comprehensive database of financial crises: Identification, frequency, and duration
* With data from the SystemicBankingCrisesDatabase2

* Temporary CountryName Dataset
use panel, clear
keep if year == 2000
keep country
save _countries, replace 
clear

* Temporary CountryNameYear Dataset
use panel, clear
keep country year
save _countriesyears, replace 

******************************************************************************************
******************************************************************************************
* First Crises Data Bank for Currency, Systemic Banking and Debt
import excel using Data/FinancialCrisisData2019, firstrow clear
keep Country Year BankingCrises CurrencyCrises DebtCrises

rename (Country Year) (country year)

* Adding 6 missing countries - egypt, russia, slovakia, south korea, taiwan, venezuela
replace country="Egypt" if country=="Egypt, Arab Rep."
replace country="Russia" if country=="Russian Federation"
replace country="Slovakia" if country=="Slovak Republic"
replace country="South Korea" if country=="Korea, Rep."
replace country="Taiwan" if country=="Taiwan, China"
replace country="Venezuela" if country=="Venezuela, RB"

sort country year
gen byte start_BankCrisis = .
* Creates new variable start_crisis
bysort country (year): replace start_BankCrisis = 1 if BankingCrises == 1 & (BankingCrises[_n-1] != 1 | _n == 1)
replace start_BankCrisis = . if start_BankCrisis != 1

gen byte start_CCrisis = .
* Creates new variable start_crisis
bysort country (year): replace start_CCrisis = 1 if CurrencyCrises == 1 & (CurrencyCrises[_n-1] != 1 | _n == 1)
replace start_CCrisis = . if start_CCrisis != 1

gen byte start_DebtCrisis = .
* Creates new variable start_crisis
bysort country (year): replace start_DebtCrisis = 1 if DebtCrises == 1 & (DebtCrises[_n-1] != 1 | _n == 1)
replace start_DebtCrisis = . if start_DebtCrisis != 1

drop BankingCrises CurrencyCrises DebtCrises
drop if year == .

merge 1:1 country year using _countriesyears.dta
keep if _merge==3
* Keeps only if in both sets
drop _merge

save _crisesData2019, replace
clear



******************************************************************************************
******************************************************************************************
* Currency from SystemicBankingCrisesDatabase2
import excel using Data/SystemicBankingCrisesDatabase2, sheet("Crisis Years") firstrow clear
keep Country CurrencyCrisis
rename CurrencyCrisis ccris
rename Country country
drop in 1
* Contains empty row
drop if country=="Myanmar"
* Country made problems with destring later

replace country="China" if country=="China, P.R."
replace country="Slovakia" if country=="Slovak Republic"
replace country="South Korea" if country=="Korea"
*Adds in Missing Countries form Original 

split ccris, p(", ")
* Splits Excel Cell into Multiples but keeps original cell
drop ccris
* Drops the original Excel Cell that has multiple datas
destring ccris1 ccris2 ccris3 ccris4 ccris5 ccris6 ccris7, replace
* Destrings into Numbers not text

merge 1:1 country using _countries.dta
keep if _merge==3
* Keeps only if in both sets
drop _merge

* Malta Missing
* Taiwan Missing
* Both not in data

drop if ccris1 == . & ccris2 == . & ccris3 == . & ccris4 == . & ccris5 == . & ccris6 == . & ccris7


local chron ccris1 ccris2 ccris3 ccris4 ccris5 ccris6 ccris7
foreach c of local chron {
preserve
keep country `c'
rename `c' sbcs
save _`c', replace
restore
}
* Creates multiple datapackages with currency crises
* First step in conveting years in ccris into year in panel

use _ccris1, clear
append using _ccris2
append using _ccris3
append using _ccris4
append using _ccris5
append using _ccris6
append using _ccris7
drop if sbcs==.
rename sbcs year 
gen start_CCrisis = 1
save _CurrencyCrisesUpdate2020, replace
clear
* Generates variable that is one for each year 
* Combines year and ccris

******************************************************************************************
******************************************************************************************
* Systemic Banking Crises Data from SystemicBankingCrisesDatabase2
import excel using Data/SystemicBankingCrisesDatabase2, sheet("Crisis Years") firstrow clear
keep Country SystemicBankingCrisisstartin
rename SystemicBankingCrisisstartin sbcs
rename Country country

split sbcs, p(", ")
* Splits Excel Cell into Multiples but keeps original cell
drop sbcs
* Drops the original Excel Cell that has multiple datas
destring sbcs1 sbcs2 sbcs3 sbcs4, replace
* Destrings into Numbers not text

replace country="China" if country=="China, P.R."
replace country="Slovakia" if country=="Slovak Republic"
replace country="South Korea" if country=="Korea"

merge 1:1 country using _countries.dta
keep if _merge==3
drop _merge

* Malta Missing
* Taiwan Missing
* Both not in data

drop if sbcs1 == . & sbcs2 == . & sbcs3 == . & sbcs4 == . 
* Drops empty values

local chron sbcs1 sbcs2 sbcs3 sbcs4
foreach c of local chron {
preserve
keep country `c'
rename `c' sbcs
save _`c', replace
restore
}
* Creates multiple datapackages with systemic banking crises
* First step in conveting years in sbcs into year in panel

use _sbcs1, clear
append using _sbcs2
append using _sbcs3
append using _sbcs4
drop if sbcs==.
rename sbcs year 
replace year=1984 if year==1983 & (country=="Israel" | country=="Peru") 
drop if (country=="Cyprus" | country=="United Kingdom")
gen start_BankCrisis = 1
save _SystemicBCUpdateII2020, replace
clear
* Generates variable that is one for each year 
* Combines year and sbcs 

******************************************************************************************
******************************************************************************************
* Systemic Banking Crises Data from MacroHistory
use Data/MacroHistory, clear
keep country year crisisJST

replace crisisJST = . if crisisJST==0
rename crisisJST start_BankCrisis

save _HistBankCrisis, replace 
clear

use _countriesyears, clear

merge 1:1 country year using _HistBankCrisis
drop if _merge==2
drop _merge

save _HistBankCrisis, replace 
clear

******************************************************************************************
******************************************************************************************
* Financial Crisis from Global Macro Database from 1900 to 2021
use Data/GMD, clear

rename countryname country
rename CurrencyCrisis CurCrisis
replace country="Russia" if country == "Russian Federation"
keep country year SovDebtCrisis CurCrisis BankingCrisis

replace SovDebtCrisis = . if SovDebtCrisis == 0
replace CurCrisis = . if CurCrisis == 0
replace BankingCrisis = . if BankingCrisis == 0

save _newcrisis, replace
clear


******************************************************************************************
******************************************************************************************
**** Including Financial Crises Data
******************************************************************************************
******************************************************************************************

* Merging Temporary Datasets
use _countriesyears, clear

merge 1:1 country year using _HistBankCrisis
drop if _merge==2
drop _merge

merge 1:1 country year using _crisesData2019
drop _merge

merge 1:1 country year using _CurrencyCrisesUpdate2020
drop _merge

merge 1:1 country year using _SystemicBCUpdateII2020
drop _merge

merge 1:1 country year using _newcrisis
drop if _merge == 2
drop _merge

gen _BankCrisis = 1 if start_BankCrisis == 1 | BankingCrisis == 1
gen _CurrencyCrisis = 1 if start_CCrisis == 1 | CurCrisis == 1
gen _DebtCrisis = 1 if start_DebtCrisis == 1 | SovDebtCrisis == 1

drop start_* BankingCrisis CurCrisis SovDebtCrisis

* To have no years of consequtive starts of crises
sort country year

gen start_BankCrisis = _BankCrisis   
bysort country (year): gen prev_crisis = _BankCrisis[_n-1]
replace start_BankCrisis = . if _BankCrisis == 1 & prev_crisis == 1
drop prev_crisis

gen start_CCrisis = _CurrencyCrisis   
bysort country (year): gen prev_crisis = _CurrencyCrisis[_n-1]
replace start_CCrisis = . if _CurrencyCrisis == 1 & prev_crisis == 1
drop prev_crisis

gen start_DebtCrisis = _DebtCrisis   
bysort country (year): gen prev_crisis = _DebtCrisis[_n-1]
replace start_DebtCrisis = . if _DebtCrisis == 1 & prev_crisis == 1
drop prev_crisis

drop _*

save _financialcises2019, replace
clear

******************************************************************************************
******************************************************************************************
* Including into Skeleton

use panel, clear
merge 1:1 country year using _financialcises2019
drop _merge

rename start_BankCrisis BankCrisis
rename start_CCrisis CurrencyCrisis
rename start_DebtCrisis DebtCrisis

replace BankCrisis=0 if BankCrisis==.
replace CurrencyCrisis=0 if CurrencyCrisis==.
replace DebtCrisis=0 if DebtCrisis==.

gen FinCrisis = 0
replace FinCrisis = 1 if BankCrisis==1 | CurrencyCrisis==1 | DebtCrisis==1

* drop BankCrisis CurrencyCrisis DebtCrisis

save panel, replace
clear

cap !del _*
cap !rm _*.dta

* Germany has no currency crisis in the 1920s ???


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Coup d'Etat Crises (Using Coup data from Polity5 from 1950 to 2021)
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year
save _countriesyears, replace 


import excel using Data/INSCR_Coup_2021, sheet("Sheet1") firstrow clear
keep country year scoup1 atcoup2
* Keeps only successfull and atempted coups for a measure of stability

ds, has(type numeric)
foreach var of varlist `r(varlist)' {
    replace `var' = . if `var' == 0
}
* Replaces all 0 with . for all numeric values

rename scoup1 SCoup
rename atcoup2 ACoup

* Iceland, Malta,  missing data
replace country="Myanmar" if country =="Myanmar (Burma)"
replace country="South Korea" if country=="Korea South"
replace country="Slovakia" if country=="Slovak Republic"
replace country="Germany" if country=="Germany West"
replace country="Czech Republic" if country=="Czechoslovakia"
replace country="Russia" if country=="USSR"

* Croatia before 1991
* Estonia before 1991
* Latvia before 1991
* Lithuania before 1991
* Slovenia before 1991
* Slovakia before independence

duplicates drop country year, force
* Drops both duplicates in the data

sort country year

merge 1:1 country year using _countriesyears
keep if _merge == 3
drop _merge

gen byte Coup = .
replace Coup = 1 if (SCoup >= 1 & SCoup < .) | (ACoup >= 1 & ACoup < .)
* Generates a Coup Variable if in a year Either of SCoup or ACoup are 1 or higher
* Is . otherwise

drop SCoup ACoup

save _Coup, replace 
clear

use panel, clear
merge 1:1 country year using _Coup
drop _merge

replace Coup=0 if Coup==.

save panel, replace 
clear

cap !del _*
cap !rm _*.dta

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Inflation Data (Using Global Macro Database from 1900 to 2023)
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year
save _countriesyears, replace 

* CPI from Macro Dataset Index 2010 = 100 and 1900 to 2023
use Data/GMD, clear

rename countryname country
keep country year CPI
replace country="Russia" if country=="Russian Federation"

* Multiple CPI = 100 - Czech Republic, Estonia, Latvia, Lithuania, Luxembourg
* Currency before and after Absorbtion into other Countries
drop if country == "Czech Republic" & year <= 1950 
* Czechoslovakia
drop if country == "Estonia" & year <= 1950
drop if country == "Latvia" & year <= 1950
drop if country == "Lithuania" & year <= 1950
* USSR
drop if country == "Luxembourg" & year <= 1947
* After WW2 was reorganized

sort country year
gen logCPI = log(CPI)
gen Inf = logCPI - logCPI[_n-1] if country == country[_n-1]

rename Inf Inflation

drop logCPI CPI

save _CPI1, replace
clear


* Pre-Merge
use _countriesyears, clear

merge 1:1 country year using _CPI1
drop if _merge == 2
drop _merge

save _CPI, replace
clear


* Merging into Main
use panel, clear

merge 1:1 country year using _CPI 
drop if _merge == 2
drop _merge

save panel, replace
clear 

cap !del _*
cap !rm _*.dta

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Trade Share of GDP
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 

* Using Global Macro Database
use Data/GMD, clear

keep countryname year exports_GDP imports_GDP

rename countryname country
rename exports_GDP _EX
rename imports_GDP _IM
replace country="Russia" if country=="Russian Federation"
drop if year < 1900 | year > 2023

gen TradeShare = _EX + _IM

save _trade, replace
clear

use _countriesyears, clear

merge 1:1 country year using _trade
drop if _merge == 2
drop _merge

bys cid: ipolate TradeShare year if country=="Australia" & year >= 1913 & year <= 1915, gen(_Australia)
bys cid: ipolate TradeShare year if country=="Austria" & year >= 1937 & year <= 1948, gen(_Austria)
bys cid: ipolate TradeShare year if country=="Colombia" & year >= 1948 & year <= 1957, gen(_Colombia)
bys cid: ipolate TradeShare year if country=="Germany" & year >= 1943 & year <= 1948, gen(_Germany)
bys cid: ipolate TradeShare year if country=="Greece" & year >= 1939 & year <= 1946, gen(_Greece)
bys cid: ipolate TradeShare year if country=="Hungary" & year >= 1943 & year <= 1950, gen(_Hungary)
bys cid: ipolate TradeShare year if country=="Japan" & year >= 1943 & year <= 1946, gen(_Japan)
bys cid: ipolate TradeShare year if country=="Netherlands" & year >= 1943 & year <= 1946, gen(_Netherlands)
bys cid: ipolate TradeShare year if country=="Peru" & year >= 1952 & year <= 1957, gen(_Peru)
bys cid: ipolate TradeShare year if country=="Romania" & year >= 1914 & year <= 1920, gen(_Romania)
bys cid: ipolate TradeShare year if country=="Russia" & year >= 1940 & year <= 1945, gen(_Russia)
bys cid: ipolate TradeShare year if country=="Turkey" & year >= 1947 & year <= 1950, gen(_Turkey)
bys cid: ipolate TradeShare year if country=="Venezuela" & year >= 2014 & year <= 2018, gen(_Venezuela)

foreach c in Australia Austria {
	replace TradeShare = _`c' if country == "`c'" & _`c'!=.
}

bys cid: ipolate TradeShare year if country=="Belgium" & year >= 1913 & year <= 1919, gen(_Belgium1)
bys cid: ipolate TradeShare year if country=="Belgium" & year >= 1939 & year <= 1941, gen(_Belgium2)
bys cid: ipolate TradeShare year if country=="Belgium" & year >= 1941 & year <= 1943, gen(_Belgium3)
bys cid: ipolate TradeShare year if country=="Belgium" & year >= 1943 & year <= 1946, gen(_Belgium4)
bys cid: ipolate TradeShare year if country=="Bulgaria" & year >= 1946 & year <= 1948, gen(_Bulgaria1)
bys cid: ipolate TradeShare year if country=="Bulgaria" & year >= 1948 & year <= 1952, gen(_Bulgaria2)

replace TradeShare = _Belgium1 if country=="Belgium" & year >= 1913 & year <= 1919
replace TradeShare = _Belgium2 if country=="Belgium" & year >= 1939 & year <= 1941
replace TradeShare = _Belgium3 if country=="Belgium" & year >= 1941 & year <= 1943
replace TradeShare = _Belgium4 if country=="Belgium" & year >= 1943 & year <= 1946
replace TradeShare = _Bulgaria1 if country=="Bulgaria" & year >= 1946 & year <= 1948
replace TradeShare = _Bulgaria2 if country=="Bulgaria" & year >= 1948 & year <= 1952

drop _* 

save _TradeShare, replace
clear

use panel, clear

merge 1:1 country year using _TradeShare
drop if _merge == 2
drop _merge

save panel, replace
clear 

cap !del _*
cap !rm _*.dta

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Gini
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 
clear

* Use the SWIID data - mi
use Data\SWIID9.8_Gini.dta, clear

gen Gini = _1_gini_disp

mi unset
* Solve mi set problem

keep country year Gini

replace country="South Korea" if country == "Korea"


save _gini1, replace
clear

* Premerge with Skeleton
use _countriesyears

merge 1:1 country year using _gini1
drop if _merge == 2
drop _merge



save _gini, replace
clear

* Merge into Main
use panel, clear

merge 1:1 country year using _gini 
drop if _merge == 2
drop _merge 

save panel, replace
clear

cap !del _*
cap !rm _*.dta

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Public Debt
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 
clear

* Prepare Global Macro Database
use Data/GMD, clear 

rename countryname country
keep country year govdebt_GDP
* Government Debt as % of GDP
replace country="Russia" if country=="Russian Federation"

save _Debt1, replace
clear 

* Premerge with Skeleton
use _countriesyears, clear

merge 1:1 country year using _Debt1
drop if _merge == 2
drop _merge

rename govdebt_GDP DebtShare

bys cid: ipolate DebtShare year if country=="Austria" & year >= 1913 & year <= 1924, gen(_Austria1)
bys cid: ipolate DebtShare year if country=="Austria" & year >= 1937 & year <= 1948, gen(_Austria2)
bys cid: ipolate DebtShare year if country=="Belgium" & year >= 1913 & year <= 1920, gen(_Belgium1)
bys cid: ipolate DebtShare year if country=="Belgium" & year >= 1939 & year <= 1941, gen(_Belgium2)
bys cid: ipolate DebtShare year if country=="Belgium" & year >= 1941 & year <= 1943, gen(_Belgium3)
bys cid: ipolate DebtShare year if country=="Belgium" & year >= 1943 & year <= 1946, gen(_Belgium4)
bys cid: ipolate DebtShare year if country=="Bolivia" & year >= 1944 & year <= 1947, gen(_Bolivia)
bys cid: ipolate DebtShare year if country=="Egypt" & year >= 1945 & year <= 1954, gen(_Egypt1)
bys cid: ipolate DebtShare year if country=="Egypt" & year >= 1957 & year <= 1959, gen(_Egypt2)
bys cid: ipolate DebtShare year if country=="Egypt" & year >= 1962 & year <= 1970, gen(_Egypt3)
bys cid: ipolate DebtShare year if country=="France" & year >= 1913 & year <= 1920, gen(_France1)
bys cid: ipolate DebtShare year if country=="France" & year >= 1938 & year <= 1946, gen(_France2)
bys cid: ipolate DebtShare year if country=="Greece" & year >= 1913 & year <= 1919, gen(_Greece1)
bys cid: ipolate DebtShare year if country=="Greece" & year >= 1939 & year <= 1948, gen(_Greece2)
bys cid: ipolate DebtShare year if country=="Japan" & year >= 1944 & year <= 1946, gen(_Japan)
bys cid: ipolate DebtShare year if country=="Malaysia" & year >= 1957 & year <= 1960, gen(_Malaysia)
bys cid: ipolate DebtShare year if country=="Malta" & year >= 1978 & year <= 1980, gen(_Malta) 
bys cid: ipolate DebtShare year if country=="Netherlands" & year >= 1939 & year <= 1946, gen(_Netherlands)
bys cid: ipolate DebtShare year if country=="Norway" & year >= 1939 & year <= 1946, gen(_Norway)
bys cid: ipolate DebtShare year if country=="Peru" & year >= 1961 & year <= 1963, gen(_Peru1)
bys cid: ipolate DebtShare year if country=="Peru" & year >= 1968 & year <= 1970, gen(_Peru2)
bys cid: ipolate DebtShare year if country=="Spain" & year >= 1935 & year <= 1940, gen(_Spain)
bys cid: ipolate DebtShare year if country=="Turkey" & year >= 1915 & year <= 1925, gen(_Turkey)

ds _*
foreach var of varlist `r(varlist)' {
    replace DebtShare = `var' if !missing(`var')
}

drop _*

save _Debt, replace
clear

* Merge into Main
use panel, clear

merge 1:1 country year using _Debt
drop if _merge == 2
drop _merge 

save panel, replace
clear

cap !del _*
cap !rm _*.dta

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Labor Share of GDP
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 
clear

* Prepare PennWorldTable
use Data/PennWorldTable1001, clear

keep country year labsh
rename labsh LaborShare

replace country = "Bolivia" if country == "Bolivia (Plurinational State of)"
replace country = "South Korea" if country == "Republic of Korea"
replace country = "Russia" if country == "Russian Federation"
replace country = "Venezuela" if country == "Venezuela (Bolivarian Republic of)"

save _LaborShare1, replace
clear

* Premerge with Skeleton
use _countriesyears, clear

merge 1:1 country year using _LaborShare1
drop if _merge == 2
drop _merge

save _LaborShare, replace
clear

* Including into Main
use panel, clear

merge 1:1 country year using _LaborShare 
drop if _merge == 2
drop _merge

save panel, replace
clear


cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Tariff Index (Import Tariffs)
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 
clear

* Prepare TariffData from the FOHR Paper (1960 to 2013)
use Data/Tariffs_MacroDataset, clear

replace country="South Korea" if country=="Korea"
replace country="Slovakia" if country=="Slovak Republic"
replace country="Taiwan" if country=="Taiwan Province of China"
replace country="Venezuela" if country=="Venezuela, RB"

* No data for Switzerland

drop if tariff==.

rename tariff FOHR_TariffRate

save _Tariffs1, replace
clear

* Prepare WDI TariffData (2013 ro 2023)
import excel using Data/WB_WDI_Tariff.xlsx, firstrow clear

keep CountryName YR*
drop if CountryName==""
reshape long YR, i(CountryName) j(year)

* Taiwan Turkey Venezuela

rename CountryName country 
rename YR WDI_TariffRate

replace WDI_TariffRate = "" if trim(WDI_TariffRate) == ".." | trim(WDI_TariffRate) == "n/a" | trim(WDI_TariffRate) == "--"
destring WDI_TariffRate, replace force


replace country="Czech Republic" if country=="Czechia"
replace country="Egypt" if country=="Egypt, Arab Rep."
replace country="South Korea" if country=="Korea, Rep."
replace country="Russia" if country=="Russian Federation"
replace country="Slovakia" if country=="Slovak Republic"
replace country="Turkey" if country=="Turkiye"
replace country="Venezuela" if country=="Venezuela, RB"

save _Tariffs2, replace
clear


* Pre-Merge and Interpolate
use _countriesyears, clear

merge 1:1 country year using _Tariffs1
drop if _merge == 2
drop _merge

merge 1:1 country year using _Tariffs2
drop if _merge == 2
drop _merge

bys cid: ipolate FOHR_TariffRate year, gen(FOHR_TariffRate_ipo)
replace FOHR_TariffRate_ipo = . if FOHR_TariffRate!=.
replace FOHR_TariffRate = FOHR_TariffRate_ipo if FOHR_TariffRate==.

bys cid: ipolate WDI_TariffRate year, gen(WDI_TariffRate_ipo)
replace WDI_TariffRate_ipo = . if WDI_TariffRate!=.
replace WDI_TariffRate = WDI_TariffRate_ipo if WDI_TariffRate==.

bys cid: gen byte base = 1 if year==2013  
bys cid (base): gen WDI_TariffRate_i  = (WDI_TariffRate / WDI_TariffRate[1]) if year>=2013
bys cid (base): gen FOHR_TariffRate_ext= WDI_TariffRate_i * FOHR_TariffRate[1] if year>=2013 
bys cid: replace FOHR_TariffRate_ext = FOHR_TariffRate if year<=2013 
drop base WDI_TariffRate_i
* New Index to 2013 to match with the FOHR data

replace FOHR_TariffRate_ext = FOHR_TariffRate if country=="Taiwan"
replace FOHR_TariffRate_ext = WDI_TariffRate if country=="Switzerland"
* Manual clean up for better matching

bys cid: gen byte base = 1 if year==1993 & country=="Croatia"  
bys cid (base): gen WDI_TariffRate_i  = (WDI_TariffRate / WDI_TariffRate[1]) if year<=1993 & country=="Croatia"
bys cid (base): gen FOHR_TariffRate_exthrv= WDI_TariffRate_i * FOHR_TariffRate_ext[1] if year<=1993 & country=="Croatia" 
bys cid: replace FOHR_TariffRate_ext = FOHR_TariffRate_exthrv  if year<=1993 & country=="Croatia" 
* Manual clean up for better matching

rename FOHR_TariffRate_ext Tariffs

drop FOHR_* WDI_* base

save _Tariffs, replace
clear


* Merge into Main
use panel, clear

merge 1:1 country year using "_Tariffs"
drop if _merge == 2
drop _merge

save panel, replace
clear

cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Financial Openness Index (From the KOF Globalisation Index Set)
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 
clear

* Prepare Openness Data
use Data/KOF_Globalization2024.dta, clear

keep country year KOFFiGI

replace country="Egypt" if country=="Egypt, Arab Rep"
replace country="Korea" if country=="Korea, Rep"
replace country="Russia" if country=="Russian Federation"
replace country="Slovakia" if country=="Slovak Republic"
replace country="Venezuela" if country=="Venezuela, RB"

rename KOFFiGI FinOpen

save _FinOpen1, replace
clear

* Premerge with Skeleton
use _countriesyears, clear

merge 1:1 country year using _FinOpen1
drop if _merge == 2
drop _merge

save _FinOpen, replace
clear

* Including into Main
use panel, clear

merge 1:1 country year using _FinOpen 
drop if _merge == 2
drop _merge

save panel, replace
clear


cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Trade Openness Index (From the KOF Globalisation Index Set)
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 
clear


* Prepare Openness Data
use Data/KOF_Globalization2024.dta, clear

keep country year KOFTrGI

replace country="Egypt" if country=="Egypt, Arab Rep"
replace country="Korea" if country=="Korea, Rep"
replace country="Russia" if country=="Russian Federation"
replace country="Slovakia" if country=="Slovak Republic"
replace country="Venezuela" if country=="Venezuela, RB"

rename KOFTrGI TradeOpen

save _TradeOpen1, replace
clear

* Premerge with Skeleton
use _countriesyears, clear

merge 1:1 country year using _TradeOpen1
drop if _merge == 2
drop _merge

save _TradeOpen, replace
clear

* Including into Main
use panel, clear

merge 1:1 country year using _TradeOpen 
drop if _merge == 2
drop _merge

save panel, replace
clear


cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Social Conflicts (Copied data from replication package since not publicly available)
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid Coup
save _countriesyears, replace 
clear

* Prepare data
import excel using "Data/2021 Edition CNTSDATA.xlsx", firstrow cellrange(A2:E17918) clear 
replace country="Slovakia" if country=="Slovak Republic"
replace country="Russia" if country=="Russian Federation"
replace country = "Russia" if country=="USSR (Russia)"  
replace country="South Korea" if country=="Korea, South"
replace country="China" if country=="China PR"
replace country="China" if country=="China Republic"
replace country="Austria" if country=="Austria-Hungary"
replace country="Austria" if country=="Austrian Empire"
replace country="Germany" if country=="German FR"
replace country="Czech Republic" if country=="Czechoslovakia"
save _conflict1, replace


* Temporary CountryNameYear Dataset
use _countriesyears, clear

merge 1:1 country year using _conflict1
drop if _merge == 2
drop _merge

sort country year
foreach p in domestic2 domestic6 domestic8 Coup{
forvalues i=1/8{
replace `p' = `p'[_n+`i'] if country=="Slovakia" & (year== 1993-`i')
}
}

gen Conflicts = domestic2 + domestic6 + domestic8 + Coup

drop domestic* Coup

save _conflict, replace
clear

* Merge with main
use panel, clear

merge 1:1 country year using _conflict
drop if _merge==2
drop _merge

replace Conflicts=0 if Conflicts==.

save panel, replace
clear


cap !del _*
cap !rm _*.dta

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Unemployment
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary CountryNameYear Dataset
use panel, clear
keep country year cid
save _countriesyears, replace 
clear

* Prepare Unemployment Data
use Data/GMD, replace 

rename countryname country
keep country year unemp
replace country="Russia" if country=="Russian Federation"

rename unemp UnemploymentRate

save _GMDemploy, replace
clear

* Pre-Merge 
use _countriesyears, clear

merge 1:1 country year using _GMDemploy
drop if _merge == 2
drop _merge

save _Employ, replace
clear

* Merge with main data
use panel, clear

merge 1:1 country year using _Employ
drop if _merge == 2
drop _merge

save panel, replace
clear

cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including World Wars (Copied from ReplicationPackage)
******************************************************************************************
******************************************************************************************
******************************************************************************************

use panel, clear

gen WorldWar = 0
replace WorldWar = 1 if year>=1914 & year<=1918
replace WorldWar = 1 if year>=1939 & year<=1945

save panel, replace 
clear


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Independence Years for Countries gaining Independence (Copied from ReplicationPackage)
******************************************************************************************
******************************************************************************************
******************************************************************************************

use panel, clear

gen independent = 1 if year >= 1900
replace independent = 0 if iso=="AUS" & year<=1900 & independent==1
replace independent = 0 if iso=="AUT" & year<=1917 & independent==1
replace independent = 0 if iso=="CYP" & year<=1959 & independent==1
replace independent = 0 if iso=="CZE" & year<=1917 & independent==1
replace independent = 0 if iso=="DEU" & (year>=1946 & year<=1948) & independent==1
replace independent = 0 if iso=="EGY" & year<=1921 & independent==1
replace independent = 0 if iso=="EST" & (year<=1917 | (year>=1941 & year<=1990)) & independent==1
replace independent = 0 if iso=="FIN" & year<=1916 & independent==1
replace independent = 0 if iso=="HRV" & year<=1991 & independent==1
replace independent = 0 if iso=="HUN" & year<=1917 & independent==1
replace independent = 0 if iso=="IDN" & year<=1944 & independent==1
replace independent = 0 if iso=="IND" & year<=1946 & independent==1
replace independent = 0 if iso=="IRL" & year<=1920 & independent==1
replace independent = 0 if iso=="ISL" & year<=1943 & independent==1
replace independent = 0 if iso=="ISR" & year<=1947 & independent==1
replace independent = 0 if iso=="KOR" & year<=1947 & independent==1
replace independent = 0 if iso=="LTU" & (year<=1917 | (year>=1941 & year<=1990)) & independent==1
replace independent = 0 if iso=="LVA" & (year<=1917 | (year>=1941 & year<=1990)) & independent==1
replace independent = 0 if iso=="MLT" & year<=1963 & independent==1
replace independent = 0 if iso=="MYS" & year<=1956 & independent==1
replace independent = 0 if iso=="NOR" & year<=1904 & independent==1
replace independent = 0 if iso=="NZL" & year<=1906 & independent==1
replace independent = 0 if iso=="PHL" & year<=1945 & independent==1
replace independent = 0 if iso=="POL" & year<=1917 & independent==1
replace independent = 0 if iso=="SVK" & year<=1992 & independent==1
replace independent = 0 if iso=="SVN" & year<=1991 & independent==1
replace independent = 0 if iso=="TWN" & year<=1948 & independent==1
replace independent = 0 if iso=="ZAF" & year<=1909 & independent==1

save panel, replace
clear

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Advanced Economies Flag (Copied from ReplicationPackage) (Brauch ich das?)
******************************************************************************************
******************************************************************************************
******************************************************************************************

use panel, clear

gen advanced = 0
replace advanced = 1 if country=="Australia"
replace advanced = 1 if country=="Austria"
replace advanced = 1 if country=="Belgium"
replace advanced = 1 if country=="Canada"
replace advanced = 1 if country=="Cyprus"
replace advanced = 1 if country=="Czech Republic"
replace advanced = 1 if country=="Denmark"
replace advanced = 1 if country=="Estonia"
replace advanced = 1 if country=="Finland"
replace advanced = 1 if country=="France"
replace advanced = 1 if country=="Germany"
replace advanced = 1 if country=="Greece"
replace advanced = 1 if country=="Ireland"
replace advanced = 1 if country=="Israel"
replace advanced = 1 if country=="Italy"
replace advanced = 1 if country=="Japan"
replace advanced = 1 if country=="South Korea"
replace advanced = 1 if country=="Latvia"
replace advanced = 1 if country=="Lithuania"
replace advanced = 1 if country=="Luxembourg"
replace advanced = 1 if country=="Malta"
replace advanced = 1 if country=="Netherlands"
replace advanced = 1 if country=="New Zealand"
replace advanced = 1 if country=="Norway"	
replace advanced = 1 if country=="Portugal"
replace advanced = 1 if country=="Slovakia"
replace advanced = 1 if country=="Slovenia"
replace advanced = 1 if country=="Spain"
replace advanced = 1 if country=="Sweden"
replace advanced = 1 if country=="Switzerland"
replace advanced = 1 if country=="Taiwan"
replace advanced = 1 if country=="United Kingdom"
replace advanced = 1 if country=="United States"

save panel, replace 
clear


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Populists 
******************************************************************************************
******************************************************************************************
******************************************************************************************

use panel, clear

merge 1:1 country year using Populist_Data
drop if _merge == 2
drop _merge

save panel, replace
clear

******************************************************************************************
******************************************************************************************
******************************************************************************************
****Polishing (Cpoied and Altered from ReplicationPackage)
******************************************************************************************
******************************************************************************************
******************************************************************************************

use panel, clear

order country iso year cid realGDP realGDPpc Institution_Index Dem_Index CleanElections Judicial FreeMedia Inflation Gini TradeShare DebtShare LaborShare UnemploymentRate FinOpen TradeOpen Tariffs FinCrisis BankCrisis CurrencyCrisis DebtCrisis Coup Conflicts WorldWar independent advanced 
*placebo

* Actual Variables
label var country "Country"
label var iso  "ISO 3-letter code"
label var year  "Year"
label var cid  "Country ID"
label var realGDPpc  "Real GDP per capita (index, 2005=100)"
label var CleanElections  "Clean elections index"
label var Judicial  "Judicial constraints on the executive index"
label var FreeMedia  "Alternative sources of information index"
label var Institution_Index "1st Principal Component Score (Electoral, judicial, medial, and Polity score)"
label var BankCrisis  "Banking crisis onset (0-1 dummy)"
label var CurrencyCrisis  "Currency crisis onset (0-1 dummy)"
label var DebtCrisis  "Sovereign debt crisis onset (0-1 dummy)"
label var FinCrisis "Either onset of Currency, Sovereign Debt, or Banking Crisis (0-1 dummy)"
label var Inflation  "Inflation rate" 
label var TradeShare  "Trade/GDP (IM/GDP + EX/GDP)"
label var Gini  "Gini Index"
label var DebtShare  "Government Debt/GDP"
label var LaborShare  "Share of labour compensation in GDP"
label var Tariffs  "Import tariff rate (in %)"
label var FinOpen  "KOF Financial Globalisation Index"
label var TradeOpen  "KOF Trade Globalisation Index"
label var Coup "Successfull/Tried Coup d'Etat (0-1 dummy)"
label var Conflicts  "Number of successfull/tried Coup d'Etats, riots, strikes and demonstrations per year"
label var UnemploymentRate  "Unemployment, total (% of total labor force)"

* Environment Variables
label var WorldWar "World war ongoing (0-1 dummy)"
label var independent "Independent state (0-1 dummy)"
label var advanced "Advanced economy (0-1 dummy)"

* Placebo
label var placebo "Non-populist government takeover (0-1 dummy)"

	
format %15s country

save Master_Data.dta, replace

cap !del Populist_Data.dta
cap !rm Populist_Data.dta
cap !del panel.dta
cap !rm panel.dta

clear

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************