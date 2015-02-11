function runAnalysis()
close all
%%%% FUNCTIONS %%%%
flist = getCalcFunctionList();
outputs = getOutputFunctionList();


%%%% READ IN DATA %%%%
dataPharmacy_20132014 = ReadInData('pharmacy', '2013_2014');
dataGP_20102011 = ReadInData('GP', '2010_2011');
dataGP_20112012 = ReadInData('GP', '2011_2012');
dataGP_20122013 = ReadInData('GP', '2012_2013');
dataGP_20132014 = ReadInData('GP', '2013_2014');

%%%% ANALYSIS %%%%

% Pharmacy survey output
outputs.PharmacyUptake(dataPharmacy_20132014.GP, flist);

            
% 2. WHICH PCTs had most uptake in pharmacists vs GPs
%uptake over time in GPs (totals=given by GP, total vacc = given by GP + pharmacies) (% given matched GP practice) + Pharmacies (% given matched GP practice)
outputs.PlotUptakebyPCT(dataGP_20102011, dataGP_20112012, dataGP_20122013, dataGP_20132014);

    
 
  
% 3. WHICH RISK GROUPS had most uptake in pharmacists vs GPs
%uptake over time in GPs (totals=given by GP, total vacc = given by GP + pharmacies) (% given matched GP practice) + Pharmacies (% given matched GP practice)



end
