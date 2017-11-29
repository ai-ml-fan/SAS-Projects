libname mydata "/folders/myfolders/sasuser.v94" access=readonly;
%let PATH = /folders/myfolders/sasuser.v94;
%let NAME = HW;
%let LIB = &NAME..;
libname &NAME. "&PATH.";

%let INFILE = &LIB.LOGIT_INSURANCE;
%let TESTFILE=&LIB.LOGIt_INSURANCE_TEST;
%let TEMPFILE = &LIB.TEMPFILE;
%let SCRUBFILE = &LIB.SCRUBFILE;

data &TEMPFILE;
	set &INFILE.;
	drop INDEX;
	**drop TARGET_AMT;
	drop RED_CAR;
	run;

proc contents data=&INFILE.;
run;

proc print data=&TEMPFILE.(obs=7);	
run;

proc means data=&TEMPFILE. nmiss mean median;
var KIDSDRIV AGE HOMEKIDS YOJ INCOME  HOME_VAL TRAVTIME BLUEBOOK TIF OLDCLAIM CLM_FREQ  MVR_PTS CAR_AGE ;
run;

* produce default proc means descriptive statistics;
* PROC MEANS;
* examine means of continuous variables for predictive relevance to response variable;
Title "Logistic Regression EDA - Examine Means";
* examine means at min, 25th, 50th, 75th, and max percentile;
proc means data= &TEMPFILE. min p5 p10 p25 p50 p75 p90 p95  max ndec=2;
class TARGET_FLAG;
var MVR_PTS CLM_FREQ OLDCLAIM HOMEKIDS KIDSDRIV HOME_VAL INCOME AGE;
run;
* examine means at 5th, 10th, 25th, 50th, 75th, 90th, and 95th percentile;
proc means data= &TEMPFILE. min p5 p10 p25 p50 p75 p90 p95  max ndec=2;
class TARGET_FLAG;
var TIF CAR_AGE TRAVTIME YOJ ;
run;



proc means data=&TEMPFILE.  N MEAN STD MEDIAN MIN MAX RANGE SKEW KURTOSIS STDERR NMISS ;
var _numeric_;
run;



* Determine correlations between variables;
ods graphics on;
proc corr data=&INFILE. nomiss plots=scatter outp=myfile;
var KIDSDRIV 
AGE 
HOMEKIDS 
YOJ 
INCOME HOME_VAL TRAVTIME BLUEBOOK TIF OLDCLAIM CLM_FREQ MVR_PTS CAR_AGE;
with Target_Flag;
;
ods graphics on;
proc corr data=&INFILE. nomiss plots=scatter outp=myfile;
var TARGET_FLAG;
 with KIDSDRIV 
AGE 
HOMEKIDS 
YOJ 
INCOME HOME_VAL TRAVTIME BLUEBOOK TIF OLDCLAIM CLM_FREQ MVR_PTS CAR_AGE;
;

ods graphics off;
proc freq data=&INFILE.;
table car_USE/missing;
run;

proc univariate data=&INFILE. plot;
var INCOME TRAVTIME;
run;


proc freq data=&INFILE.;
table _character_ /missing;
run;


data &SCRUBFILE.;
set &TEMPFILE.;



IMP_AGE = AGE;
if missing(IMP_AGE) then IMP_AGE = 45;
IMP_INCOME = INCOME;
M_INCOME = 0;
if missing(IMP_INCOME) then do;
	IMP_INCOME = 54000;
	M_INCOME =1;
end;
IMP_HOME_VAL = HOME_VAL;
if missing(IMP_HOME_VAL) then IMP_HOME_VAL =160000;
IMP_YOJ = YOJ;
if missing(IMP_YOJ) then IMP_YOJ = 11;
IMP_CAR_AGE = CAR_AGE;
IF (IMP_CAR_AGE <=0) then IMP_CAR_AGE =1;
if missing(IMP_CAR_AGE) then IMP_CAR_AGE = 8;
IMP_JOB = JOB;
if missing(IMP_JOB) then do;
    if IMP_INCOME > 100000 then
    	IMP_JOB = "Doctor";
    else if IMP_INCOME > 80000 then
    	IMP_JOB = "Lawyer";
    else if IMP_INCOME > 50000 then
    	IMP_JOB ="z_White_Collar";
    else IMP_JOB = "z_Blue Collar";
