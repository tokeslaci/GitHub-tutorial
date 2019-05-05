* Table 1: Number of observations by country & number of employees / ownership / industry

	use "$in_ama/Amadeus_ceu2015_alldata_HU_SK_RO_wresp.dta", clear

	recode numberofemployees2013 (min/20=1 "less than 20 ") ///
		(21/50=2 "21-50") ///
		(51/250=3 "51-250") ///
		(250/max=4 "more than 250") ///
		, gen(size_cat)
	la var size_cat "Number of employees"
	replace size_cat=1 if size_cat==.  /*Clean it */

	g foreign=0
	replace foreign=1 if foreign_ind_owner==1 |  foreign_other_owner==1
	la def for 0 "Domestic" 1 "Foreign"
	label values foreign for
	label var foreign "Ownership"

	do "$anal/nace2_label_en.do"

	label values sector2 nace2

	label var sector2 "Industry"
	replace sector2=20 if sector2<20
	replace sector2=30 if sector2>30  /*WE have to check the industry of these firms --> NACE 30+ is not supposed to be in the sample*/ 


	tabout size_cat foreign sector2 countryisocode  using  "$out_tab/Table1.xls", ///
		cells(freq ) replace ptotal(single)

* Table 2: Median  numbers at the firm level for the number of suppliers, customers, the
	   //number of returning partners, the share of the TOP3 partners in sales/material costs 
	   //and the average length of key relationships.

	use "$data/buyer_hash", clear
	g rel="B"
	append using "$in/supplier_hash", 
	replace rel="S" if rel==""
	cap drop junk
	g junk=0
	replace junk=share if share!=. & (partner_index=="1" | partner_index=="2" | partner_index=="3")
	bysort masterid_hash rel: egen top3=total(junk)
	g top3_B=.
	replace top3_B=top3 if rel=="B" & partner_index=="1" 
	g top3_S=.
	replace top3_S=top3 if rel=="S" & partner_index=="1" 
	replace top3_B=. if top3_B==0
	replace top3_B=100 if top3_B>100 & top3_B!=.
	replace top3_S=. if top3_S==0
	replace top3_S=100 if top3_S>100 & top3_S!=.	
	g length_B=.
	replace length_B=relation_length if rel=="B"
	g length_S=.
	replace length_S=relation_length if rel=="S"
	
	collapse (median) top3_B top3_S length_B length_S, by(country_code)
	rename country_code countryisocode
	save "$out/junk", replace
	
	use "$in_ama/Amadeus_ceu2015_alldata_HU_SK_RO_wresp.dta", clear
	collapse (median) buyer_number_2015 buyer_returning_number_2015 ///
		supplier_number_2015 supplier_returning_number_2015, by(countryisocode)
	merge countryisocode using "$out/junk"
	
		rename supplier_number_2015 number_S
		rename supplier_returning_number_2015 returning_S
		rename buyer_number_2015 number_B
		rename buyer_returning_number_2015 returning_B
	
	replace returning_S=returning_S/number_S
	replace returning_B=returning_B/number_B
	
	reshape long number_ returning_ top3_ length_, i(countryisocode) j(rel) string
	cap drop _merge
	save "$out_tab/Table2", replace
	
