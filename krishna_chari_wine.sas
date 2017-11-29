** PART 1:EDA;
libname mydata "/folders/myfolders/sasuser.v94" access=readonly;
%let PATH = /home/krishnaprabhacha0/sasuser.v94;
%let NAME = HW;
%let LIB = &NAME..;
libname &NAME. "&PATH.";
%let INPUTFILE = &LIB.wine;
%let INFILE = TEMPFILE;
%let FIXFILE=FIXFILE;
%let SWAPFILE=SWAPFILE;
%let TESTFILE=&LIB.wine_test;
%let OUTFILE=outfile;


data &INFILE.;
set &INPUTFILE.;
run;
* List out the column names and data types for the data set;
proc contents data=&INFILE.; run; quit;

* Print out the first 10 observations on the data set;
proc print data=&INFILE.(obs=10);
run;

* produce default proc means descriptive statistics;
Title "PROC MEANS EDA - Examine Variable Descriptive Statistics";
proc means data=&INPUTFILE.  NMISS N MEAN STD MEDIAN MIN MAX RANGE SKEW KURTOSIS STDERR  P1 P5 P95 P99;
var _NUMERIC_;

**class TARGET_FLAG;

proc freq data =&INFILE;
tables target;
run;
proc freq data =&INFILE;
table STARS*TARGET/missing;
run;

proc gchart data=&INFILE. ;
vbar TARGET;
run;
proc univariate data = &INFILE. noprint;
var TARGET;
histogram ;
run;
* Numeric Exploration:Use after creating the target_flag and Target_amt columns;
%macro sgp(pred,source);
title "TARGET_FLAG vs" &pred.;
proc freq data =&source.;
table TARGET_FLAG*&pred./missing;
run;
%mend;

%macro sgp1(pred,source);
title "TARGET vs" &pred.;
proc sgplot data =&source.;
reg x=&pred. y=TARGET;
run;
%mend;

%macro sgp2(pred,source);
title "TARGET AMOUNT vs" &pred.;
proc sgplot data =&source.;
reg x=&pred. y=TARGET_AMT;
run;

proc univariate data=&source. plot;
var &pred.;
run;

title &pred.;
proc gchart data=&source.;
vbar &pred./nozero;
run;
%mend;


*Check correlation between alcohol content and cases purchased;
** Determine correlation;


** Wine rating and cases purchased;
ods graphics on;
title 'Cass purchased vs. Alcohol Data';
proc corr data=&INFILE. nomiss plots=matrix(histogram);
   var Target_Amt M_Stars ;
 run;
ods graphics off;


 

data &INFILE.;
set &INPUTFILE.;
TARGET_FLAG = (TARGET >0);
TARGET_AMT = TARGET-1;
if TARGET_FLAG =0 then TARGET_AMT = .;

IMP_DENSITY = DENSITY;
IF missing(imp_density) then imp_density = 0.9942927;

IMP_STARS = STARS;
M_STARS = 0;
IF missing(IMP_STARS ) then do; IMP_STARS =0;M_STARS =1; end;
IMP_Sulphates=Sulphates;
IF missing(Sulphates) then IMP_Sulphates=0.5271118;
imp_Alcohol=Alcohol;
IF missing(Alcohol) then imp_Alcohol=10.4892363;
imp_labelAppeal=labelAppeal;
imp_totalsulfurdioxide=totalsulfurdioxide;

IF missing(labelAppeal) then imp_labelAppeal=-0.009066;
IF missing(totalsulfurdioxide) then imp_totalsulfurdioxide=120.7142326;
**IMP_TotalSulfurdioxide = sign(IMP_TOTALSULFURDIOXIDE) * log(abs(IMP_SULFURDIOXIDE)+1);
if IMP_totalSulfurdioxide < -330 then IMP_TOTALSulfurdioxide=-330;
if IMP_totalSulfurdioxide > 630 then IMP_TOTALSulfurdioxide=630;

