******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Create Populist Dataset with following Variables
******************************************************************************************
******************************************************************************************
******************************************************************************************

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

* Account for different political leanings coming together and how to assign them in the combined leader spells!

* Correa 2007 is left wing
* Chavez/Maduro 1999 is left wing
* Garcia 2006 is right and Humala 2011 is left -> maybe split?
* Estrada 1998 is left and Arroyo 2001 is right -> maybe split?
* Duarte 2003 is right and Lugo 2008 is left -> maybe split?
* Carter 1977 is left and Reagan 1981 is right -> maybe split?
* Caldera 1994 is right and Chavez  1999 is left -> maybe split?

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

gen Continent=""
replace Continent="South America"  in 1 
replace Continent="Ozeania"        in 2 
replace Continent="Europe"         in 3
replace Continent="Europe"         in 4 
replace Continent="South America"  in 5 
replace Continent="South America"  in 6 
replace Continent="Europe"         in 7 
replace Continent="North America"  in 8 
replace Continent="South America"  in 9 
replace Continent="Asia"           in 10 
replace Continent="South America"  in 11
replace Continent="Europe"         in 12
replace Continent="Europe"     	   in 13
replace Continent="Europe"         in 14
replace Continent="Europe"         in 15
replace Continent="South America"  in 16
replace Continent="Africa"         in 17
replace Continent="Europe"         in 18
replace Continent="Europe"         in 19
replace Continent="Europe"         in 20
replace Continent="Europe"         in 21 
replace Continent="Europe"         in 22
replace Continent="Europe"         in 23
replace Continent="Europe"         in 24
replace Continent="Asia"           in 25
replace Continent="Asia"           in 26
replace Continent="Europe"         in 27
replace Continent="Asia"           in 28
replace Continent="Europe"         in 29
replace Continent="Asia"           in 30
replace Continent="Europe"         in 31 
replace Continent="Europe"         in 32
replace Continent="Europe"         in 33 
replace Continent="Asia"           in 34 
replace Continent="Europe"         in 35 
replace Continent="North America"  in 36
replace Continent="Europe"         in 37 
replace Continent="Ozeania"        in 38 
replace Continent="Europe"         in 39 
replace Continent="South America"  in 40 
replace Continent="South America"  in 41
replace Continent="Ozeania"        in 42
replace Continent="Europe"         in 43
replace Continent="Europe"         in 44
replace Continent="Europe"         in 45
replace Continent="Europe"         in 46
replace Continent="Europe"         in 47
replace Continent="Europe"         in 48
replace Continent="Africa"         in 49 
replace Continent="Asia"           in 50
replace Continent="Europe"         in 51
replace Continent="Europe"         in 52
replace Continent="Europe"         in 53
replace Continent="Asia"           in 54
replace Continent="Asia"           in 55
replace Continent="Europe"         in 56
replace Continent="Europe"         in 57
replace Continent="North America"  in 58
replace Continent="South America"  in 59
replace Continent="South America"  in 60

expand 124
* Expands for each country by 154 cells
bysort country: gen year = 1900 + [_n-1]
egen cid = group(country)
xtset cid year
* Sorts each country and assigns years to each country from 1900 to 2024


save Code_Populist, replace
clear
* Saves skeleton as "Code_Populist"


******************************************************************************************
******************************************************************************************
******************************************************************************************
**** All Populists Rule
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Prepare Dataset
import excel using Data/PopulistData.xlsx, firstrow clear

drop if ID==.

rename (Country YearTakingPower YearLoosingPower) (country year _PopLose)
keep country year _PopLose LeftRight Leaders

duplicates drop country year, force
* Chile in 1925 war Turmoil

replace country="Philippines" if country=="Philippin"
replace country="New Zealand" if country=="New Zeeland"
replace country="United Kingdom" if country=="UK"
replace country="United States" if country=="USA"
* Fehler in meiner Excel die sich nicht aktualisiert lol

save _all_pop, replace
clear

* Prepare Dataset
import excel using Data/PopulistData.xlsx, firstrow clear

drop if ID==.
rename (Country YearTakingPower YearLoosingPower) (country year _PopLose)

replace country="Philippines" if country=="Philippin"
replace country="New Zealand" if country=="New Zeeland"
replace country="United Kingdom" if country=="UK"
replace country="United States" if country=="USA"

drop Classification R

duplicates drop country year, force

******************************************************************************************
******************************************************************************************
* Generating Populist Classes for Samples