end;   
    if IMP_INCOME > 180000 then
    	IMP_INCOME = 180000;

    JOB_WHITE_COLLAR = IMP_JOB  in ("Doctor","Lawyer","z_White_Collar");	
    BLUE_COLLAR = "No";
    if (IMP_JOB = "z_Blue Collar") then
    	BLUE_COLLAR = "Yes";
    IMP_NEW_CAR=0;
    IMP_OLD_CAR=0;
    if (IMP_CAR_AGE < 8)then IMP_NEW_CAR =1;
    else if (IMP_CAR_AGE >= 8) then IMP_OLD_CAR =1;
    IS_SPEEDER = 0;
    IS_SPEEDER = CAR_TYPE  in ("z_SUV","Pickup");
    GRADUATED = 0;
    GRADUATED = EDUCATION NOT in ( "z_High School","<High School");
  
  
    LOG10_AGE = log10(imp_age);
    LOG10_Bluebook = log10(Bluebook);
    LOG10_Car_Age = log10(IMP_CAR_AGE);
    LOG10_HOME_VAL = log10(IMP_HOME_VAL);
    LOG10_INCOME = log10(IMP_INCOME);
  drop AGE;
drop INCOME;
drop HOME_VAL;
drop YOJ;
drop CAR_AGE;
drop JOB;
drop INCOME;
drop CAR_TYPE;
drop EDUCATION;
      
run;



* examine frequencies of discretized continuous variables for predictive relavance to response variable;
Title "Logistic Regression EDA - Examine Frequencies";
proc freq data=&SCRUBFILE.;
table (IMP_NEW_CAR BLUE_COLLAR IMP_JOB)*TARGET_FLAG
/missing;
run;

proc means data=&SCRUBFILE. nmiss min mean median;
class IMP_JOB;
var IMP_INCOME;
run;

proc means data=&SCRUBFILE. nmiss min mean median;
var _NUMERIC_;
run;

proc print data =&SCRUBFILE.(obs=8);
run;

proc freq data=&SCRUBFILE.;
table (_character_) * TARGET_FLAG /missing;
run;

proc means data=&SCRUBFILE. mean median;
class TARGET_FLAG;
var _numeric_;
run;

proc univariate data=&SCRUBFILE.;
class TARGET_FLAG;
var _numeric_;
histogram;
run;
* Histograms, look for outliers and transform and compare;
*title "Histogram for '&x after LOG Transformation";
%macro HistwithXform(x,ds);
proc sgplot data=&ds.;
histogram &x.;
run;
%mend;

proc sgplot data = &SCRUBFILE.;
histogram IMP_AGE;
run;

proc sgplot data = &SCRUBFILE.;
*histogram IMP_AGE;
histogram LOG10_AGE;
run;
proc sgplot data = &SCRUBFILE.;
*histogram IMP_AGE;
histogram LOG10_INCOME;
run;
proc sgplot data = &SCRUBFILE.;
histogram IMP_INCOME;
run;
proc sgplot data = &SCRUBFILE.;
histogram IMP_HOME_VAL;
run;
proc sgplot data = &SCRUBFILE.;
*histogram IMP_AGE;
histogram LOG10_HOME_VAL;
run;
proc sgplot data = &SCRUBFILE.;
histogram IMP_CAR_AGE;
run;
proc sgplot data = &SCRUBFILE.;
*histogram IMP_AGE;
histogram LOG10_CAR_AGE;
run;
proc sgplot data = &SCRUBFILE.;
histogram BLUEBOOK;
run;
proc sgplot data = &SCRUBFILE.;
*histogram IMP_AGE;
histogram LOG10_BLUEBOOK;
run;






proc logistic data =&SCRUBFILE.;
model TARGET_FLAG(ref="0") = 
		JOB_WHITE_COLLAR
		KIDSDRIV
		HOMEKIDS
		TRAVTIME
		BLUEBOOK
		TIF
		OLDCLAIM
		CLM_FREQ
		MVR_PTS
		IMP_AGE
		IMP_INCOME
		IMP_HOME_VAL
		IMP_CAR_AGE
		/selection=forward;
		
