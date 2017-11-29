
%let PATH = .;
%let NAME = GAINS;
%let LIB = &NAME..;

libname &NAME. "&PATH.";

%let TARGET 	= TARGET;
%let P_TARGET	= P_TARGET1;



%let INFILE 	= &LIB.GAINS_LIFT;



%let RANKVAR	= RANK;
%let GROUPS		= 10;


%let SORTFILE	= SORTFILE;
%let RANKFILE	= RANKFILE;
%let MEANFILE	= MEANFILE;



*proc print data=&INFILE.;
*run;


proc sort data=&INFILE. out=&SORTFILE.;
by descending &P_TARGET.;
run;


*proc print data=&SORTFILE.;
*run;


proc rank data=&SORTFILE. out=&RANKFILE. groups=&GROUPS. descending;
var &P_TARGET.;
ranks &RANKVAR.;
run;

data &RANKFILE.;
set &RANKFILE.;
&RANKVAR. = &RANKVAR. + 1;
run;

proc print data=&RANKFILE.(obs=10);
run;


proc means data=&RANKFILE. noprint;
class &RANKVAR.;
output out=&MEANFILE. sum( &TARGET. )=&TARGET. min(&P_TARGET.)=CUTOFF;
run;


data &MEANFILE.;
set &MEANFILE.;
if missing( &RANKVAR. ) then delete;
drop _TYPE_;
TP = TARGET;
FP = _FREQ_ - TARGET;
drop TARGET;
run;


proc print data=&MEANFILE. NOOBS;
var CUTOFF _FREQ_ TP;
run;