replace Populist="." if Populist=="No"
replace HA2019="." if HA2019=="N.A." | HA2019=="No" | HA2019==""
replace HA2019="Yes" if HA2019=="Very"
replace KM2020="." if KM2020=="N.A." | KM2020=="No"
replace MS2021="." if MS2021=="N.A." | MS2021=="No"
replace ED2019="." if ED2019=="N.A." | ED2019=="No"

gen str10 PopClass = "."
replace PopClass="Borderline" if Populist=="Borderline" | Populist=="Yes" | HA2019=="Yes" | HA2019=="Weakly"  | KM2020=="Yes" | MS2021=="Yes" | ED2019=="Yes"
replace PopClass="Core" if Populist=="Yes" & (HA2019=="Yes" | KM2020=="Yes" | MS2021=="Yes" | ED2019=="Yes")
replace PopClass="Extended" if year<=1945 
* Put into Classes based on Consensus and Year of Taking Power

replace PopClass = "Borderline" if country=="Italy" & Leaders=="Meloni"

keep country year PopClass

save _ClassPop, replace
clear

******************************************************************************************
******************************************************************************************
*Merge Into Main

use Code_Populist, clear

merge 1:1 country year using "_all_pop"
drop if _merge == 2
drop _merge

* Including nearly consequitive terms
replace _PopLose=1926 if country=="Chile" & _PopLose==1925
replace _PopLose=2006 if country=="Ecuador" & _PopLose==2005
replace _PopLose=2007 if country=="Italy" & _PopLose==2006
replace _PopLose=2011 if country=="Slovakia" & _PopLose==2010

merge 1:1 country year using "_ClassPop"
drop if _merge == 2
drop _merge

save Code_Populist, replace
clear

cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
* Populist in Power for each year

use Code_Populist, clear

gen _PopStart = .
gen _PopEnd = .

replace _PopEnd = _PopLose if _PopLose < .
* When PopLose is not missing, that's the end of a populist rule
replace _PopStart = year if _PopLose < .
* The year that observation represents is the start of rule

bysort country (year): gen AllPop = .
gen _start = .
gen _stop = .

bysort country (year): replace _start = year if _PopStart < .
bysort country (year): replace _stop  = _PopEnd  if _PopEnd  < .
* Assign start and end markers

bysort country (year): replace _start = _start[_n-1] if missing(_start)
* Carry forward the most recent start year

bysort country (year): replace _stop = _stop[_n-1] if missing(_stop)
* Carry forward the most recent end year

replace AllPop = 1 if _start <= year & year <= _stop
* Flag years between start and stop (inclusive)

drop _*

******************************************************************************************
******************************************************************************************
* Political leaning and sample for each year

bysort country (year): replace PopClass = PopClass[_n-1] if AllPop == 1 & missing(PopClass) & AllPop[_n-1] == 1
bysort country (year): replace LeftRight = LeftRight[_n-1] if AllPop == 1 & missing(LeftRight) & AllPop[_n-1] == 1


gen LeftPop = .
replace LeftPop = 1 if (AllPop == 1 & LeftRight == "Left")

gen RightPop = .
replace RightPop = 1 if (AllPop == 1 & LeftRight == "Right")
* Generiert variablen für Left/Right Populists mit Takeover identifyer.

save Code_Populist, replace
clear

cap !del _*
cap !rm _*.dta

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Populist Class Variables
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Code_Populist, clear

******************************************************************************************
******************************************************************************************
* Core Populist Sample (Only Consensus after 1945)
gen CorePop = .
replace CorePop = 1 if AllPop==1 & PopClass=="Core"

gen LeftCorePop = .
replace LeftCorePop = 1 if CorePop==1 & LeftPop==1

gen RightCorePop = .
replace RightCorePop = 1 if CorePop==1 & RightPop==1

******************************************************************************************
******************************************************************************************
* Borderline Populist Sample (Only one Agree after 1945)
gen BorderPop = .
replace BorderPop = 1 if AllPop==1 & (PopClass=="Borderline" | PopClass=="Core")

gen LeftBorderPop = .
replace LeftBorderPop = 1 if BorderPop==1 & LeftPop==1

gen RightBorderPop = .
replace RightBorderPop = 1 if BorderPop==1 & RightPop==1


******************************************************************************************
******************************************************************************************
* Extended Populist Sample (All)
rename (AllPop LeftPop RightPop) (ExtPop LeftExtPop RightExtPop)

save Code_Populist, replace
clear

******************************************************************************************
******************************************************************************************
* Unique Populist Takeovers

use Code_Populist, clear

******************************************************************************************

bysort country (year): generate _episode = sum(CorePop == 1 & (CorePop[_n-1] == . | _n == 1))

