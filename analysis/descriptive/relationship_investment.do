* Figure 6: how firms find customers - distribution of the answers to ’how the relationship started?’ for key
	   //relationships (each such relationship when respondent is supplier is one observation).
	*6a: by country
	*6b: by type of firms

	use "$data/buyer_hash", clear

	cap drop _merge
	merge m:1 masterid_hash using "$in_ama/Amadeus_ceu2015_alldata_HU_SK_RO_wresp.dta", keep(match) 
	
	
	drop if group_member==.  /*here we may be better of by consitently defining which supplier is missing fully */
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
	
		g relation_form=relation_form_nogroup
	replace relation_form=6 if relation_form_nogroup==5 | relation_form_nogroup==98
	replace relation_form=5 if relation_form_group==1 | relation_form_group==2
	
	replace relation_form=. if relation_form_nogroup>6 ///
		& relation_form_group!=1 & relation_form_group!=2
	
	label define relationship 1 "Supplier approached buyer" ///
		2 "Buyer approached seller" ///
		3 "Via network" ///
		4 "Professional event" ///
		5 "Within group" ///
		6 "Other"
	
	label define relationship_s 1 "Supplier initiated" ///
		2 "Buyer initiated" ///
		3 "Within group" ///
		4 "Network, event, etc" 
		
	recode relation_form (1 =1 ) (2=2) (3 4 6 =4) (5=3) ///
		, g(relation_form_s )
	
	label values relation_form_s relationship_s
		
	label values 	relation_form relationship
	
	tab relation_form category, nofreq col
	
	forvalues i=1/4 {
		local label_`i': label relationship_s `i'
		g cat_`i'=0 if relation_form_s!=.
		replace cat_`i'=1 if  relation_form_s==`i'
		label var cat_`i' "`label_`i''"
	}

	graph bar cat_*, stack over(countryisocode) ///
		legend( label(1 "`label_1'" ) label(2 "`label_2'" ) ///
		label(3 "`label_3'" ) label(4 "`label_4'" ) 	) ///
		legend(pos(3) col(1) stack order(1 - " " 2 - " " 3 - " " 4)) ///
		saving("$out_fig/Fig6a", replace)	
	
	graph bar cat_*, stack over(category) ///
		legend( label(1 "`label_1'" ) label(2 "`label_2'" ) ///
		label(3 "`label_3'" ) label(4 "`label_4'" ) 	) ///
		legend(pos(3) col(1) stack order(1 - " " 2 - " " 3 - " " 4)) ///
		saving("$out_fig/Fig6b", replace)
	
	drop cat_*
	