imp_ResidualSugar=ResidualSugar;
if missing(ResidualSugar) then imp_ResidualSugar=5.4187331;
imp_ph = ph;
if missing(ph) then imp_ph = 3.2076282;
imp_freesulfurdioxide=freesulfurdioxide;
if missing(freesulfurdioxide) then imp_freesulfurdioxide = 30.4455713;
imp_chlorides = chlorides;
if missing(chlorides) then imp_chlorides=0.0548225;

if imp_Alcohol > 15.1 then al_bin=10;
   
   else if imp_Alcohol > 12.8 then al_bin=9;
   else if imp_Alcohol > 11.7 then al_bin=8;
   else if imp_Alcohol > 10.9 then al_bin=7;
   else if imp_Alcohol > 10.49 then al_bin=6;
   else if imp_Alcohol > 9.9 then al_bin=5;
   else if imp_Alcohol > 9.4 then al_bin=4;
   else if imp_Alcohol > 8.7 then al_bin=3;
   else if imp_Alcohol > 5.9 then al_bin=2;
   else al_bin=1;
   
	   
   if imp_Density > 1.029 then density_bin=10;
   else if imp_Density > 1.009 then density_bin=9;
   else if imp_Density > 0.998 then density_bin=8;
   else if imp_Density > 0.996 then density_bin=7;
   else if imp_Density > 0.994 then density_bin=6;
   else if imp_Density > 0.993 then density_bin=5;
   else if imp_Density > 0.990 then density_bin=4;
   else if imp_Density > 0.978 then density_bin=3;
   else if imp_Density > 0.959 then density_bin=2;
   else density_bin=1;
   
	   
   if FixedAcidity > 15.6 then FixedA_bin=10;
   else if FixedAcidity > 11.1 then FixedA_bin=9;
   else if FixedAcidity > 8.4 then FixedA_bin=8;
   else if FixedAcidity > 7.4 then FixedA_bin=7;
   else if FixedAcidity > 6.9 then FixedA_bin=6;
   else if FixedAcidity > 6.5 then FixedA_bin=5;
   else if FixedAcidity > 5.9 then FixedA_bin=4;
   else if FixedAcidity > 3 then FixedA_bin=3;
   else if FixedAcidity > -1.2 then FixedA_bin=2;
   else FixedA_bin=1;
    
   if imp_FreeSulfurDioxide > 223 then SulfurDioxide_bin=10;
   else if imp_FreeSulfurDioxide > 106.5 then SulfurDioxide_bin=9;
   else if imp_FreeSulfurDioxide > 52 then SulfurDioxide_bin=8;
   else if imp_FreeSulfurDioxide > 38 then SulfurDioxide_bin=7;
   else if imp_FreeSulfurDioxide > 30.4 then SulfurDioxide_bin=6;
   else if imp_FreeSulfurDioxide > 23 then SulfurDioxide_bin=5;
   else if imp_FreeSulfurDioxide > 12 then SulfurDioxide_bin=4;
   else if imp_FreeSulfurDioxide > -44 then SulfurDioxide_bin=3;
   else if imp_FreeSulfurDioxide > -165 then SulfurDioxide_bin=2;
   else SulfurDioxide_bin=1;
   
drop index;
drop stars;
drop density;
drop totalSulfurdioxide;
drop Alcohol;
drop labelAppeal;
drop Sulphates;
drop ResidualSugar;
drop ph;
drop freesulfurdioxide;
drop chlorides;


run;
%sgp(imp_alcohol,&INFILE.);*Bucket it to show range;
%sgp(imp_stars,&INFILE.);
%sgp(imp_LabelAppeal,&INFILE.);*all values show 30/70 for target 0/1;
%sgp(AcidIndex,&INFILE.);
%sgp(imp_Chlorides,&INFILE.);*No effect;
%sgp(CitricAcid,&INFILE.);*Buckets;
%sgp(imp_Density,&INFILE.);*Buckets;
%sgp(FixedAcidity,&INFILE.);*Bucket it to show range;
%sgp(imp_FreeSulfurDioxide,&INFILE.);*Bucket it to show range;
%sgp(imp_ph,&INFILE.);*No effect;
%sgp(imp_ResidualSugar,&INFILE.);*No effect;
%sgp(imp_Sulphates,&INFILE.);*Normal dist with max between -1.27-2.2);
%sgp(VolatileAcidity,&INFILE.);
%sgp(imp_TotalSulfurDioxide,&INFILE.);

