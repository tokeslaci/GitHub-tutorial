* Figure 12 : distribution of the answers to ’does the firm have to improve its
	     //product/process for the relationship now’ for key relationships (each such
	     //relationship when respondent is supplier is one observation)
	*12a: by type of firm
	*12b: by country

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
	
		g inno=0 if product_recent_modify<99 & process_recent_modify<99
	
	replace inno=1 if product_recent_modify==1
	replace inno=2 if process_recent_modify==1
	replace inno=3 if product_recent_modify==1 & process_recent_modify==1
	
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
			saving("$out_fig/Fig12b", replace)
			
	
			
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
			saving("$out/Fig12a", replace)					