* Core Populist Sample (Only Consensus after 1945)
gen CoreTake = .
bysort country _episode (year): replace CoreTake = 1 if CorePop == 1 & (_n == 1)
replace CoreTake=1 if iso=="ARG" & year==2003


gen LeftCoreTake = .
replace LeftCoreTake = 1 if CoreTake==1 & LeftCorePop==1

gen RightCoreTake = .
replace RightCoreTake = 1 if CoreTake==1 & RightCorePop==1

drop _episode

******************************************************************************************

bysort country (year): generate _episode = sum(BorderPop == 1 & (BorderPop[_n-1] == . | _n == 1))

* Borderline Populist Sample (Only one Agree after 1945)
gen BorderTake = .
bysort country _episode (year): replace BorderTake = 1 if BorderPop == 1 & (_n == 1)
bysort country _episode (year): replace BorderTake = 1 if CorePop == 1 & (_n == 1)


gen LeftBorderTake = .
replace LeftBorderTake = 1 if BorderTake==1 & LeftBorderPop==1

gen RightBorderTake = .
replace RightBorderTake = 1 if BorderTake==1 & RightBorderPop==1

drop _episode

******************************************************************************************

bysort country (year): generate _episode = sum(ExtPop == 1 & (ExtPop[_n-1] == . | _n == 1))

* Extended Populist Sample (All)
gen ExtTake = .
bysort country _episode (year): replace ExtTake = 1 if ExtPop == 1 & (_n == 1)
bysort country _episode (year): replace ExtTake = 1 if BorderPop == 1 & (_n == 1)
bysort country _episode (year): replace ExtTake = 1 if CorePop == 1 & (_n == 1)


gen LeftExtTake = .
replace LeftExtTake = 1 if ExtTake==1 & LeftExtPop==1

gen RightExtTake = .
replace RightExtTake = 1 if ExtTake==1 & RightExtPop==1

drop _*

save Code_Populist, replace
clear

******************************************************************************************
******************************************************************************************
******************************************************************************************
**** Including Placebo (Copied directly from ReplicationPackage) - Brauch ich das überhaupt?
******************************************************************************************
******************************************************************************************
******************************************************************************************

* Temporary Country Set
use Code_Populist, clear 
keep if year == 2000
keep iso country
save _countries, replace

******************************************************************************************
******************************************************************************************
use data/Archigos_4.1.dta, clear

split startdate, p("-")
drop startdate2 startdate3
destring startdate1, replace
* Take only start year (drop month and day) and destring
split enddate, p("-")
drop enddate2 enddate3
destring enddate1, replace
* Take only end year
keep idacr startdate* leader obsid enddate*
* Take iso (idacr), start and end years, leader name, and iso-year-counter (obsid)
rename idacr iso
rename startdate1 startyear
rename enddate1 endyear

drop if iso=="CZE" | iso=="KOR"
replace iso = "AUS1" if iso=="AUL"
* From AUL to AUS1
replace iso = "AUT" if iso=="AUS"
* From AUS to AUT
replace iso = "AUS" if iso=="AUS1"
* From AUS1 to AUS
replace iso = "BGR" if iso=="BUL"
replace iso = "HRV" if iso=="CRO"
replace iso = "CZE" if iso=="CZR"
replace iso = "DNK" if iso=="DEN"
replace iso = "FRA" if iso=="FRN"
replace iso = "DEU" if iso=="GMY"
replace iso = "DEU" if iso=="GFR"
replace iso = "IDN" if iso=="INS"
replace iso = "IRL" if iso=="IRE"
replace iso = "ISL" if iso=="ICE"
replace iso = "LVA" if iso=="LAT"
replace iso = "LTU" if iso=="LIT"
replace iso = "MYS" if iso=="MAL"
replace iso = "NLD" if iso=="NTH"
replace iso = "NZL" if iso=="NEW"
replace iso = "PRY" if iso=="PAR"
replace iso = "PHL" if iso=="PHI"
replace iso = "PRT" if iso=="POR"
replace iso = "ROU" if iso=="RUM"
replace iso = "SVK" if iso=="SLO"
replace iso = "SVN" if iso=="SLV"
replace iso = "ZAF" if iso=="SAF"
replace iso = "KOR" if iso=="ROK"
replace iso = "ESP" if iso=="SPN"
replace iso = "SWE" if iso=="SWD"
replace iso = "CHE" if iso=="SWZ"
replace iso = "TWN" if iso=="TAW"
replace iso = "THA" if iso=="THI"
replace iso = "GBR" if iso=="UKG"
replace iso = "URY" if iso=="URU"
* Angleichen an eigene iso