proc means data=&INFILE. nmiss min mean median MIN MAX;
class TARGET_FLAG; 
var _NUMERIC_;
run;

proc corr data=&INFILE. plots=scatter outp=myfile;
var imp_labelAppeal
imp_alcohol
imp_stars
with Target_Amt;
;
proc univariate data=&INFILE. ;
var imp_Alcohol;
output out=getpercentiles pctlpre=P_ pctlpts=10 to 100 by 10;
run;
data &FIXFILE.;
set &INFILE.;
     
	if _n_ =1 then set getpercentiles;
	   
   if imp_Alcohol > P_90 then al_bin=10;
   else if imp_Alcohol > P_80 then al_bin=9;
   else if imp_Alcohol > P_70 then al_bin=8;
   else if imp_Alcohol > P_60 then al_bin=7;
   else if imp_Alcohol > P_50 then al_bin=6;
   else if imp_Alcohol > P_40 then al_bin=5;
   else if imp_Alcohol > P_30 then al_bin=4;
   else if imp_Alcohol > P_20 then al_bin=3;
   else if imp_Alcohol > P_10 then al_bin=2;
   else al_bin=1;
   drop P_:;
run;
proc univariate data=&INFILE. ;
var imp_Density;
output out=getpercentiles pctlpre=P_ pctlpts=10 to 100 by 10;
run;
data &FIXFILE.;
set &INFILE.;
     
	if _n_ =1 then set getpercentiles;
	   
   if imp_Density > P_90 then density_bin=10;
   else if imp_Density > P_80 then density_bin=9;
   else if imp_Density > P_70 then density_bin=8;
   else if imp_Density > P_60 then density_bin=7;
   else if imp_Density > P_50 then density_bin=6;
   else if imp_Density > P_40 then density_bin=5;
   else if imp_Density > P_30 then density_bin=4;
   else if imp_Density > P_20 then density_bin=3;
   else if imp_Density > P_10 then density_bin=2;
   else density_bin=1;
   drop P_:;
run;
%sgp(density_bin,&FIXFILE.);*Bucket it to show range;
%sgp1(al_bin,&FIXFILE.);*Bucket it to show range;
%sgp2(al_bin,&FIXFILE.);*Bucket it to show range;
%sgp1(density_bin,&FIXFILE.);*Bucket it to show range;
%sgp2(density_bin,&FIXFILE.);*Bucket it to show range;

ods graphics on;
title 'Cass purchased vs. Alcohol Data';
proc corr data=&FIXFILE. nomiss plots=matrix(histogram);
   var Target_Amt M_Stars ;
 run;
ods graphics off;

proc corr data=&FIXFILE. plots=scatter outp=myfile;
var density_bin
al_bin
with Target_Amt;
;

proc freq data =&INFILE.;
 table target_flag /missing;
run;

proc print data =&INFILE.(obs=20);
 var target target_flag target_amt;
run;

proc univariate data = &INFILE. plot;
histogram TARGET TARGET_AMT;
run;
proc univariate data = &INFILE. plot;
histogram TOTALSULFURDIOXIDE;
run;

proc freq data =&INFILE.;
table STARS*TARGET/missing;
run;
ods graphics on;
title 'Measures of Association for a Physical Fitness Study';
proc corr data=&INFILE. pearson spearman kendall hoeffding
          plots=matrix(histogram);
   var Target_Amt Imp_Density imp_ResidualSugar imp_Chlorides imp_FreeSulfurdioxide imp_ph VolatileAcidity CitricAcid imp_Alcohol imp_Sulphates imp_labelAppeal imp_totalsulfurdioxide;
run;
ods graphics off;

***	BUILD MODELS (40 Points)

Build at least five different using the SAS procs: PROC GENMOD and PROC REG. The five models will be:
•	GENMOD with Poisson distribution
•	GENMOD with Negative Binomial distribution
•	GENMOD with Zero Inflated Poisson distribution
•	GENMOD with Zero Inflated Negative Binomial distribution
•	REGRESSION (use standard PROC REG and if you wish you may use a variable selection method)