run;
*USE LOG10 values;
proc logistics data =&SCRUBFILE. plot(only)=(roc(ID=prob));
model TARGET_FLAG(ref="0") = 
		JOB_WHITE_COLLAR
		KIDSDRIV
		HOMEKIDS
		TRAVTIME
		LOG10_BLUEBOOK
		TIF
		OLDCLAIM
		CLM_FREQ
		MVR_PTS
		LOG10_AGE
		LOG10_INCOME
		LOG10_HOME_VAL
		LOG10_CAR_AGE
		/selection=forward ;*/roceps=0.05;
		
run;





* PROC LOGISTIC;
* logistic regression to identify best predictor variables by backward selection;
Title "Logistic Regression - All Variables Backward Selection";
proc logistics data=&SCRUBFILE. plot(only)=(roc(ID=prob));
class CAR_USE SEX BLUE_COLLAR/param=ref;
model TARGET_FLAG(ref="0") =CAR_USE SEX BLUE_COLLAR MVR_PTS OLDCLAIM CLM_FREQ IMP_HOME_VAL 
TRAVTIME IMP_AGE IMP_INCOME  IMP_NEW_CAR/roceps=0.05;
run;

** ADDING NEW VARS;
proc logistics data =&SCRUBFILE. plot(only)=(roc(ID=prob));
class BLUE_COLLAR(ref="No") /param=ref;
model TARGET_FLAG(ref="0") = 
		BLUE_COLLAR
		JOB_WHITE_COLLAR
		KIDSDRIV
		TIF
		MVR_PTS
		IMP_AGE
		IMP_YOJ
		IMP_NEW_CAR
		IMP_OLD_CAR
		/roceps=0.1;
		**/selection=forward ;


run;

** Forward stepwise
proc logistics data =&SCRUBFILE. plot(only)=(roc(ID=prob));
class BLUE_COLLAR(ref="No") Revoked(ref="No") CAR_USE/param=ref;
model TARGET_FLAG(ref="0") = 
		BLUE_COLLAR
		REVOKED
		CAR_USE
		JOB_WHITE_COLLAR
		KIDSDRIV
		TIF
		MVR_PTS
		IMP_AGE
		IMP_YOJ
		IMP_NEW_CAR
		IMP_OLD_CAR
		/selection=stepwise
                     slentry=0.3
                     slstay=0.35
                     details
                     lackfit;

run;
** FAST BACKWARD 
title 'Backward Elimination on Insurance Data';
proc logistic data=&SCRUBFILE. plot(only)=(roc(ID=prob));
class IS_SPEEDER SEX PARENT1 MSTATUS BLUE_COLLAR(ref="No") GRADUATED Revoked(ref="No") CAR_USE  URBANICITY/param=ref;
      model Target_Flag= MVR_PTS IMP_AGE CLM_FREQ*OLDCLAIM CLM_FREQ IMP_YOJ TIF TRAVTIME KIDSDRIV IMP_CAR_AGE
      		        BLUEBOOK GRADUATED IMP_HOME_VAL IMP_INCOME PARENT1 BLUE_COLLAR HOMEKIDS Revoked CAR_USE SEX MSTATUS IS_SPEEDER URBANICITY
                   / selection=backward
                     fast
                     slstay=0.2
                     ctable;
   run;

** THIRD MODEL WITH PROBIT;
** FOURTH MODEL WITH GENMOD;
** FIFTH MODEL WITH LOG10;
title 'Forward Selection on Insurance Data';
proc logistic data=&SCRUBFILE. plot(only)=(roc(ID=prob));
class IS_SPEEDER SEX PARENT1 MSTATUS BLUE_COLLAR(ref="No") GRADUATED Revoked(ref="No") CAR_USE  URBANICITY/param=ref;
      model Target_Flag= MVR_PTS LOG10_AGE CLM_FREQ*OLDCLAIM CLM_FREQ IMP_YOJ TIF TRAVTIME KIDSDRIV LOG10_CAR_AGE
      		        LOG10_BLUEBOOK GRADUATED LOG10_HOME_VAL LOG10_INCOME PARENT1 BLUE_COLLAR HOMEKIDS Revoked CAR_USE SEX MSTATUS IS_SPEEDER URBANICITY
                   / selection=forward
                     ;
