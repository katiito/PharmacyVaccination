function h = getOutputFunctionList

    h.PharmacyUptake = @outputPharmacyUptake;
    h.PlotUptakebyPCT = @plotUptakebyPCT;
    h.PlotUptakebyPCT_combined = @plotUptakebyPCT_combined;
    h.outputLocationPharmacyvsGP = @outputLocationPharmacyvsGP;
end



function outputPharmacyUptake(GPdata, f)
% find indices that contain or don't contain brackets
        brackets = cellfun(@f.brackets, GPdata, 'UniformOutput', false);
        no_brackets_indices = find(~cellfun(@(a)~isempty(a), brackets));
        OnlyNoBrackets = GPdata(no_brackets_indices);
        
        % of the ones that don't contain brackets:
            % which ones are just Nulls
            out = cellfun(@f.nullindex,OnlyNoBrackets);
            nulls_indices = find(out);
            OnlyNulls = OnlyNoBrackets(nulls_indices);
            % which ones are just Dr names
            drs = cellfun(@f.titleindex, OnlyNoBrackets, 'UniformOutput', false);
            drs_indices = find(cellfun(@(a)~isempty(a), drs));
            OnlyDrs = OnlyNoBrackets(drs_indices);
          
        % print out
        totout = sprintf('Totals: %g', size(brackets,1));
        gpout = sprintf('GP specified: %g', size(brackets,1) - size(nulls_indices,1));
        nullout = sprintf('Nulls: %g', size(nulls_indices,1));
        nopostcode = sprintf('No Postcode: %g', size(no_brackets_indices,1));
        postcodeout = sprintf('With Postcode: %g', size(brackets,1) - size(no_brackets_indices,1));
        onlydrout = sprintf('Only Dr Name: %g - <some address,check output>', size(drs_indices,1) );
        practiceout = sprintf('Practice info: %g + <some address,check output>', size(no_brackets_indices,1) - size(nulls_indices,1) - size(drs_indices,1) );
        
        fprintf('\n\n')
        disp(gpout)
        disp(postcodeout)
        disp(practiceout)
        disp(onlydrout)        
        disp(nullout)
        disp(totout)
        fprintf('\n\n')
end


%% PLOTTING by PCTs (DO NOT USE PHARMACY DATA)
function plotUptakebyPCT(year1data, year2data, year3data, year4data)
yearindex = 0;
for years = {'2010_2011', '2011_2012', '2012_2013', '2013_2014'}   
    years = years{1};
    yearindex = yearindex + 1;
    % pick the year
    if strcmp(years, '2010_2011')
        datafileGP = year1data;
    elseif strcmp(years, '2011_2012')
        datafileGP = year2data;
    elseif strcmp(years, '2012_2013')
        datafileGP = year3data;
    elseif strcmp(years, '2013_2014')
        datafileGP = year4data;
        datafilePH = year4pharmdata;
    end

    %get the PCTs
    PCTNames = unique(datafileGP.PCTName)';
    
    for pctname = PCTNames
        looppct = pctname(1);
        looppct = regexprep(looppct,'[^\w'']','');
        looppct = looppct{1};
        %locate logicals for PCT
        arr.(looppct) = cellfun(@(a)strcmp(a, pctname), datafileGP.PCTName);
        %add up submatrix of vaccinated for PCT
        TotalVacc.(looppct) = sum(datafileGP.Allpatients.aged65andover.Vaccinated(arr.(looppct)))...
                                + sum(datafileGP.Allpatients.aged6monthstounder2years.Vaccinated(arr.(looppct)))...
                                + sum(datafileGP.Allpatients.aged2yearstounder16years.Vaccinated(arr.(looppct)))...
                                + sum(datafileGP.Allpatients.aged16tounder65.Vaccinated(arr.(looppct)));
        TotalReg.(looppct) = sum(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct)))...
                                + sum(datafileGP.Allpatients.aged6monthstounder2years.Registered(arr.(looppct)))...
                                + sum(datafileGP.Allpatients.aged2yearstounder16years.Registered(arr.(looppct)))...
                                + sum(datafileGP.Allpatients.aged16tounder65.Registered(arr.(looppct)));
        pcVacc{yearindex}.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct);
    end
    
    if yearindex < 4
        [outarray(:,yearindex), sortindex] = sortrows(cell2mat(struct2cell(pcVacc{yearindex})) , 1);
    end
    if yearindex==3
        fig = figure;
        set(fig, 'Position', [100 100 1600 900]);
        subplot(2,1,1)
        bar(outarray(:,1:yearindex));
        box off;
        ylim([0 0.22])
        set(gca, 'XTick', 1:size(PCTNames,2))
        set(gca, 'XTickLabel', PCTNames(sortindex))
        xticklabel_rotate();
    elseif yearindex==4
        clear outarray
        [outarray, sortindex] = sortrows(cell2mat(struct2cell(pcVacc{yearindex})), 1);
        subplot(2,1,2)
        bar(outarray);
        box off;
        ylim([0 0.22])
        set(gca, 'XTick', 1:size(PCTNames,2))
        set(gca, 'XTickLabel', PCTNames(sortindex))
        xticklabel_rotate();
    end
    
 end 