Sometimes Poisson and Negative Binomial models give the same results. If that is the case, comment on that. Consider changing the input variables if that occurs so that you get different models.

You may select the variables manually, use an approach such as Forward or Stepwise, 
use a different approach such as trees, or use a combination of techniques.
Describe the techniques you used. If you manually selected a variable for 
inclusion into the model or exclusion into the model, indicate why this was done.;
* GENMOD with Poisson distribution;
*GENMOD WITH POISSON;
data &FIXFILE.;
set &INFILE.;
run;
proc genmod data=&FIXFILE.;
model TARGET= IMP_STARS AcidIndex FixedAcidity IMP_Density 
              IMP_Alcohol IMP_LabelAppeal  M_STARS/link=log dist=poi;
       output out =&FIXFILE. p=X_GENMOD_POI;
run;
proc print data=&FIXFILE.(obs=10);
var TARGET X_GENMOD_POI;
run;

data scorefile;
set &FIXFILE;
             
       P_GENMOD_POI = 1.7345 + IMP_STARS *(0.1889) + AcidIndex *(-0.0816) +
       FixedAcidity *(-0.0001) + IMP_Density *(-0.2753) +
	   IMP_ALCOHOL * (0.0033)+ IMP_LABELAPPEAL* (0.1590) + M_Stars *(-0.6518); 
P_GENMOD_POI=exp(P_GENMOD_POI);        

run;


proc print data=scorefile(obs=10);
var TARGET X_GENMOD_POI P_GENMOD_POI;
run;

%SCORE(&TESTFILE.,&OUTFILE.);


* MODEL WITH STANDARD REGRESSION;

proc reg data=&FIXFILE.;
model TARGET= IMP_STARS AcidIndex FixedAcidity VolatileAcidity CitricAcid IMP_ALCOHOL IMP_SULPHATES
             IMP_LABELAPPEAL IMP_TOTALSULFURDIOXIDE M_STARS 
             IMP_DENSITY IMP_RESIDUALSUGAR/selection=stepwise;
    output out=&FIXFILE. pred=X_REGRESSION;
run;

proc print data=&FIXFILE.(obs=10);
var TARGET X_REGRESSION;
run;

data scorefile;
set &FIXFILE;
P_REGRESSION = 4.31316 + IMP_STARS *(0.77928) + AcidIndex *(-0.20055) + 
               VolatileAcidity * (-0.09682) + IMP_Alcohol*(0.01244) + 
                IMP_SULPHATES *(-0.03045) +
                IMP_LabelAppeal *(0.46613) + IMP_TotalSulfurdioxide *(0.00024906) +
               M_STARS * (-0.69066 )+ IMP_DENSITY * (-0.83132) ;
run;

proc print data=scorefile(obs=10);
var TARGET X_REGRESSION P_REGRESSION;
run;

%SCORE(&TESTFILE.,&OUTFILE.);
*****;
*	GENMOD with Negative Binomial distribution;
proc genmod data =&FIXFILE.;
model TARGET= IMP_STARS IMP_Density IMP_Sulphates AcidIndex VolatileAcidity 
              imp_ph IMP_Alcohol IMP_LabelAppeal Imp_Chlorides
              IMP_FreeSulfurdioxide IMP_TOTALSULFURDIOXIDE M_STARS/link=log dist=nb;
       output out =&FIXFILE. p=X_GENMOD_NB;
run;
proc print data=&FIXFILE.(obs=10);
var TARGET X_GENMOD_NB;
run;

data scorefile;
set &FIXFILE;
             
       P_GENMOD_NB = 1.7740 + IMP_STARS *(0.1879) + IMP_Density *(-0.2789) +
       IMP_SULPHATES * (-0.0118) + AcidIndex *(-0.0805) +
       VolatileAcidity *(-0.0311) + imp_ph * (-0.0129) +
       IMP_ALCOHOL * (0.0035)+ IMP_LABELAPPEAL* (0.1589) +
       imp_chlorides * (-0.0369) + IMP_FreeSulfurdioxide  *(-0.0001) +
       IMP_TOTALSULFURDIOXIDE *(-0.0001) + M_Stars *(-0.6476); 
       P_GENMOD_NB=exp(P_GENMOD_NB);        

