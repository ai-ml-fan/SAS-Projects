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
*Binning of variables;
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


	*Used for the POI model;
	P_GENMOD_POI = 1.7345 + IMP_STARS *(0.1889) + AcidIndex *(-0.0816) +
       FixedAcidity *(-0.0001) + IMP_Density *(-0.2753) +
	   IMP_ALCOHOL * (0.0033)+ IMP_LABELAPPEAL* (0.1590) + M_Stars *(-0.6518); 
	P_GENMOD_POI=exp(P_GENMOD_POI);
	*P_TARGET = round(P_GENMOD_POI,1);	
	*Used for the Regression model;
	P_REGRESSION =R31316 + IMP_STARS *(0.77928) + AcidIndex *(-0.20055) + 
               VolatileAcidity * (-0.09682) + IMP_Alcohol*(0.01244) +  IMP_SULPHATES *(-0.03045) +
                IMP_LabelAppeal *(0.46613) + IMP_TotalSulfurdioxide *(0.00024906) +
               M_STARS * (-0.69066 )+ IMP_DENSITY * (-0.83132) ;
	*P_TARGET = round(P_REGRESSION,1);	
	
	*Used for the NB model;
	P_GENMOD_NB = 1.7740 + IMP_STARS *(0.1879) + IMP_Density *(-0.2789) +
       IMP_SULPHATES * (-0.0118) + AcidIndex *(-0.0805) +
       VolatileAcidity *(-0.0311) + imp_ph * (-0.0129) +
       IMP_ALCOHOL * (0.0035)+ IMP_LABELAPPEAL* (0.1589) +
       imp_chlorides * (-0.0369) + IMP_FreeSulfurdioxide  *(-0.0001) +
       IMP_TOTALSULFURDIOXIDE *(-0.0001) + M_Stars *(-0.6476); 
    P_GENMOD_NB=exp(P_GENMOD_NB);
    *P_TARGET=round(P_GENMOD_NB,1);
	
	*USed for the ZIP model
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
	P_TARGET=round(P_SCORE_ZIP,1);
	if P_TARGET <0 then P_TARGET =0;
	if P_TARGET > 8 then P_TARGET=8;

	keep INDEX P_TARGET ;

	

%mend;

***********;
********;

*Standalone step for new data ;

%let TESTFILE = ; *put data  filename here;
%let OUTFILE = myoutfile;


data &OUTFILE.;
*Call the Score Macro;


%SCORE(&TESTFILE.,&OUTFILE.);

*******;