save _archtemp, replace


******************************************************************************************
******************************************************************************************
use _archtemp, clear
merge m:1 iso using _countries
drop if _merge==1
drop _merge country
* Similar to mergin _archtemp into _countriesyears 

drop if iso=="CHE"
sort iso startyear endyear
replace endyear = 2018 if iso=="ARG" & startyear==2015 & endyear==2015
replace endyear = 2018 if iso=="BEL" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="BOL" & startyear==2006 & endyear==2015 
replace endyear = 2018 if iso=="CAN" & startyear==2015 & endyear==2015
replace endyear = 2018 if iso=="CHL" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="CHN" & startyear==2012 & endyear==2015
replace endyear = 2018 if iso=="COL" & startyear==2010 & endyear==2015
replace endyear = 2018 if iso=="CYP" & startyear==2013 & endyear==2015
replace endyear = 2018 if iso=="DEU" & startyear==2005 & endyear==2015
replace endyear = 2018 if iso=="DNK" & startyear==2015 & endyear==2015 
replace endyear = 2018 if iso=="EGY" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="FIN" & startyear==2012 & endyear==2015 
replace endyear = 2018 if iso=="GRC" & startyear==2015 & endyear==2015
replace endyear = 2018 if iso=="HRV" & startyear==2015 & endyear==2015
replace endyear = 2018 if iso=="HUN" & startyear==2010 & endyear==2015
replace endyear = 2018 if iso=="IDN" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="IND" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="ISR" & startyear==2009 & endyear==2015
replace endyear = 2018 if iso=="JPN" & startyear==2012 & endyear==2015
replace endyear = 2018 if iso=="LTU" & startyear==2009 & endyear==2015
replace endyear = 2018 if iso=="LUX" & startyear==2013 & endyear==2015
replace endyear = 2018 if iso=="MEX" & startyear==2012 & endyear==2015
replace endyear = 2018 if iso=="MLT" & startyear==2013 & endyear==2015
replace endyear = 2018 if iso=="MYS" & startyear==2009 & endyear==2015
replace endyear = 2018 if iso=="NLD" & startyear==2010 & endyear==2015
replace endyear = 2018 if iso=="NOR" & startyear==2013 & endyear==2015
replace endyear = 2018 if iso=="PRY" & startyear==2013 & endyear==2015
replace endyear = 2018 if iso=="RUS" & startyear==2000 & endyear==2015
replace endyear = 2018 if iso=="SVK" & startyear==2012 & endyear==2015
replace endyear = 2018 if iso=="SVN" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="SWE" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="THA" & startyear==2014 & endyear==2015
replace endyear = 2018 if iso=="TUR" & startyear==2003 & endyear==2015
replace endyear = 2018 if iso=="URY" & startyear==2015 & endyear==2015
replace endyear = 2018 if iso=="VEN" & startyear==2012 & endyear==2015
replace endyear = 2018 if iso=="AUS" & startyear==2015 & endyear==2015
replace endyear = 2016 if iso=="AUT" & startyear==2008 & endyear==2015
replace endyear = 2017 if iso=="BGR" & startyear==2014 & endyear==2015
replace endyear = 2016 if iso=="BRA" & startyear==2011 & endyear==2015
replace endyear = 2017 if iso=="CZE" & startyear==2014 & endyear==2015
replace endyear = 2017 if iso=="ECU" & startyear==2007 & endyear==2015
replace endyear = 2018 if iso=="ESP" & startyear==2011 & endyear==2015
replace endyear = 2016 if iso=="EST" & startyear==2014 & endyear==2015
replace endyear = 2017 if iso=="FRA" & startyear==2012 & endyear==2015
replace endyear = 2016 if iso=="GBR" & startyear==2010 & endyear==2015
replace endyear = 2017 if iso=="IRL" & startyear==2011 & endyear==2015
replace endyear = 2016 if iso=="ISL" & startyear==2013 & endyear==2015
replace endyear = 2016 if iso=="ITA" & startyear==2014 & endyear==2015
replace endyear = 2017 if iso=="KOR" & startyear==2013 & endyear==2015
replace endyear = 2016 if iso=="NZL" & startyear==2008 & endyear==2015
replace endyear = 2016 if iso=="PER" & startyear==2011 & endyear==2015
replace endyear = 2016 if iso=="PHL" & startyear==2010 & endyear==2015
replace endyear = 2016 if iso=="PRT" & startyear==2006 & endyear==2015
replace endyear = 2016 if iso=="TWN" & startyear==2008 & endyear==2015
replace endyear = 2017 if iso=="USA" & startyear==2009 & endyear==2015
replace endyear = 2018 if iso=="ZAF" & startyear==2009 & endyear==2015
replace endyear = 2016 if iso=="LVA" & startyear==2014 & endyear==2014
* Expand Archigos_4 beyond 2015