run;


proc print data=scorefile(obs=10);
var TARGET X_GENMOD_NB P_GENMOD_NB;
run;

%SCORE(&TESTFILE.,&OUTFILE.);

*****;
* GENMOD with Zero Inflated Poisson(ZIP) distribution;(NOBINS);



proc genmod data=&FIXFILE.;
model TARGET= FixedAcidity imp_FreeSulfurDioxide imp_Density imp_Alcohol 
              AcidIndex
             IMP_LabelAppeal IMP_STARS VolatileAcidity
             imp_Chlorides imp_pH imp_sulphates/dist=zip link=log ;
              zeromodel FixedAcidity imp_FreeSulfurDioxide imp_Density M_STARS IMP_STARS  IMP_LABELAPPEAL  / link=logit;
       output out=&FIXFILE. pred=X_GENMOD_ZIP pzero=X_GENMOD_PZERO;

run;


data scorefile;
set &FIXFILE;

P_GENMOD_ZIP = 1.5280 + 
				FixedAcidity  *(0.0006)+ 
				imp_FreeSulfurDioxide  *(0.0000 ) + 
				imp_Density *(-0.2522 ) +
				imp_Alcohol  *(0.0065 )+
				AcidIndex *(-0.0322 ) +
				imp_labelAppeal *(0.2339 )+
				IMP_STARS *(0.1006 ) +
				VolatileAcidity *(-0.0156) + 
				imp_chlorides *( -0.0254)+
				imp_ph*(0.0016)+
				IMP_Sulphates * (-0.0025);

P_GENMOD_ZIP =exp(P_GENMOD_ZIP);

P_GENMOD_PZERO = 1.1709 + FixedAcidity *(0.0202)+ 
                 imp_FreeSulfurDioxide *(-0.0009)+ imp_Density *(1.1709)
                 + M_STARS*(-2.0209) + IMP_STARS*(-4.0943)
                 + imp_labelAppeal*(0.7562);


if P_GENMOD_PZERO  > 1000 then P_GENMOD_PZERO  =1000;
if P_GENMOD_PZERO  <= -1000 then P_GENMOD_PZERO  =-1000;
P_GENMOD_PZERO = exp(P_GENMOD_PZERO)/1+exp(P_GENMOD_PZERO);
P_SCORE_ZIP=P_GENMOD_ZIP *(1 - P_GENMOD_PZERO);

run;
proc print data=scorefile(obs=10);
var TARGET  P_SCORE_ZIP;
run;

%SCORE(&TESTFILE.,&OUTFILE.);

*****;
ZIP: with Bins;
*WITH BINS after NON-BINS;

*data &FIXFILE.;
*set &INFILE.;
*run;
proc genmod data=&FIXFILE.;
model TARGET= FIXEDA_BIN SulfurDioxide_bin density_bin al_bin 
              AcidIndex
             IMP_LabelAppeal IMP_STARS VolatileAcidity
             imp_Chlorides imp_pH imp_sulphates/dist=zip link=log ;
              zeromodel FIXEDA_BIN SulfurDioxide_bin density_bin M_STARS IMP_STARS  IMP_LABELAPPEAL  / link=logit;
       output out=&FIXFILE. pred=X_GENMOD_ZIP pzero=X_GENMOD_PZERO;

run;
proc print data=&FIXFILE.(obs=10);
var TARGET X_GENMOD_ZIP;
run;

data scorefile;
set &FIXFILE;
P_GENMOD_ZIP = 1.2763 + 
				FixedA_bin  *(0.0022)+ 
				SulfurDioxide_bin *(0.0026 ) + 
				density_bin *(-0.0045 ) +
				al_bin *(0.0110 )+
				AcidIndex *(-0.0301 ) +
				imp_labelAppeal *(0.2340 )+
				IMP_STARS *(0.0990 ) +
				VolatileAcidity *(-0.0152) + 
				imp_chlorides *( -0.0240)+
				imp_ph*(0.0017)+
				IMP_Sulphates * (-0.0025);

