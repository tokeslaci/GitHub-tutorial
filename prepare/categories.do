* This creates form type variables and labels
* uses respondent_hash


* create firm level vars
gen firm_group= company_not_business_group==0

gen firm_type_m=.
replace firm_type_m=1 if owner_type!=2 & company_not_business_group==0
replace firm_type_m=2 if owner_type==2
replace firm_type_m=3 if (owner_domestic_foreign==1 | owner_domestic_foreign==4)  /* includes 9 bank owned */
replace firm_type_m=4 if (owner_domestic_foreign==2  | owner_domestic_foreign==3)
 
label define ftype 1 "Firm type: group, domestic" 2 "Firm type: group, foreign" 3 "Firm type: private, domestic" 4 "Firm type: private, foreign"
label values firm_type ftype


*************
cap drop buyer_location
gen buyer_location=3
replace buyer_location=1 if ///
	country==11 & country_code=="HU" | ///
	country==17 & country_code=="RO"  | ///
	country==20 & country_code=="SK"

replace buyer_location=2 if ///
	country_code=="HU" & inlist(country, 17,20, 1,3,4,5,9,15, 21,26)  | ///
	country_code=="RO" & inlist(country, 11,20, 1,3,4,5,9,15, 21,26)  | ///
	country_code=="SK" & inlist(country, 11,17, 1,4,4,5,9,15, 21,26)  


label define area 1 `"Domestic buyer"', modify
label define area 2 `"Nearby export"', modify
label define area 3 `"Farther-away export"', modify

label values buyer_location area	
	
/*	
label define country 1 `"Austria"', modify
label define country 2 `"Belgium"', modify
label define country 3 `"Bulgaria"', modify
label define country 4 `"Croatia"', modify
label define country 5 `"Czechia"', modify
label define country 6 `"Denmark"', modify
label define country 7 `"Finland"', modify
label define country 8 `"France"', modify
label define country 9 `"Germany"', modify
label define country 10 `"Greece"', modify
label define country 11 `"Hungary"', modify
label define country 12 `"Italy"', modify
label define country 13 `"Netherlands"', modify
label define country 14 `"Norway"', modify
label define country 15 `"Poland"', modify
label define country 16 `"Portugal"', modify
label define country 17 `"Romania"', modify
label define country 18 `"Russia"', modify
label define country 19 `"Serbia"', modify
label define country 20 `"Slovakia"', modify
label define country 21 `"Slovenia"', modify
label define country 22 `"Spain"', modify
label define country 23 `"Sweden"', modify
label define country 24 `"Switzerland"', modify
label define country 25 `"Turkey"', modify
label define country 26 `"Ukraine"', modify
label define country 27 `"United Kingdom"', modify
label define country 33 `"Do not know"', modify
label define country 51 `"Other European countries"', modify
label define country 52 `"American countries"', modify
label define country 53 `"African countries"', modify
label define country 54 `"Asian countries"', modify
label define country 55 `"Australia and other countries"', modify
*/