expand 2 if iso=="AUS"  & iso!=iso[_n+1]
replace leader="Scott Morrison" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="BRA"  & iso!=iso[_n+1]
replace leader="Temer" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="COL"  & iso!=iso[_n+1]
replace leader="Duque Marquez" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="CZE"  & iso!=iso[_n+1]
replace leader="Babis" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""

expand 2 if iso=="ECU"  & iso!=iso[_n+1]
replace leader="Lenin Moreno" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""

expand 2 if iso=="ESP"  & iso!=iso[_n+1]
replace leader="Pedro Sanchez" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="EST"  & iso!=iso[_n+1]
replace leader="Ratas" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="FRA"  & iso!=iso[_n+1]
replace leader="Macron" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""

expand 2 if iso=="GBR"  & iso!=iso[_n+1]
replace leader="May" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="IRL"  & iso!=iso[_n+1]
replace leader="Varadkar" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""

expand 2 if iso=="KOR"  & iso!=iso[_n+1]
replace leader="Moon Jae-in" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""

expand 2 if iso=="LVA"  & iso!=iso[_n+1]
replace leader="Kucinskis" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="MEX"  & iso!=iso[_n+1]
replace leader="Lopez Obrador" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="MYS"  & iso!=iso[_n+1]
replace leader="Mahatir Mohamad" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="PRT"  & iso!=iso[_n+1]
replace leader="Rebelo de Sousa" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="PRY"  & iso!=iso[_n+1]
replace leader="Mario Abdo Benitez" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="ROU"  & iso!=iso[_n+1]
replace leader="Klaus Iohannis" if iso[_n+1]==""
replace startyear=2014 if iso[_n+1]==""

expand 2 if iso=="SVN"  & iso!=iso[_n+1]
replace leader="Sarec" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="TWN"  & iso!=iso[_n+1]
replace leader="Tsai Ing-wen" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="USA"  & iso!=iso[_n+1]
replace leader="Trump" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""

expand 2 if iso=="ZAF"  & iso!=iso[_n+1]
replace leader="Ramaphosa" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="ITA"  & iso!=iso[_n+1]
replace leader="Gentiloni" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="PER"  & iso!=iso[_n+1]
replace leader="Pedro Kuczynski" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""

expand 2 if iso=="SVK"  & iso!=iso[_n+1]
replace leader="Pellegrini" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

replace endyear = 2018 in 1919/1942

sort iso startyear endyear 
expand 2 if iso=="AUT"  & iso!=iso[_n+1]
replace leader="Kern" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""
replace endyear=2017 if iso[_n+1]==""

expand 2 if iso=="BGR"  & iso!=iso[_n+1]
replace leader="Gerdschikow" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""
replace endyear=2017 if iso[_n+1]==""

expand 2 if iso=="ISL"  & iso!=iso[_n+1]
replace leader="Johannsson" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""
replace endyear=2017 if iso[_n+1]==""

expand 2 if iso=="NZL"  & iso!=iso[_n+1]
replace leader="Bill English" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""
replace endyear=2017 if iso[_n+1]==""

expand 2 if iso=="PHL"  & iso!=iso[_n+1]
replace leader="Duterte" if iso[_n+1]==""
replace startyear=2016 if iso[_n+1]==""
replace endyear=2018 if iso[_n+1]==""

sort iso startyear endyear 
expand 2 if iso=="ITA"  & iso!=iso[_n+1]
replace leader="Salvini/Di Maio" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="PER"  & iso!=iso[_n+1]
replace leader="Vizcarra Cornejo" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="AUT"  & iso!=iso[_n+1]
replace leader="Kurz" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""
replace endyear=2018 if iso[_n+1]==""

expand 2 if iso=="BGR"  & iso!=iso[_n+1]
replace leader="Boyko Borisov" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""
replace endyear=2018 if iso[_n+1]==""

expand 2 if iso=="CHL"  & iso!=iso[_n+1]
replace leader="Sebastian Pinera" if iso[_n+1]==""
replace startyear=2018 if iso[_n+1]==""

expand 2 if iso=="ISL"  & iso!=iso[_n+1]
replace leader="Benediktsson II" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""