** DECISION TREE;
** R
** SAS MACRO ;
proc logistics data =&SCRUBFILE. plot(only)=(roc(ID=prob));
class BLUE_COLLAR(ref="No") Revoked(ref="No") CAR_USE/param=ref;
model TARGET_FLAG(ref="0") = 
		BLUE_COLLAR
		CLM_FREQ
		TRAVTIME
		oldclaim
		REVOKED
		CAR_USE
		JOB_WHITE_COLLAR
		KIDSDRIV
		TIF
		MVR_PTS
		IMP_AGE
		IMP_YOJ
		IMP_NEW_CAR
		IMP_OLD_CAR
		/roceps=0.1;
run;

***PROBIT MODEL 1;
ods graphics on;
title "Automobile Crash Model based on PROBIT"; 
proc probit data =&SCRUBFILE. plots=ALL;
class Revoked(ref="No") is_speeder sex car_use blue_collar;
model TARGET_FLAG =  KIDSDRIV TRAVTIME CLM_FREQ MVR_PTS  imp_age  Revoked  blue_collar car_use sex is_speeder imp_old_car/d =logistic;
output out=out p=Prob std=std xbeta=xbeta;


run;
%GainLift(data=out, response=TARGET_FLAG, p=Prob, event=0) title;

ods graphics off;

** PROBIT MODEL 2;
proc probit data =&SCRUBFILE. ;
class BLUE_COLLAR(ref="No") Revoked(ref="No") CAR_USE;
model TARGET_FLAG(ref="0") = 
		BLUE_COLLAR
		CLM_FREQ
		TRAVTIME
		oldclaim
		REVOKED
		CAR_USE
		JOB_WHITE_COLLAR
		KIDSDRIV
		TIF
		MVR_PTS
		IMP_AGE
		IMP_YOJ
		IMP_NEW_CAR
		IMP_OLD_CAR
		/d=logistic
		;
run;

** GENMOD model;
proc genmod data=&SCRUBFILE.;
class BLUE_COLLAR(ref="No") Revoked(ref="No") CAR_USE;
model TARGET_FLAG = BLUE_COLLAR
		CLM_FREQ
		TRAVTIME
		oldclaim
		REVOKED
		CAR_USE
		JOB_WHITE_COLLAR
		KIDSDRIV
		TIF
		MVR_PTS
		IMP_AGE
		IMP_YOJ
		IMP_NEW_CAR
		IMP_OLD_CAR
		/dist=binomial link=logit;
		estimate 'Beta' BLUE_COLLAR 1 -1/ exp;

run;

**MORE CATEGORICAL VARS;
ods graphics on;
proc logistic data=&INFILE. plots(only)=(oddsratio(range=clip));
   class red_car mstatus/param=ref;
   model Target_Flag = red_car mstatus Clm_Freq kidsdriv ;
   oddsratio red_car;
   contrast 'no vs yes' red_car 1 / estimate=exp;
   effectplot interaction(sliceby=red_car) /noobs;
   effectplot slicefit(sliceby=red_car plotby=mstatus) / noobs;
run;
ods graphics off;

ods graphics on;
proc logistic data=&SCRUBFILE. plots(only)=(oddsratio(range=clip));
   class Urbanicity Sex Revoked car_type car_use/param=ref;
   model Target_Flag = Urbanicity Sex Imp_Age revoked  mvr_pts Clm_Freq oldclaim car_type car_use;
   oddsratio Urbanicity;   
   oddsratio Sex;
   oddsratio imp_Age;
   oddsratio revoked; 
   oddsratio clm_freq; 
   oddsratio oldclaim; 
   oddsratio mvr_pts; 
   contrast 'Highly Urban/Urban vs z_Highly Rural/ Rural' Urbanicity 1 / estimate=exp;
   contrast 'No vs Yes' Revoked 1  / estimate=exp;
   contrast 'z_F vs M' Sex 1 / estimate=exp;
   effectplot interaction(sliceby=car_type plotby=car_use)/ at(Sex=all) noobs;
   effectplot slicefit(sliceby=Urbanicity plotby=sex) / noobs;
   effectplot slicefit(sliceby=Urbanicity plotby=revoked) / noobs;