end


function plotUptakebyPCT_combined(year1data, year2data, year3data, year4data, year4pharmdata, f)
yearindex = 0;
    for years = {'2010_2011', '2011_2012', '2012_2013', '2013_2014'}   
        years = years{1};
        yearindex = yearindex + 1;
        % pick the year
        if strcmp(years, '2010_2011')
            datafileGP = year1data;
            datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
        elseif strcmp(years, '2011_2012')
            datafileGP = year2data;
            datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
        elseif strcmp(years, '2012_2013')
            datafileGP = year3data;
            datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
        elseif strcmp(years, '2013_2014')
            datafileGP = year4data;
            datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
            datafilePH = year4pharmdata;
            %% MOVE CCG Names to PCT Names so easily comparable
            datafileGP.PCTName = cellfun(f.RelabelCCGasPCT, datafileGP.PCTName, 'UniformOutput', false);
            PCTNames = unique(datafileGP.PCTName)';
        end

        %get the PCTs
        PCTNames = unique(datafileGP.PCTName)';
        for pctname = PCTNames
            looppct = pctname(1);
            looppct = regexprep(looppct,'[^\w'']','');
            looppct = looppct{1};
            %locate logicals for PCT
            arr.(looppct) = cellfun(@(a)strcmp(a, pctname), datafileGP.PCTName);
            %add up submatrix of vaccinated for PCT
            TotalVacc.(looppct) = sum(datafileGP.Allpatients.aged65andover.Vaccinated(arr.(looppct)))...
                                    + sum(datafileGP.Allpatients.aged6monthstounder2years.Vaccinated(arr.(looppct)))...
                                    + sum(datafileGP.Allpatients.aged2yearstounder16years.Vaccinated(arr.(looppct)))...
                                    + sum(datafileGP.Allpatients.aged16tounder65.Vaccinated(arr.(looppct)));
                                
            TotalReg.(looppct) = sum(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct)))...
                                    + sum(datafileGP.Allpatients.aged6monthstounder2years.Registered(arr.(looppct)))...
                                    + sum(datafileGP.Allpatients.aged2yearstounder16years.Registered(arr.(looppct)))...
                                    + sum(datafileGP.Allpatients.aged16tounder65.Registered(arr.(looppct)));
            %calculate percentage vaccinated
            pcVacc{yearindex}.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct);                   
            
            %count up rows in pharmacy data for each PCT
            if strcmp(years, '2013_2014')
                dosecount.(looppct) = sum( cellfun( @(pctname, reference)strcmpi(strtrim(pctname), strtrim(reference)), datafilePH.PCTName, repmat(pctname, size(datafilePH.PCTName,1),1)));
 
                % 2 rows need to be changed for more pharmacy data 2014-5
                pcVaccPharm{1}.(looppct) = (TotalVacc.(looppct) + dosecount.(looppct))/TotalReg.(looppct);  
                
            end
            
            
            
            
        end
    
        
        outarray(:,yearindex) = cell2mat(struct2cell(pcVacc{yearindex}));
        if strcmp(years, '2013_2014')
            pharmarray(:,1) = cell2mat(struct2cell(pcVaccPharm{1}));
        end
    end
    
        [allarray, sortindex] = sortrows([outarray, pharmarray], 1);
        bar(allarray);
        box off;
        ylim([0 0.22])
        set(gca, 'XTick', 1:size(PCTNames,2))
        set(gca, 'XTickLabel', PCTNames(sortindex))
        xticklabel_rotate();
        leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP)', '2013--14 (GP & Pharmacy)');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
 end 




%% HOW MANY PEOPLE GO SOME PLACE ELSE TO GET THEIR FLU SHOT
function outputLocationPharmacyvsGP(dataPH)
    
    denominator = cellfun( @(pharmacy, GP)strcmp(pharmacy, GP), dataPH.PCTName, dataPH.PCTGP);
    numerator = sum(denominator);
    sprintf('There are %g out of %g pharmacy vaccine doses administered in the same CCG/PCT compared to where patient registered', numerator, size(denominator,1))
end