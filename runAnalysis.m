function runAnalysis()

% collect pharmacy data
dataPharmacy_20132014 = ReadInData('pharmacy', '2013_2014');
% collect GP data
dataGP_20102011 = ReadInData('GP', '2010_2011');
dataGP_20112012 = ReadInData('GP', '2011_2012');
dataGP_20122013 = ReadInData('GP', '2012_2013');
dataGP_20132014 = ReadInData('GP', '2013_2014');

% handle to all analysis functions
flist = getCalcFunctionList();
outputs = getOutputFunctionList();




% 1. HOW MANY People weren't associated with a GP
%calcualted NULLs in GP column in pharmacy survey
outputs.PharmacyUptake(dataPharmacy_20132014.GP, flist);



%% PUT ALL THIS IN A FUNCTION TO OUTPUT

            
%% THINGS TO CALCULATE


% 2. WHICH PCTs had most uptake in pharmacists vs GPs
%uptake over time in GPs (totals=given by GP, total vacc = given by GP + pharmacies) (% given matched GP practice) + Pharmacies (% given matched GP practice)

% 3. WHICH RISK GROUPS had most uptake in pharmacists vs GPs
%uptake over time in GPs (totals=given by GP, total vacc = given by GP + pharmacies) (% given matched GP practice) + Pharmacies (% given matched GP practice)



end