run;
ods graphics off;

ods graphics on;
** 2nd Try with training data containing only crashed cars;
data TRAINFILE;
set &SCRUBFILE.;
if TARGET_AMT > 0;
run;
** Now the trainfile contains only records of crashed cars;
proc reg data =TRAINFILE ;
**** Model for predicting target amount of claims;
** proc reg data =&SCRUBFILE. ;
model TARGET_AMT = 
		bluebook
		oldclaim
		TIF
		IMP_NEW_CAR
		CLM_FREQ
		TRAVTIME/VIF
		;

run;
ods graphics off;
ods graphics on;
proc reg data =&TEMPFILE ;
**** Model for predicting target amount of claims;
** proc reg data =&SCRUBFILE. ;
model TARGET_AMT = 
		BLUEBOOK
		TIF 
		MVR_PTS
		CLM_FREQ
		OLDCLAIM
		HOME_VAL
		INCOME
		AGE		
		KIDSDRIV
		TRAVTIME/VIF
		;

run;
ods graphics off;

proc logistics data =&SCRUBFILE.;
class IMP_JOB(ref="Doctor")/param=ref;
model TARGET_FLAG(ref="0") = 
		IMP_JOB
		KIDSDRIV
		;

run;

proc logistics data =&SCRUBFILE. plot(only)=(roc(ID=prob));
class CAR_USE /param=ref;
model TARGET_FLAG(ref="0") = 
		CAR_USE
		TRAVTIME
		IMP_INCOME
		/roceps=0.1
;

run;

proc logistic data =&SCRUBFILE.;
class REVOKED(ref="No") /param= ref;
model TARGET_FLAG(ref="0") = 
		REVOKED
		KIDSDRIV
		MVR_PTS
		IMP_YOJ
		;
run;

data PATRIOTS;
**set &TEMPFILE.;
set &TESTFILE.;

**;
IMP_AGE = AGE;
if missing(IMP_AGE) then IMP_AGE = 45;
IMP_INCOME = INCOME;
M_INCOME = 0;
if missing(IMP_INCOME) then do;
	IMP_INCOME = 54000;
	M_INCOME =1;
end;
IMP_HOME_VAL = HOME_VAL;
if missing(IMP_HOME_VAL) then IMP_HOME_VAL =160000;
IMP_YOJ = YOJ;
if missing(IMP_YOJ) then IMP_YOJ = 11;
IMP_CAR_AGE = CAR_AGE;
if missing(IMP_CAR_AGE) then IMP_CAR_AGE = 8;
IMP_JOB = JOB;
if missing(IMP_JOB) then do;
    if IMP_INCOME > 100000 then
    	IMP_JOB = "Doctor";
    else if IMP_INCOME > 80000 then
    	IMP_JOB = "Lawyer";
    else if IMP_INCOME > 50000 then
    	IMP_JOB ="z_White_Collar";
    else IMP_JOB = "z_Blue Collar";
end;   
    if IMP_INCOME > 180000 then
    	IMP_INCOME = 180000;

    JOB_WHITE_COLLAR = IMP_JOB  in ("Doctor","Lawyer","z_White_Collar");	
    BLUE_COLLAR = "No";
    if (IMP_JOB = "z_Blue Collar") then
    	BLUE_COLLAR = "Yes";
    IMP_NEW_CAR=0;
    IMP_OLD_CAR=0;
    if (IMP_CAR_AGE < 8)then IMP_NEW_CAR =1;
    else if (IMP_CAR_AGE >= 8) then IMP_OLD_CAR =1;
       
**;

*YHAT = -1.2310 + 0.08886 *(REVOKED in ("Yes")) + 0.3775*KIDSDRIV +
0.2078*MVR_PTS -0.0374*IMP_YOJ;
** YHAT = 	-0.9937
		+(CAR_USE in ("Commercial")) * 0.7297
		+TRAVTIME   * 0.00552
		+IMP_INCOME * -9.08E-6
		;
        