P_GENMOD_ZIP =exp(P_GENMOD_ZIP);

P_GENMOD_PZERO = 2.3178 + FixedA_bin *(0.0689)+ 
                 SulfurDioxide_bin *(-0.0749)+ density_bin*(0.0284)
                 + M_STARS*(-2.0199) + IMP_STARS*(-4.0855)
                 + imp_labelAppeal*(0.7580);



if P_GENMOD_PZERO  > 1000 then P_GENMOD_PZERO  =1000;
if P_GENMOD_PZERO  <= -1000 then P_GENMOD_PZERO  =-1000;
P_GENMOD_PZERO = exp(P_GENMOD_PZERO)/1+exp(P_GENMOD_PZERO);
P_SCORE_ZIP=P_GENMOD_ZIP *(1 - P_GENMOD_PZERO);

run;

proc print data=SCoreFile(obs=10);
var TARGET TARGET_FLAG TARGET_AMT  P_SCORE_ZIP;

run;

%SCORE(&TESTFILE.,&OUTFILE.);
********;
ZINB :Zero Inflated Negative Binomial
*PROC GENMOD ;



proc genmod data =&FIXFILE.;
title "Model:Zero Inflated Negative Binomial Regression";
model TARGET= IMP_Alcohol M_STARS IMP_FreeSulfurdioxide 
              IMP_Density VolatileAcidity AcidIndex FixedAcidity IMP_Sulphates
                IMP_LabelAppeal 
              IMP_TotalSulfurdioxide IMP_STARS/link=log dist=zinb;
              zeromodel FixedAcidity imp_FreeSulfurDioxide imp_Density 
                        IMP_Alcohol M_STARS IMP_STARS  IMP_LABELAPPEAL  / link=logit;
       output out=&FIXFILE. pred=X_GENMOD_ZINB pzero=X_ZERO_ZINB;
       
run;
proc print data=&FIXFile.(obs=10);
var TARGET X_GENMOD_ZINB;

data scorefile;
set &FIXFILE;

P_GENMOD_ZINB = 1.5280 + IMP_Alcohol M_STARS IMP_FreeSulfurdioxide 
              IMP_Density VolatileAcidity AcidIndex FixedAcidity IMP_Sulphates
                IMP_LabelAppeal 
              IMP_TotalSulfurdioxide;
				FixedAcidity  *(0.0006)+ 
				imp_FreeSulfurDioxide  *(0.0000 ) + 
				imp_Density *(-0.2522 ) +
				imp_Alcohol  *(0.0065 )+
				AcidIndex *(-0.0322 ) +
				imp_labelAppeal *(0.2339 )+
				IMP_STARS *(0.1006 ) +
				VolatileAcidity *(-0.0156) + 
				imp_chlorides *( -0.0254)+
				imp_ph*(0.0016)+
				IMP_Sulphates * (-0.0025);

P_GENMOD_ZINB =exp(P_GENMOD_ZINB);

P_ZERO_ZINB = 1.1709 + FixedAcidity *(0.0202)+ 
                 imp_FreeSulfurDioxide *(-0.0009)+ imp_Density *(1.1709)
                 + M_STARS*(-2.0209) + IMP_STARS*(-4.0943)
                 + imp_labelAppeal*(0.7562);

P_ZERO_ZINB = exp(P_GENMOD_PZERO)/1+exp(P_GENMOD_PZERO);
P_SCORE_ZIP=P_GENMOD_ZIP *(1 - P_GENMOD_PZERO);

if P_GENMOD_PZERO  > 1000 then P_GENMOD_PZERO  =1000;
if P_GENMOD_PZERO  <= -1000 then P_GENMOD_PZERO  =-1000;
P_GENMOD_PZERO = exp(P_GENMOD_PZERO)/1+exp(P_GENMOD_PZERO);
P_SCORE_ZIP=P_GENMOD_ZIP *(1 - P_GENMOD_PZERO);

run;

proc print data=&FIXFILE.(obs=10);
var TARGET  X-GENMOD_ZINB 
run;

*******
*Print Results;


******;

