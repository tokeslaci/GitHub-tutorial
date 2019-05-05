* Convert 1000 HUF to 1000 EUR

local salesvars "sales_total_ sales_total_domestic_ sales_export_EU_ sales_export_outside_EU_"
local years "2014 2015"
scalar EUR2014 = 314.89
scalar EUR2015 = 313.12 

foreach salevar of local salesvars {
foreach year of local years {

	generate `salevar'`year'_EUR = `salevar'`year' / EUR`year'
}
}

label var sales_total_2014_EUR "Total sales 1000EUR z02_14_1"
label var sales_total_2015_EUR "Total sales 1000EUR z02_15_1"
label var sales_total_domestic_2014_EUR "Total domestic sales 1000EUR z02_14_2"
label var sales_total_domestic_2015_EUR "Total domestic sales 1000EUR z02_15_2"
label var sales_export_EU_2014_EUR "Total export sales 1000EUR z02_14_3"
label var sales_export_EU_2015_EUR "Total export sales 1000EUR z02_15_3"
label var sales_export_outside_EU_2014_EUR "Total export sales outside EU 1000EUR z02_14_4"
label var sales_export_outside_EU_2015_EUR "Total export sales outside EU 1000EUR z02_15_4"