**YHAT = -0.0815 + (BLUE_COLLAR in ("Yes")) * 0.3639  - 0.2809 * JOB_WHITE_COLLAR
	+  0.3522 * KIDSDRIV -0.0460 * TIF + 0.2047 * MVR_PTS -  0.0170 *IMP_AGE 
	- 0.0277 * IMP_YOJ + 0.0432 * IMP_NEW_CAR  -  0.2483 *IMP_OLD_CAR;
** 3rd model;
**YHAT =  -0.7969
+0.0601 * (BLUE_COLLAR in ("Yes"))
+0.3253 * CLM_FREQ
+0.00674 * TRAVTIME
-0.00001 * OLDCLAIM
+1.0226 * (REVOKED in ("Yes"))
+0.5786 * (CAR_USE in ("Commercial"))
-0.1752 * JOB_WHITE_COLLAR
+0.3460 * KIDSDRIV
-0.0453 * TIF
+0.1449 * MVR_PTS
-0.0173 * IMP_AGE
-0.0305 * IMP_YOJ
+0.0727 * IMP_NEW_CAR
-0.2470 * IMP_OLD_CAR
;
** 4th model;
*YHAT =  -0.9448+0.1773 * (BLUE_COLLAR in ("Yes"))
+0.3248 * CLM_FREQ
+0.00070 * TRAVTIME
-0.00001 * OLDCLAIM
+1.0244 * (REVOKED in ("Yes"))
+0.5153 * (CAR_USE in ("Commercial"))
-0.1792 * JOB_WHITE_COLLAR
+0.3458 * KIDSDRIV
-0.0454 * TIF
+0.1447 * MVR_PTS
-0.0176 * IMP_AGE
-0.0337 * IMP_YOJ
+0.2318 * IMP_NEW_CAR
;






** BACKWARD SELECTION;

YHAT= -0.6417+0.6370* (CAR_USE in ("Commercial"))
-0.2057*(sex in ("M"))
-0.2006 * (BLUE_COLLAR in ("No"))
+0.1397*MVR_PTS
+6.75E-6*OLDCLAIM
+0.2513*CLM_FREQ
-2.52E-6*IMP_HOME_VAL
+0.00612*TRAVTIME
-0.0130*IMP_AGE
-4.19E-6*IMP_INCOME
+0.0801*IMP_NEW_CAR
;
**YHAT = exp(YHAT);
**if missing (YHAT) then YHAT=99999;
**PROB = YHAT/(1+YHAT);
**P_TARGET_FLAG = PROB;

** PROBIT REGRESSION;
**YHAT =  -0.5092
+0.0375 * (BLUE_COLLAR in ("Yes"))
+0.1950 * CLM_FREQ
+0.00397 * TRAVTIME
-7.9E-6 * OLDCLAIM
+0.6070 * (REVOKED in ("Yes"))
+0.3363 * (CAR_USE in ("Commercial"))
-0.0976 * JOB_WHITE_COLLAR
+0.2076 * KIDSDRIV
-0.0267 * TIF
+0.0857 * MVR_PTS
-0.00977 * IMP_AGE
-0.0177 * IMP_YOJ
+0.0425 * IMP_NEW_CAR
-0.1452 * IMP_OLD_CAR
;

P_TARGET_FLAG = probnorm(YHAT);
**P_TARGET_AMT = 870.11052 + 0.00435 * BLUEBOOK - 
		0.00900* OLDCLAIM
		-49.72892* TIF
		+466.45555 * IMP_NEW_CAR
		+434.16721 * CLM_FREQ
		+ 7.56937* TRAVTIME;
		
**P_TARGET = 3768.85639 + 0.11532 * BLUEBOOK - 
		0.00357 * OLDCLAIM
		-11.86949* TIF
		+572.08378 * IMP_NEW_CAR
		+42.85782 * CLM_FREQ
		+ 1.13669 * TRAVTIME;

**P_TARGET_AMT= P_TARGET * P_TARGET_FLAG;

keep INDEX P_TARGET_FLAG;
**keep INDEX P_TARGET_AMT;

run;




*****SCORING PROBIT and GENMOD ;
data Probnorm;
**set &TEMPFILE.;
set &TESTFILE.;

