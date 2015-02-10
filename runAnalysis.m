function runAnalysis()

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
PCTNames = unique(dataGP_20102011.PCTName)';

    for pctname = PCTNames
        looppct = pctname(1);
        looppct = regexprep(looppct,'[^\w'']','');
        looppct = looppct{1};
        %locate logicals for PCT
        arr.(looppct) = cellfun(@(a)strcmp(a, pctname), dataGP_20102011.PCTName);
        %add up submatrix of vaccinated for PCT
        TotalVacc.(looppct) = sum(dataGP_20102011.Allpatients.aged65andover.Vaccinated(arr.(looppct)))...
                                + sum(dataGP_20102011.Allpatients.aged6monthstounder2years.Vaccinated(arr.(looppct)))...
                                + sum(dataGP_20102011.Allpatients.aged2yearstounder16years.Vaccinated(arr.(looppct)))...
                                + sum(dataGP_20102011.Allpatients.aged16tounder65.Vaccinated(arr.(looppct)));
        TotalReg.(looppct) = sum(dataGP_20102011.Allpatients.aged65andover.Registered(arr.(looppct)))...
                                + sum(dataGP_20102011.Allpatients.aged6monthstounder2years.Registered(arr.(looppct)))...
                                + sum(dataGP_20102011.Allpatients.aged2yearstounder16years.Registered(arr.(looppct)))...
                                + sum(dataGP_20102011.Allpatients.aged16tounder65.Registered(arr.(looppct)));
        pcVacc.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct);
    end

% 3. WHICH RISK GROUPS had most uptake in pharmacists vs GPs
%uptake over time in GPs (totals=given by GP, total vacc = given by GP + pharmacies) (% given matched GP practice) + Pharmacies (% given matched GP practice)



end