* PROC LOGISTIC ; 
* PROC LOGISTIC ; 
proc logistic data=&FIXFILE.;
model TARGET_FLAG(ref="0") = IMP_STARS IMP_LabelAppeal M_STARS;
output out=&FIXFILE. p=X_LOGIT_PROB;
run;
proc print data=&FIXFILE.(obs=10);
var TARGET_FLAG X_LOGIT_PROB ;

run;
data scorefile;
set &FIXFILE;
P_LOGIT_PROB = -1.2899 + IMP_STARS *(2.5806)+ 
                 IMP_LABELAPPEAL *(-0.4906)+ M_STARS*(-4.4074);
*CAP P_LOGIT as we are going to exp it the next step
if P_LOGIT_PROB > 1000 then P_LOGIT_PROB =1000;
if P_LOGIT_PROB <= -1000 then P_LOGIT_PROB =-1000;
P_LOGIT_PROB =exp(P_LOGIT_PROB)/(1+exp(P_LOGIT_PROB));
run;


%SCORE(&TESTFILE.,&OUTFILE.);
proc print data=scorefile(obs=10);
var TARGET X_LOGIT_PROB P_LOGIT_PROB;

run;
****************;


* PROC GENMOD;

proc genmod data =&FIXFILE.;
model TARGET= IMP_STARS IMP_Density IMP_Sulphates
              IMP_Alcohol IMP_LabelAppeal IMP_TotalSulfurdioxide M_STARS/link=log dist=nb;
       output out =&FIXFILE. p=X_GENMOD_NB;
run;
proc print data=&FIXFILE.(obs=10);
var TARGET X_GENMOD-Nb;
run;
data scorefile;
set &FIXFILE;
P_REGRESSION = 3.06747 + IMP_STARS *(0.81011) +
               IMP_DENSITY * (-1.23532) + IMP_SULPHATES *(-0.038521) +
               IMP_Alcohol*(0.01437) + IMP_LabelAppeal *(0.44668) + IMP_TotalSulfurdioxide *(0.00031312) +
               M_STARS * (-0.74118);*M_STARS *(-2.36139);
               
P_GENMOD_NB = 1.2363 + IMP_STARS *(0.1980) + IMP_Density *(-0.4374) +
	IMP_Sulphates *(-0.0134) + IMP_ALCOHOL * (0.0046)+ IMP_LABELAPPEAL* (0.1536) + IMP_TotalSulfurdioxide *(0.0001) +
	M_Stars *(-0.6704); *M_Stars *(-1.0665);
P_GENMOD_NB=exp(P_GENMOD_NB);

P_LOGIT_PROB = -1.2899 + IMP_STARS *(2.5806)+ IMP_LABELAPPEAL *(-0.4906)+ M_STARS*(-4.4074);
*CAP P_LOGIT as we are going to exp it the next step
if P_LOGIT_PROB > 1000 then P_LOGIT_PROB =1000;
if P_LOGIT_PROB <= -1000 then P_LOGIT_PROB =-1000;
P_LOGIT_PROB =exp(P_LOGIT_PROB)/(1+exp(P_LOGIT_PROB));

P_ZERO_PROB = 2.4011 + IMP_STARS *(-4.0062) + 
              IMP_LabelAppeal*(0.7384) + M_STARS *(6.0790);
if P_ZERO_PROB > 1000 then P_ZERO_PROB =1000;
if P_ZERO_PROB <= -1000 then P_ZERO_PROB =-1000;
P_LOGIT_PROB =exp(P_ZERO_PROB)/(1+exp(P_ZERO_PROB));

P_GENMOD_ZINB = 1.4326 + IMP_STARS *(0.1091) + IMP_Density *(0.2315) +
                M_STARS*(-0.1847);
P_GENMOD_ZINB = exp(P_GENMOD_ZINB);
P_GENMOD_ZINB= P_GENMOD_ZINB* (1+P_ZERO_PROB);

P_GENMOD_ZINB = round(P_GENMoD_ZINB,0.01);
X_GENMOD_ZINB=round(X_GENMOD_ZINB,0.01);

P_ENSEMBLE =(P_REGRESSION + P_GENMOD_NB +P_GENMOD_ZINB)/3;