IMP_YOJ=YOJ;
if missing(IMP_YOJ) then IMP_YOJ =11;
IMP_INCOME = INCOME;
M_INCOME = 0;
if missing(IMP_INCOME) then do;
	IMP_INCOME = 54000;
	M_INCOME =1;
end;

    IMP_JOB = JOB;
    if missing(IMP_JOB) then do;
    	if IMP_INCOME > 100000 then
    		IMP_JOB = "Doctor";
    	else if IMP_INCOME > 80000 then
    		IMP_JOB = "Lawyer";
    	else
    		IMP_JOB = "z_Blue_Collar";
    end;
    IMP_AGE = AGE;
    if missing(IMP_AGE) then IMP_AGE = 45;

    IMP_CAR_AGE = CAR_AGE;
    if missing(IMP_CAR_AGE) then IMP_CAR_AGE = 8;
    JOB_WHITE_COLLAR = IMP_JOB  in ("Doctor","Lawyer");	
    BLUE_COLLAR = "No";
    if (IMP_JOB = "z_Blue_Collar") then
    	BLUE_COLLAR = "Yes";
    IMP_NEW_CAR=0;
    IMP_OLD_CAR=0;
    if (IMP_CAR_AGE < 8)then IMP_NEW_CAR =1;
    else if (IMP_CAR_AGE > 8) then IMP_OLD_CAR =1;
    
YHAT =  -0.7969
+0.0601 * (BLUE_COLLAR in ("Yes"))
+0.3253 * CLM_FREQ
+0.00674 * TRAVTIME
-0.00001 * OLDCLAIM
+1.0226 * (REVOKED in ("Yes"))
+0.5786 * (CAR_USE in ("Commercial"))
-0.1752 * JOB_WHITE_COLLAR
+0.3460 * KIDSDRIV
-0.0453 * TIF
+0.1449 * MVR_PTS
-0.0173 * IMP_AGE
-0.0305 * IMP_YOJ
+0.0727 * IMP_NEW_CAR
-0.2470 * IMP_OLD_CAR
;

YHAT = exp(YHAT);
if missing (YHAT) then YHAT=99999;
PROB = YHAT/(1+YHAT);
P_TARGET_FLAG = PROB;

** PROBIT REGRESSION;
**YHAT_PROBIT =  -0.7968
+0.0601* (BLUE_COLLAR in ("Yes"))
+0.3253 * CLM_FREQ
+0.0067 * TRAVTIME
+1.0226 * (REVOKED in ("Yes"))
+0.5786 * (CAR_USE in ("Commercial"))
-0.1752 * JOB_WHITE_COLLAR
+0.3460 * KIDSDRIV
-0.0453 * TIF
+0.1449 * MVR_PTS
-0.0173 * IMP_AGE
-0.0305 * IMP_YOJ
+0.0727 * IMP_NEW_CAR
-0.2470 * IMP_OLD_CAR
;




**P_TARGET_FLAG = probnorm(YHAT_PROBIT);
**P_TARGET_AMT = 870.11052 + 0.00435 * BLUEBOOK - 
		0.00900* OLDCLAIM
		-49.72892* TIF
		+466.45555 * IMP_NEW_CAR
		+434.16721 * CLM_FREQ
		+ 7.56937* TRAVTIME;
		
P_TARGET = 3768.85639 + 0.11532 * BLUEBOOK - 
		0.00357 * OLDCLAIM
		-11.86949* TIF
		+572.08378 * IMP_NEW_CAR
		+42.85782 * CLM_FREQ
		+ 1.13669 * TRAVTIME;

P_TARGET_AMT= P_TARGET * P_TARGET_FLAG;

keep INDEX P_TARGET_FLAG;
**keep INDEX P_TARGET_AMT;

run;

**PROC GLM;
data genmod;
**set &TEMPFILE.;
set &TESTFILE.;

IMP_YOJ=YOJ;
if missing(IMP_YOJ) then IMP_YOJ =11;
IMP_INCOME = INCOME;
M_INCOME = 0;
if missing(IMP_INCOME) then do;
	IMP_INCOME = 54000;
	M_INCOME =1;
