function h = getOutputFunctionList

    h.PharmacyUptake = @outputPharmacyUptake;
    h.PlotUptakebyPCT = @plotUptakebyPCT;
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


%% PLOTTING by PCTs
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