* Figure 3: percentages (1-99) of the distribution of the variables (number of customers, //
	   //share of new customers, share of top customer, share of TOP3 customers)

	use "$data/buyer_hash", clear

	cap drop _merge
	merge m:1 masterid_hash using "$in_ama/Amadeus_ceu2015_alldata_HU_SK_RO_wresp.dta", keep(match) 
	
	
	drop if group_member==.  /*here we may be better of by consitently defining which supplier is missing fully*/
				 //--> we should define those relevant/crucial variables, which if missing, then that data point doesn't count as an observation.
	label define emp_cat 1 "10-50" 2 "51-250" 3 ">250"
	label values  number_employees emp_cat
	recode number_employees (1=1 "10-50") (2 3 = 2 ">50"), g(emp_cat_ag)
	g category=0
	replace category=2 if emp_cat_ag==2 & owner==1
	replace category=3 if emp_cat_ag==2 & owner==2
	label define category 0 "Small, dom." 1 "Small, foreign" ///
		2 "Large, dom." 3 "Foreign"
	label values category category	
	g exp_share=(sales_export_EU_2014 +sales_export_outside_EU_2014 )/sales_total_2014
	replace exp_share=0 if exp_share==.
	label var exp_share "Export share of revenue, 2014"
	g b_newshare=(1-buyer_returning_number_2015/buyer_number_2015)*100
	label var  b_newshare "Share of new buyers 2015 (%)"
	g s_newshare=(1-supplier_returning_number_2015/supplier_number_2015)*100
	label var s_newshare "Share of new suppliers 2015 (%)"	
	

	destring partner_index, force replace	
	drop if partner_index>3	
	
	collapse (mean) b1_number=buyer_number_2015 ///
		(sum) b4_3share=share (max)  b3_1share=share (mean) b2_newshare=b_newshare , by(masterid)
	
	replace b4_3share=. if b4_3share==0 
	replace b3_1share=. if b3_1share==0 	
	
	foreach var of varlist b1_number b2_newshare b4_3share b3_1share {
		foreach num of numlist 5 10(10)95  {	
			egen p`num'_`var'=pctile(`var'), p(`num')
			replace p`num'_`var'=round(p`num'_`var')
			replace p`num'_`var'=100 if p`num'_`var'>100 & (`var'!=b1_number)
		}
	}	
	
	
	keep p5_* p??_* 
	keep in 1
	g id=1
	reshape long p1 p10 p20 p30 p40 p50 p60 p70 p80 p90 p99, i(id) j(var) string
	reshape long p, i(id var) j(perc) 
	encode var, g(varcode)
	
	line p perc if varcode==1, ///
		xtitle("Percentile") ytitle("Number of customers") ///
		saving("$out/b1", replace)  title("A: Number of customers")
	line p perc if varcode==2, ///
		yscale(range(0 100)) ylabel(0(20)100) ///
		xtitle("Percentile") ytitle("Share of new customers") ///
		saving("$out/b2", replace) title("B: Share of new customers")		
	line p perc if varcode==3, ///
		yscale(range(0 100))  ylabel(0(20)100)  ///	
		xtitle("Percentile") ytitle("Share of top customer") ///
		saving("$out/b3", replace) title("C: Share of top customer")		
	line p perc if varcode==4, ///
		yscale(range(0 100))  ylabel(0(20)100)  ///	
		xtitle("Percentile") ytitle("Share of TOP3 customers") ///
		saving("$out/b4", replace) title("D: Share of TOP3 customers")	
		
	graph combine "$out/b1" "$out/b2" "$out/b3" "$out/b4", 	///
			saving("$out_fig/Fig3", replace)	

* Figure 4: kernel densities of the ln number of customers. Small: <=50 employees, 
		//large otherwise. Foreign: foreign controlled.

use "$data/buyer_hash", clear

	cap drop _merge
	merge m:1 masterid_hash using "$in_ama/Amadeus_ceu2015_alldata_HU_SK_RO_wresp.dta", keep(match) 
	
	
	drop if group_member==.  /*here we may be better of by consitently defining which supplier is missing fully*/
	label define emp_cat 1 "10-50" 2 "51-250" 3 ">250"
	label values  number_employees emp_cat
	recode number_employees (1=1 "10-50") (2 3 = 2 ">50"), g(emp_cat_ag)
	g category=0
	replace category=2 if emp_cat_ag==2 & owner==1
	replace category=3 if emp_cat_ag==2 & owner==2
	label define category 0 "Small, dom." 1 "Small, foreign" ///
		2 "Large, dom." 3 "Foreign"
	label values category category	
	g exp_share=(sales_export_EU_2014 +sales_export_outside_EU_2014 )/sales_total_2014
	replace exp_share=0 if exp_share==.
	label var exp_share "Export share of revenue, 2014"
	g b_newshare=(1-buyer_returning_number_2015/buyer_number_2015)*100
	label var  b_newshare "Share of new buyers 2015 (%)"
	g s_newshare=(1-supplier_returning_number_2015/supplier_number_2015)*100
	label var s_newshare "Share of new suppliers 2015 (%)"	
	
	destring partner_index, force replace	
	drop if partner_index>3	

	collapse (mean) b1_number=buyer_number_2015 ///
		, by(masterid countryisocode category)
	
		replace b1_number=log(b1_number)
	
		twoway (kdensity b1_number if category==0 ) ///
		(kdensity b1_number if category==2 ) ///
		(kdensity b1_number if category==3 ) /// 
		,	xtitle("log number of customers") ytitle("") ///
		saving("$out/b1", replace)  title("By firm type") ///
		legend(label(1 "Small domestic") label(2 "Large domestic") label(3 "Foreign"))

		twoway (kdensity b1_number if countryisocode=="HU" ) ///
		(kdensity b1_number if countryisocode=="RO" ) ///
		(kdensity b1_number if countryisocode=="SK" ) /// 
		,	xtitle("log number of customers") ytitle("") ///
		saving("$out/b2", replace)  title("By country") ///
		legend(label(1 "Hungary") label(2 "Romania") label(3 "Slovakia"))
		
		graph combine "$out/b1" "$out/b2" , 	///
			saving("$out_fig/Fig4", replace) ysize(2.5)		
			
* Table 5: distribution of headquarters of the key partners. One observation is one key relationship.
** --> little bit different numbers than in original presentation (<1%point).. why??? don't know
	   
	use "$data/buyer_hash", clear
	g junk=1
	replace country_code=country_code+": cust."
	append using "$in/supplier_hash"
			drop if country==33  /*don't know*/
	replace country_code=country_code+": supp." ///
		if country_code=="RO" |  country_code=="HU" |  country_code=="SK"	
	do "$anal/labels_en.do"
	collapse (count) group_member, by(country country_code)
	label values country country_code
	drop if country==.
	bysort country_code: egen share=pc(group_member)
	gsort country_code -share
	bysort country_code: gen rank=_n
	drop if rank>5
	encode country_code, g(ccode)
	
	label define country_code 54 `"Asia"', modify
	
	decode country, g(decode_country)
	g label=substr(decode_country, 1,6)
	replace share=round(share,0.1)
	tostring share, g(decode_share) force
	replace decode_share=substr(decode_share, 1,3) if share<10
	replace decode_share=substr(decode_share, 1,4) if share>10	
	replace label=label+" ("+decode_share+"%)"
	
	levelsof country, local(countries)
	local scattercmd ""
	foreach i of local countries {
		g junkvar_`i'=.
		replace junkvar_`i'=rank if country==`i'
		local scattercmd "`scattercmd' (scatter   rank ccode if country == `i' , msymbol(none) mlabel(label)   mlabpos(3) mlabsize(vlarge) mlabgap(-8) ) "

	}	
*twoway `scattercmd' /// --> it does another figure, with additional circles proportional to share, but not nice

/*
twoway (scatter junkvar_* ccode [w=share], msymbol(circle_hollow...) ) ///
	(scatter  rank ccode , msymbol(none)  mlabel(label) mlabcolor(grey)  mlabpos(3) mlabgap(7)) ///
	,  legend(off) ///
	xlabel(1 2 3, valuelabel angle(h)) xscale(r(0.5 3.5)) yscale(r(0 6)) xtitle("") ytitle("Rank")
*/

	label define ccode 1 "Customers" 2 "Suppliers" 3 "Customers" 4 "Suppliers" 5 "Customers" 6 "Suppliers", modify

	twoway 	`scattercmd'  ///
		,  legend(off) ///
		xlabel(1 2 3 4 5 6, valuelabel angle(h) labsize(large) ) xscale(r(0.5 6.5) alt ) yscale(r(0 6) reverse) ///
		ytitle("") xtitle("") ylabel(, labsize(large)) ytitle(Rank, size(large))  xline(2.5 4.5, style(p1dotmark)) ///
		text(-0.9 1.5 "Hungary", size(large)) text(-0.9 3.5 "Romania", size(large)) ///
		text(-0.9 5.5 "Slovakia", size(large)) ///
		saving("$out_tab/Table5", replace) ysize(1.8)
	