expand 2 if iso=="NZL"  & iso!=iso[_n+1]
replace leader="Jacinda Ardern" if iso[_n+1]==""
replace startyear=2017 if iso[_n+1]==""
replace endyear=2018 if iso[_n+1]==""

sort iso startyear endyear
expand 2 if iso=="ISL"  & iso!=iso[_n+1]
replace leader="Jakobsdottir" if iso[_n+1]==""
replace endyear=2018 if iso[_n+1]==""

replace endyear = 2013 if iso=="VEN" & leader=="Hugo Chavez"
replace startyear = 2013 if iso=="VEN" & leader=="Maduro" 
replace startyear = 1992 if iso=="SVK" & startyear==1993 & leader=="Meciar" 
 
expand 2 if iso=="SVK" & startyear==1992 & leader=="Meciar" 
replace startyear=1990 if iso=="SVK" & startyear==1992 & iso!=iso[_n+1] 
replace endyear=1991 if iso=="SVK" & startyear==1990
sort iso startyear endyear
expand 2 if iso=="SVK"  & iso!=iso[_n+1]
replace leader = "Carnogursky" if iso[_n+1]==""
replace startyear = 1991 if iso=="SVK" & leader =="Carnogursky"
replace endyear = 1992 if iso=="SVK" & leader =="Carnogursky"

replace endyear = 2007 if iso=="POL" & leader=="Kaczynski"
replace leader = "Kaczynski brothers/PiS" if iso=="POL" & leader=="Kaczynski"
replace leader = "Civic Platform" if iso=="POL" & leader=="Komorowski" & endyear==2015
replace startyear = 2007 if iso=="POL" & leader=="Civic Platform"
replace leader = "PiS (esp. Jaroslaw Kaczynski)" if iso=="POL" & leader=="Komorowski" 
replace startyear = 2015 if iso=="POL" & leader == "PiS (esp. Jaroslaw Kaczynski)" 
replace endyear = 2018 if iso=="POL" & leader == "PiS (esp. Jaroslaw Kaczynski)" 
drop if iso=="POL" & (leader=="Borusewicz" | leader=="Schetyna")

replace leader="Chiang Kai-shek (TWN)" if leader=="Chiang Kai-shek" & iso=="TWN"
replace obsid="" if iso=="SVK" | iso=="POL" | iso=="DEU"
replace startdate="" if iso=="SVK" | iso=="POL" | iso=="DEU"
replace enddate="" if iso=="SVK" | iso=="POL" | iso=="DEU"

* Expanding Archigos_4 with new leaders until 2019


sort iso obsid startdate enddate startyear endyear

