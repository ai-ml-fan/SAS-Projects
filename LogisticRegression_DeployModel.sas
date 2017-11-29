

*********************************************************;
* CREATE THE DATA SET;
*********************************************************;

data TEMPFILE;
input X6 X8 Y;
Y = (Y>10);
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





*********************************************************;
* RUN THE LOGISTIC REGRESSION (Reference = "0")
* A high probability implies that Y=1
*
* Here are the coefficients:
*	Intercept     -327.0;
*	X6            20.5993;
*	X8            -2.0414;
* ;
*********************************************************;

proc logistic data=TEMPFILE;
model Y(ref="0") = X6 X8;
run;
quit;


*********************************************************;
* RUN THE LOGISTIC REGRESSION (Reference = "1")
* A high probability implies that Y=0
*
* Here are the coefficients:
*	Intercept     210.6;
*	X6            -13.2155;
*	X8            1.2996;
* ;
*********************************************************;

proc logistic data=TEMPFILE;
model Y(ref="1") = X6 X8;
run;
quit;





*********************************************************;
* PROBIT MODEL ;
* RUN THE LOGISTIC REGRESSION (Reference = "0") ;
*
* Here are the coefficients:
*	Intercept     -190.9;
*	X6            12.0548;
*	X8            -1.2010;
* ;
*********************************************************;

proc logistic data=TEMPFILE;
model Y(ref="0") = X6 X8 /link=probit;
run;
quit;






*********************************************************;
*
* The model is deployed as a DATA STEP and the DATA STEP
* is put into a SAS MACRO so that it will be easier to invoke
* with different data set
*
*********************************************************;

%macro SCORE( INFILE, OUTFILE );

data &OUTFILE.;
set &INFILE.;

* Calculate Prob of Y=1 from LOGIT Reference="0";
TEMP = -327.0 + 20.5993*X6 - 2.0414*X8;
TEMP = exp(TEMP);
TEMP = TEMP / (1.0+TEMP);
Y_Hat_Logit_0 = TEMP;

/** Calculate Prob of Y=1 from LOGIT Reference="1";*/
TEMP = 210.6 + -13.2155*X6 + 1.2996*X8;
TEMP = exp(TEMP);
TEMP = TEMP / (1.0+TEMP);
Y_Hat_Logit_1 = 1-TEMP;

/** Calculate Prob of Y=1 from PROBIT Reference="0";*/
TEMP = -190.9 + 12.0548*X6 - 1.2010*X8;
Y_Hat_Probit_0 = probnorm(TEMP);

drop TEMP;
run;

%mend;


%score( TEMPFILE, MY_NEW_FILE );

proc print data=MY_NEW_FILE;
run;




data SomeNewData;
input X6 X8;
datalines;
15  25
20  35
25  45
30  50
35  55
;
run; 

%SCORE(SomeNewData, NowItsScored );

proc print data=NowItsScored;
run;












