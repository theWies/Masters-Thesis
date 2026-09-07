******************************************************************************************
******************************************************************************************
******************************************************************************************
****Package for Dataset (Taken from Replication Package)
******************************************************************************************
******************************************************************************************
******************************************************************************************

net install dm89_2.pkg, from("http://www.stata-journal.com/software/sj15-4") 
ssc install appendfile
ssc install carryforward
ssc install did_imputation
ssc install estout
* includes eststo, esttab, and estadd
ssc install ftools
ssc install reghdfe
ssc install stripplot
ssc install texsave
ssc install tsspell
ssc install winsor2

ssc install synth
net install synth_runner, from(https://raw.github.com/bquistorff/synth_runner/master/) replace 

******************************************************************************************
******************************************************************************************
******************************************************************************************

* On my PC this took about 5h to complete, but I have a weak PC (higher CPU/GPU might increase speed). I think there might be a more efficient way of coding it, but doing it this way allowed me to copy paste this template for most of my analysis points. Plus, the computing time halfs when not using the nested optimization method. 

* Run Data Preparations
 run Programs/1_Populist_Coding // Ready
 run Programs/2_Data_Prep // Ready

* Run Descriptives
 run Programs/3_MainDescriptives // IWie produziert der keine gefüllten .log Dateien
* One fix is to copy it into the main folder and run the .do file directly.

* Run Results
 run Programs/4_MainResults // Ready
 run Programs/5_OtherIndicators // Ready
 run Programs/6_HeterogeneityResults // Ready
 run Programs/7_OtherIndicators_NoEU // Ready