* Figure 7 : distribution of the answers to ’did the firm has to improve its
	     //product/process for the relationship at the beginning’ for key relationships (each such
	     //relationship when respondent is supplier is one observation)
	*7a: by type of firm
	*7b: by country

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
	
		g inno=0 if product_start_modify<99 & process_start_modify<99
	
	replace inno=1 if product_start_modify==1
	replace inno=2 if process_start_modify==1
	replace inno=3 if product_start_modify==1 & process_start_modify==1
	
	forvalues i=1/3 {
		g cat_`i'=0 if inno!=.
		replace cat_`i'=100 if  inno==`i'
	}
	
	replace cat_3=cat_3/2
	
	g junk=0

	levelsof category, local(levels)
    foreach l of local levels {
		cap drop junk2
		g junk2=0 if inno!=.
		replace junk2=100 if inno>0 & inno!=.
		sum junk2 if category==`l'
		local junk=round(`r(mean)', 0.1)
		local p`l'="`junk'"
    }
	
	graph hbar cat_3 cat_1 junk, stack over(category, axis(off)) saving("$out/g1", replace) ///
		xalternate yreverse horiz  title(product) ylabel(0 (10) 50) ///
		bar(3, bcolor(ltblue)) ///
		legend(pos(11) ring(0) col(1) lab(1 "Both") lab(2 "Only product") label(3 "Only process"))
	graph hbar cat_3 cat_2, stack over(category, axis(off)) saving("$out/g2", replace) ///
		text(22 85 "Dom., small (`p0'%)", place(e) size(large)) ///
		text(22 50 "Dom., large (`p2'%)", place(e) size(large)) ///
		text(22 15 "Foreign (`p3'%)", place(e) size(large))  ///
		legend(off) title(process) bar(2, bcolor(ltblue)) ylabel(0 (10) 50)
	
		
	graph combine "$out/g1.gph" "$out/g2.gph" ///
		, imargin(0 0 0 0) ///
			saving("$out_fig/Fig7b", replace)
			
	
			
	local counter=1
	levelsof countryisocode, local(levels)
    foreach l of local levels {
		cap drop junk2
		g junk2=0 if inno!=.
		replace junk2=100 if inno>0 & inno!=.
		sum junk2 if countryisocode=="`l'"
		local junk=round(`r(mean)', 0.1)
		local p`counter'="`junk'"
		local counter=`counter'+1
    }
			
	graph hbar cat_3 cat_1 junk, stack over(countryisocode, axis(off)) saving("$out/g1", replace) ///
		xalternate yreverse horiz  title(product) ylabel(0 (10) 50) ///
		bar(3, bcolor(ltblue)) ///
		legend(pos(11) ring(0) col(1) lab(1 "Both") lab(2 "Only product") label(3 "Only process"))
	graph hbar cat_3 cat_2, stack over(countryisocode, axis(off)) saving("$out/g2", replace) ///
		text(25 85 "Hungary (`p1'%)", place(e) size(large)) ///
		text(25 50 "Romania (`p2'%)", place(e) size(large)) ///
		text(25 15 "Slovakia (`p3'%)", place(e) size(large))  ///
		legend(off) title(process) bar(2, bcolor(ltblue)) ylabel(0 (10) 50)
		
	graph combine "$out/g1.gph" "$out/g2.gph" ///
		, imargin(0 0 0 0) ///
			saving("$out_fig/Fig7a", replace)					

* Table 9: Cross relation length - median length of key relationships (each such relationship when
	   //respondent is supplier is one observation). SME: <=50 employees, large otherwise.

	use "$data/buyer_hash", clear

	cap drop _merge
	merge m:1 masterid_hash using "$in_ama/Amadeus_ceu2015_alldata_HU_SK_RO_wresp.dta", keep(match) 
	
	
	drop if group_member==.  /*here we may be better of by consitently defining which supplier is missing fully*/
	label define emp_cat 1 "10-50" 2 "51-250" 3 ">250"
	label values  number_employees emp_cat
	recode number_employees (1 2=1 "10-250") (3 = 2 ">250"), g(emp_cat_ag)
	g category=0
	replace category=2 if emp_cat_ag==2 & owner==1
	replace category=3 if emp_cat_ag==2 & owner==2
	label define category 0 "Domestic SME" 1 "SME, foreign" ///
		2 "Domestic large" 3 "Foreign-owned"
	label values category category	
	g exp_share=(sales_export_EU_2014 +sales_export_outside_EU_2014 )/sales_total_2014
	replace exp_share=0 if exp_share==.
	label var exp_share "Export share of revenue, 2014"
	g b_newshare=(1-buyer_returning_number_2015/buyer_number_2015)*100
	label var  b_newshare "Share of new buyers 2015 (%)"
	g s_newshare=(1-supplier_returning_number_2015/supplier_number_2015)*100
	label var s_newshare "Share of new suppliers 2015 (%)"	
	
	
	destring partner_index, force replace				
	
	drop if missing(SME) | missing(country)
	g category_B=0
	replace category_B=1 if SME==1
	replace category_B=2 if SME==2
	replace category_B=3 if (countryisocode=="HU" & country==11) ///
		| (countryisocode=="RO" & country==17) ///
		| (countryisocode=="SK" & country==20)
		
	label define category_B 1 "Domestic SME" 2 "Domestic large" 3 "Abroad"
	label values category_B category_B
	
	label var countryisocode "Country of reporting firm"
	label var category_B "Type of customer"
	label var category "Type of reporting firm (seller)"
	
	tabout countryisocode category_B category using "$out_tab/Table9.xls" ///
		, replace sum c(p50 relation_length)  h3(nil)	
		
* Table 8: co-innovation - type of assistance (technology transfer, asset transfer, regular meeting/consulting)
	   //provided by the buyer for product development at the start of the relationship for different types of firms
	*8a: product
	*8b: process (not included in presentation)

	foreach var of varlist  product_start_technology product_start_asset product_start_meeting ///
		process_start_technology process_start_asset process_start_meeting {
			replace `var'=0 if missing(`var')
			replace `var'=`var'*100
		}
	tabout  category_B category using "$out_tab/Table8a.xls" ///
		, replace sum c(mean product_start_technology)  	///
		h3(Technology transfer)
		
	tabout  category_B category using "$out_tab/Table8a.xls" ///
		, append sum c(mean  product_start_asset) 	///		
		h3(Asset transfer)
		
	tabout  category_B category using "$out_tab/Table8a.xls" ///
		, append sum c(mean  product_start_meeting ) ///
		h3(Regular meetings, consulting)
		
	tabout  category_B category using "$out_tab/Table8b.xls" ///
		, replace sum c(mean process_start_technology) 	///
		h3(Technology transfer)
		
	tabout  category_B category using "$out_tab/Table8b.xls" ///
		, append sum c(mean  process_start_asset)  	///		
		h3(Asset transfer)
		
	tabout  category_B category using "$out_tab/Table8b.xls" ///
		, append sum c(mean  process_start_meeting )   ///
		h3(Regular meetings, consulting)	
		
* Table 11: OLS regressions for ln(labour productivity) and customer/supplier characteristics

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
	replace top3_B=100 if top3_B>100 & 	top3_B!=.
	replace top3_S=. if top3_S==0
	replace top3_S=100 if top3_S>100 & 	top3_S!=.	
	g length_B=.
	replace length_B=relation_length if rel=="B"
	g length_S=.
	replace length_S=relation_length if rel=="S"
	g group_B=0
	replace group_B=1 if group_mem==1 & rel=="B"
	g group_S=0
	replace group_S=1 if group_mem==1 & rel=="S"
	g for_B=0
	replace for_B=1 if  rel=="B" & ((country_code=="HU" & country==11) ///
		| (country_code=="RO" & country==17) ///
		| (country_code=="SK" & country==20))
	g for_S=0
	replace for_S=1 if  rel=="S" & ((country_code=="HU" & country==11) ///
		| (country_code=="RO" & country==17) ///
		| (country_code=="SK" & country==20))
		
	g inno_B=0
	replace inno_B=1 if rel=="B" & ( product_start_modify==1 | process_start_modify==1)


	g tt_B=0
	replace tt_B=1 if rel=="B" & (product_start_technology==1 | process_start_technology==1)
	
	collapse (mean) top3_B top3_S length_B length_S ///
		(max) group_B group_S for_B for_S (mean) inno_B  tt_B , by(masterid_hash)
	
	cap drop _merge
	merge m:1 masterid_hash using "$in_ama/Amadeus_ceu2015_alldata_HU_SK_RO_wresp.dta", keep(match) 
	
	label define emp_cat 1 "10-50" 2 "51-250" 3 ">250"
	label values  number_employees emp_cat
	recode number_employees (1 2=1 "10-250") (3 = 2 ">250"), g(emp_cat_ag)
	g category=0
	replace category=2 if emp_cat_ag==2 & owner==1
	replace category=3 if emp_cat_ag==2 & owner==2
	label define category 0 "Domestic SME" 1 "SME, foreign" ///
		2 "Domestic large" 3 "Foreign-owned"
	label values category category	
	g exp_share=(sales_export_EU_2014 +sales_export_outside_EU_2014 )/sales_total_2014
	replace exp_share=0 if exp_share==.
	label var exp_share "Export share of revenue, 2014"
	g b_newshare=(1-buyer_returning_number_2015/buyer_number_2015)*100
	label var  b_newshare "Share of new buyers 2015 (%)"
	g s_newshare=(1-supplier_returning_number_2015/supplier_number_2015)*100
	label var s_newshare "Share of new suppliers 2015 (%)"	

	
	g LP=ln(( oprevtover2013-materialcoststheur2013)/numberofemployees2013)
	
	g ln_num_buyers=ln(buyer_number_2015)
	g ln_num_sup=ln(supplier_number_2015)
	encode countryisocode, g(ccode)
	g ln_emp=ln(numberofemployees2013)
	
	reg LP ln_num_buyers ln_num_sup ln_emp i.category i.sector2 i.ccode
		outreg2 using "$out_tab/Table11", replace excel bdec(3) 
	reg LP ln_num_buyers ln_num_sup  group_B group_S for_B for_S ln_emp i.category i.sector2 i.ccode		
		outreg2 using "$out_tab/Table11", append excel bdec(3) 
	reg LP ln_num_buyers ln_num_sup  group_B group_S for_B for_S length_B length_S ln_emp i.category i.sector2 i.ccode		
		outreg2 using "$out_tab/Table11", append excel bdec(3) 		
	