gen p=.
replace p=1 if iso=="ARG" & leader=="Irigoyen" & startyear==1916 & endyear==1922
replace p=1 if iso=="ARG" & leader=="Irigoyen" & startyear==1928 & endyear==1930
replace p=1 if iso=="ARG" & leader=="Peron" & startyear==1946 & endyear==1955
replace p=1 if iso=="ARG" & leader=="Peron" & startyear==1973 & endyear==1974
replace p=1 if iso=="ARG" & leader=="Peron, Isabel" & startyear==1974 & endyear==1976
replace p=1 if iso=="ARG" & leader=="Menem" & startyear==1989 & endyear==1999
replace p=1 if iso=="ARG" & leader=="Nestor Kirchner" & startyear==2003 & endyear==2007
replace p=1 if iso=="ARG" & leader=="Fernandez de Kirchner" & startyear==2007 & endyear==2015
replace p=1 if iso=="BGR" & leader=="Boyko Borisov" & startyear==2009 & endyear==2013
replace p=1 if iso=="BGR" & leader=="Boyko Borisov" & startyear==2014 & endyear==2017
replace p=1 if iso=="BGR" & leader=="Boyko Borisov" & startyear==2017 & endyear==2018
replace p=1 if iso=="BOL" & leader=="Paz Estenssoro" & startyear==1952 & endyear==1956
replace p=1 if iso=="BOL" & leader=="Siles Zuazo" & startyear==1956 & endyear==1960
replace p=1 if iso=="BOL" & leader=="Paz Estenssoro" & startyear==1960 & endyear==1964
replace p=1 if iso=="BOL" & leader=="Juan Morales" & startyear==2006 & endyear==2018
replace p=1 if iso=="BRA" & leader=="Vargas" & startyear==1930 & endyear==1945
replace p=1 if iso=="BRA" & leader=="Vargas" & startyear==1951 & endyear==1954
replace p=1 if iso=="BRA" & leader=="Mello" & startyear==1990 & endyear==1992
replace p=1 if iso=="CHL" & leader=="Alessandri y Palma" & startyear==1920 & endyear==1924
replace p=1 if iso=="CHL" & leader=="Ibanez del Campo" & startyear==1925 & endyear==1925
replace p=1 if iso=="CHL" & leader=="Alessandri y Palma" & startyear==1925 & endyear==1925
replace p=1 if iso=="CHL" & leader=="Ibanez del Campo" & startyear==1927 & endyear==1931
replace p=1 if iso=="CHL" & leader=="Alessandri y Palma" & startyear==1932 & endyear==1938
replace p=1 if iso=="CHL" & leader=="Ibanez Campo" & startyear==1952 & endyear==1958
replace p=1 if iso=="DEU" & leader=="Hitler" & startyear==1933 & endyear==1945
replace p=1 if iso=="ECU" & leader=="Velasco Ibarra" & startyear==1934 & endyear==1935
replace p=1 if iso=="ECU" & leader=="Velasco Ibarra" & startyear==1944 & endyear==1947
replace p=1 if iso=="ECU" & leader=="Velasco Ibarra" & startyear==1952 & endyear==1956
replace p=1 if iso=="ECU" & leader=="Velasco Ibarra" & startyear==1960 & endyear==1961
replace p=1 if iso=="ECU" & leader=="Velasco Ibarra" & startyear==1968 & endyear==1972
replace p=1 if iso=="ECU" & leader=="Bucaram Ortiz" & startyear==1996 & endyear==1997
replace p=1 if iso=="ECU" & leader=="Rafael Correa" & startyear==2007 & endyear==2017
replace p=1 if iso=="GRC" & leader=="Alexis Tsipras" & startyear==2015 & endyear==2018
replace p=1 if iso=="HUN" & leader=="Orban" & startyear==2010 & endyear==2018
replace p=1 if iso=="IDN" & leader=="Sukarno" & startyear==1945 & endyear==1948
replace p=1 if iso=="IDN" & leader=="Sukarno" & startyear==1949 & endyear==1966
replace p=1 if iso=="IDN" & leader=="Joko Widodo" & startyear==2014 & endyear==2018
replace p=1 if iso=="IND" & leader=="Gandhi, I." & startyear==1966 & endyear==1977
replace p=1 if iso=="IND" & leader=="Narendra Modi" & startyear==2014 & endyear==2018
replace p=1 if iso=="ISR" & leader=="Netanyahu" & startyear==1996 & endyear==1999
replace p=1 if iso=="ISR" & leader=="Netanyahu" & startyear==2009 & endyear==2018
replace p=1 if iso=="ITA" & leader=="Mussolini" & startyear==1922 & endyear==1943
replace p=1 if iso=="ITA" & leader=="Berlusconi" & startyear==1994 & endyear==1995
replace p=1 if iso=="ITA" & leader=="Berlusconi" & startyear==2001 & endyear==2006
replace p=1 if iso=="ITA" & leader=="Berlusconi" & startyear==2008 & endyear==2011
replace p=1 if iso=="ITA" & leader=="Salvini/Di Maio" & startyear==2018 & endyear==2018
replace p=1 if iso=="JPN" & leader=="Junichiro Koizumi" & startyear==2001 & endyear==2006
replace p=1 if iso=="KOR" & leader=="Roh Moo Hyun" & startyear==2003 & endyear==2008
replace p=1 if iso=="MEX" & leader=="Cardenas" & startyear==1934 & endyear==1940
replace p=1 if iso=="MEX" & leader=="Echeverria Alvarez" & startyear==1970 & endyear==1976
replace p=1 if iso=="MEX" & leader=="Lopez Obrador" & startyear==2018 & endyear==2018
replace p=1 if iso=="NZL" & leader=="Muldoon" & startyear==1975 & endyear==1984
replace p=1 if iso=="PER" & leader=="Garcia Perez" & startyear==1985 & endyear==1990
replace p=1 if iso=="PER" & leader=="Fujimori" & startyear==1990 & endyear==2000
replace p=1 if iso=="PHL" & leader=="Estrada" & startyear==1998 & endyear==2001
replace p=1 if iso=="PHL" & leader=="Duterte" & startyear==2016 & endyear==2018
replace p=1 if iso=="POL" & leader=="Kaczynski brothers/PiS" & startyear==2005 & endyear==2007
replace p=1 if iso=="POL" & leader=="PiS (esp. Jaroslaw Kaczynski)" & startyear==2015 & endyear==2018
replace p=1 if iso=="SVK" & leader=="Meciar" & startyear==1990 & endyear==1991
replace p=1 if iso=="SVK" & leader=="Meciar" & startyear==1992 & endyear==1994
replace p=1 if iso=="SVK" & leader=="Meciar" & startyear==1994 & endyear==1998
replace p=1 if iso=="SVK" & leader=="Fico" & startyear==2006 & endyear==2010
replace p=1 if iso=="SVK" & leader=="Fico" & startyear==2012 & endyear==2018
replace p=1 if iso=="THA" & leader=="Thaksin Shinawatra" & startyear==2001 & endyear==2006
replace p=1 if iso=="TUR" & leader=="Erdogan" & startyear==2003 & endyear==2018
replace p=1 if iso=="TWN" & leader=="Chen Shui-bian" & startyear==2000 & endyear==2008
replace p=1 if iso=="USA" & leader=="Trump" & startyear==2017 & endyear==2018
replace p=1 if iso=="VEN" & leader=="Hugo Chavez" & startyear==1999 & endyear==2013
replace p=1 if iso=="VEN" & leader=="Maduro" & startyear==2013 & endyear==2018
replace p=1 if iso=="ZAF" & leader=="Zuma" & startyear==2009 & endyear==2018

