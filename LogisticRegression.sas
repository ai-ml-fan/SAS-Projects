

*********************************************************;
* CREATE THE DATA SET;
*********************************************************;

data TEMPFILE;
input X6 X8 YTEMP;
Y = (YTEMP>10);
drop YTEMP;
datalines;
20  35.3  10.98
20  29.7  11.13
23  30.8  12.51
20  58.8  8.40
21  61.4  9.27
22  71.3  8.73
11  74.4  6.36
23  76.7  8.50
21  70.7  7.82
20  57.5  9.14
20  46.4  8.24
21  28.9  12.19
21  28.1  11.88
19  39.1  9.57
23  46.8  10.94
20  48.5  9.58
22  59.3  10.09
22  70.0  8.11
11  70.0  6.83
23  74.5  8.88
20  72.1  7.68
21  58.1  8.47
20  44.6  8.86
20  33.4  10.36
22  28.6  11.08
;
run; 

proc print data=TEMPFILE;
run;


********************* ;
* LOGISTIC REGRESSION ;
********************* ;

proc logistic data=TEMPFILE;
model Y(ref="0") = X6 X8;
run;
quit;


proc probit data=TEMPFILE;
model Y(ref="0") = X6 X8 /d=logistic;
run;
quit;


proc genmod data=TEMPFILE descending;
model Y = X6 X8 /dist=binomial link=logit;
run;


data SCOREFILE;
set TEMPFILE;

TEMP		= -327.0 + 20.5993*X6 - 2.0414*X8;
TEMP		= exp(TEMP);
if missing(TEMP) then TEMP = 999999;
P_LOGISTIC	= TEMP / (1+TEMP);

TEMP		= -2726.18 + 172.5663*X6 - 17.2896*X8;
TEMP		= exp(TEMP);
if missing(TEMP) then TEMP = 999999;
P_PROBIT	= TEMP / (1+TEMP);

TEMP		= -2280.16 + 144.2818*X6 - 14.4518*X8;
TEMP		= exp(TEMP);
if missing(TEMP) then TEMP = 999999;
P_GENMOD	= TEMP / (1+TEMP);


drop TEMP;
run;

proc print data=SCOREFILE;
run;


********************* ;
* PROBIT REGRESSION ;
********************* ;

proc probit data=TEMPFILE;
model Y(ref="0") = X6 X8;
run;
quit;


proc genmod data=TEMPFILE descending;
model Y = X6 X8 /dist=binomial link=probit;
run;



data SCOREFILE;
set TEMPFILE;

TEMP		= -569.331 + 36.0494*X6 -3.6142*X8;
P_PROBIT	= probnorm(TEMP);

TEMP		= -501.599 + 31.7541*X6 - 3.1829*X8;
P_GENMOD	= probnorm(TEMP);


drop TEMP;
run;

proc print data=SCOREFILE;
run;