P_REGRESSION=round(P_REGRESSION,1);
P_GENMOD_NB = round(P_GENMOD_NB,1);
P_ENSEMBLE = round(P_ENSEMBLE,1);
P_GENMOD_ZINB = round(P_GENMOD_ZINB,1);
run;

proc print data=SCOREFILE(obs=25);
var TARGET TARGET_FLAG TARGET_AMT X_GENMOD_NB P_ENSEMBLE P_GENMOD_NB P_REGRESSION P_LOGIT_PROB;
run;
       


*Print Results;
* Prints results from various models used;
proc print data=&FIXFILE. (obs=6);
title "Wine Sales Target Values based on Model Type";
var TARGET 
	X_REGRESSION 
	X_GENMOD_POI
	X_GENMOD_NB 
	X_GENMOD_ZIP
	X_GENMOD_ZIP2
	X_GENMOD_ZINB
	X_LOGIT_PROB;
run;

data SCOREFILE;
set &FIXFILE.;

keep
	TARGET 
	X_REGRESSION 
	X_GENMOD_POI
	X_GENMOD_NB 
	X_GENMOD_ZIP
	X_GENMOD_ZIP2
	X_GENMOD_ZINB
	X_LOGIT_PROB
	;
run; 


%let ERRFILE = ERRFILE;
%let MEANFILE = MEANFILE;

* Model Validation against the Mean value;

%macro FIND_ERROR( SCOREFILE, P, MEANVAL );

%let ERRFILE 	= ERRFILE;
%let MEANFILE	= MEANFILE;

data &ERRFILE.;
set &SCOREFILE.;
	ERROR_MEAN		= abs( TARGET - &MEANVAL.)			**&P.;
	ERROR_REG		= abs( TARGET - X_REGRESSION )		**&P.;
	ERROR_POI		= abs( TARGET - X_GENMOD_POI )		**&P.;
	ERROR_NB		= abs( TARGET - X_GENMOD_NB )		**&P.;
	ERROR_ZIP		= abs( TARGET - X_GENMOD_ZIP )		**&P.;
	ERROR_ZIP2		= abs( TARGET - X_GENMOD_ZIP2 )		**&P.;
	ERROR_ZINB		= abs( TARGET - X_GENMOD_ZINB )		**&P.;
	ERROR_LOG		= abs( TARGET - X_LOGIT_PROB )		**&P.;
run;


proc means data=&ERRFILE. noprint;
output out=&MEANFILE.
	mean(ERROR_MEAN)	=	ERROR_MEAN
	mean(ERROR_REG)		=	ERROR_REG
	mean(ERROR_POI)		=	ERROR_POI
	mean(ERROR_NB)		=	ERROR_NB
	mean(ERROR_ZIP)		=	ERROR_ZIP
	mean(ERROR_ZIP2)	=   ERROR_ZIP2
	mean(ERROR_ZINB)	=	ERROR_ZINB
	mean(ERROR_LOG)		=	ERROR_LOG;

run;

data &MEANFILE.;
length P 8.;
set &MEANFILE.;
	P		= &P.;
	ERROR_MEAN		= ERROR_MEAN	** (1.0/&P.);
	ERROR_REG		= ERROR_REG		** (1.0/&P.);
	ERROR_POI 		= ERROR_POI		** (1.0/&P.);
	ERROR_NB 		= ERROR_NB		** (1.0/&P.);
	ERROR_ZIP 		= ERROR_ZIP		** (1.0/&P.);
	ERROR_ZIP2		= ERROR_ZIP2	** (1.0/&P.);
	ERROR_ZINB 		= ERROR_ZINB	** (1.0/&P.);
	ERROR_LOG 		= ERROR_LOG		** (1.0/&P.); 
	drop _TYPE_;
run;

proc print data=&MEANFILE.;
title "Model Validation - Errors";
run;

%mend;


%FIND_ERROR( SCOREFILE, 1		, 3.03 );
%FIND_ERROR( SCOREFILE, 1.5	, 3.03 );
%FIND_ERROR( SCOREFILE, 2		, 3.03 );





******;










 