drop if startyear<1900
drop if p==1
drop if startyear==endyear & startyear!=2018 & endyear!=2018
drop if iso=="CHE"

bys iso: gen predecessor1 = 1 if (leader==leader[_n+1]) & (startyear[_n+1]<=endyear+1)  
bys iso: gen predecessor2 = 1 if (leader==leader[_n+2]) & (startyear[_n+2]<=endyear+1) & predecessor1 ==.  

drop if predecessor1[_n-1]==1 
drop if predecessor2[_n-2]==1 
drop if predecessor2[_n-1]==1 

keep iso startyear
gen placebo = 1
rename startyear year

save _placebo, replace

use Code_Populist, clear

merge 1:1 iso year using _placebo
drop if _merge==2
drop _merge

replace placebo = 0 if placebo==.


save Code_Populist, replace
clear 


cap !del _*
cap !rm _*.dta


******************************************************************************************
******************************************************************************************
******************************************************************************************
****Polishing (Copied and Altered from ReplicationPackage)
******************************************************************************************
******************************************************************************************
******************************************************************************************

use Code_Populist, clear

order country iso year cid PopClass Leaders LeftRight CorePop CoreTake LeftCorePop LeftCoreTake RightCorePop RightCoreTake BorderPop BorderTake LeftBorderPop LeftBorderTake RightBorderPop RightBorderTake ExtPop ExtTake LeftExtPop LeftExtTake RightExtPop RightExtTake placebo Continent

* Identifyer
label var Continent "Continent of Country"
label var Leaders "Name of the Populist coming to Power"

* Populists in Power
label var PopClass "Class of Populists: Core if multiple agree, Borderline if only one list, and Extended are all before 1946"
label var CorePop "Populist in power (0-1 dummy), core cases"
label var LeftCorePop "Left-wing populist in power (0-1 dummy), core cases"
label var RightCorePop "Right-wing populist in power (0-1 dummy), core cases"
label var BorderPop "Populist in power (0-1 dummy), borderline cases"
label var LeftBorderPop "Left-wing populist in power (0-1 dummy), borderline cases"
label var RightBorderPop "Right-wing populist in power (0-1 dummy), borderline cases"
label var ExtPop "Populist in power (0-1 dummy), all (extended) cases"
label var LeftExtPop "Left-wing populist in power (0-1 dummy), all (extended) cases"
label var RightExtPop "Right-wing populist in power (0-1 dummy), all (extended) cases"

* Populist Takeovers
label var CoreTake  "Populist government takeover (0-1 dummy), core cases"
label var LeftCoreTake "Left-wing populist government takeover (0-1 dummy), core cases"
label var RightCoreTake "Right-wing populist government takeover (0-1 dummy), core cases"
label var BorderTake  "Populist government takeover (0-1 dummy), borderline cases"
label var LeftBorderTake "Left-wing populist government takeover (0-1 dummy), borderline cases"
label var RightBorderTake "Right-wing populist government takeover (0-1 dummy), borderline cases"
label var ExtTake  "Populist government takeover (0-1 dummy), all (extended) cases"
label var LeftExtTake "Left-wing populist government takeover (0-1 dummy), all (extended) cases"
label var RightExtTake "Right-wing populist government takeover (0-1 dummy), all (extended) cases"

* Placebos
label var placebo "Non-populist government takeover (0-1 dummy)"


format %15s country

save Populist_Data, replace

cap !del Code_Populist.dta
cap !rm Code_Populist.dta

clear



