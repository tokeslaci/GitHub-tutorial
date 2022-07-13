net install dm67_4, from(http://www.stata-journal.com/software/sj15-4)

* install tabout version 2
ssc install tabout
* tabout version 3 cannot be installed from SSC
copy "http://tabout.net.au/downloads/main_version/tabout.txt" "`c(sysdir_plus)'t/tabout.ado", replace more

*** Proba