end;

    IMP_JOB = JOB;
    if missing(IMP_JOB) then do;
    	if IMP_INCOME > 100000 then
    		IMP_JOB = "Doctor";
    	else if IMP_INCOME > 80000 then
    		IMP_JOB = "Lawyer";
    	else
    		IMP_JOB = "z_Blue_Collar";
    end;
    IMP_AGE = AGE;
    if missing(IMP_AGE) then IMP_AGE = 45;

    IMP_CAR_AGE = CAR_AGE;
    if missing(IMP_CAR_AGE) then IMP_CAR_AGE = 8;
    JOB_WHITE_COLLAR = IMP_JOB  in ("Doctor","Lawyer");	
    BLUE_COLLAR = "No";
    if (IMP_JOB = "z_Blue_Collar") then
    	BLUE_COLLAR = "Yes";
    IMP_NEW_CAR=0;
    IMP_OLD_CAR=0;
    if (IMP_CAR_AGE < 8)then IMP_NEW_CAR =1;
    else if (IMP_CAR_AGE > 8) then IMP_OLD_CAR =1;


** GENMOD REGRESSION;
YHAT_genmod =  0.7968
-0.0601* (BLUE_COLLAR in ("Yes"))
-0.3253 * CLM_FREQ
-0.0067 * TRAVTIME
-1.0226 * (REVOKED in ("Yes"))
-0.5786 * (CAR_USE in ("Commercial"))
+0.1752 * JOB_WHITE_COLLAR
-0.3460 * KIDSDRIV
+0.0453 * TIF
-0.1449 * MVR_PTS
+0.0173 * IMP_AGE
+0.0305 * IMP_YOJ
-0.0727 * IMP_NEW_CAR
+0.2470 * IMP_OLD_CAR
;




P_TARGET_FLAG = probnorm(YHAT_genmod);
**P_TARGET_AMT = 870.11052 + 0.00435 * BLUEBOOK - 
		0.00900* OLDCLAIM
		-49.72892* TIF
		+466.45555 * IMP_NEW_CAR
		+434.16721 * CLM_FREQ
		+ 7.56937* TRAVTIME;
		
P_TARGET = 3768.85639 + 0.11532 * BLUEBOOK - 
		0.00357 * OLDCLAIM
		-11.86949* TIF
		+572.08378 * IMP_NEW_CAR
		+42.85782 * CLM_FREQ
		+ 1.13669 * TRAVTIME;

P_TARGET_AMT= P_TARGET * P_TARGET_FLAG;

keep INDEX P_TARGET_FLAG;
**keep INDEX P_TARGET_AMT;

run;

****;

proc print data =PATRIOTS(obs=10);
var YHAT;
run;

data CRASHED;
set &INFILE;
if TARGET_FLAG > 0;
drop TARGET_FLAG;
run;

proc print data = CRASHED(obs=10);
run;

proc means data =PATRIOTS nmiss;
var YHAT;
run;

score out=SCORED_FILE;
run;

data DEPLOYFILE;
set &INFILE.;

IMP_INCOME = INCOME;
if missing(IMP_INCOME) then IMP_INCOME = 62000;

YHAT = 	-1.0177
		+(CAR_USE in ("Commercial")) * 0.7278
		+TRAVTIME   * 0.00555
		+IMP_INCOME * -8.5E-6
		;

if YHAT > 999  then YHAT = 999;
if YHAT < -999 then YHAT = -999;

P_TARGET_FLAG = exp( YHAT ) / ( 1+exp( YHAT ));

**P_TARGET_AMT = 	4131.65436
				+BLUEBOOK*0.11017
				;
P_TARGET_AMT = 870.11052 + 0.00435 * BLUEBOOK - 
		0.00900* OLDCLAIM
		-49.72892* TIF
		+466.45555 * IMP_NEW_CAR
		+434.16721 * CLM_FREQ
		+ 7.56937* TRAVTIME


PURE_PREMIUM = P_TARGET_FLAG*P_TARGET_AMT;

run;

%score(&TESTFILE.,SCOREHW2);



*%scoreamount(&TESTFILE.,HW2AMOUNTFILE);
*%SCOREAMOUNTFINAL(&TESTFILE.,HW2finaLAMOUNTFILE);