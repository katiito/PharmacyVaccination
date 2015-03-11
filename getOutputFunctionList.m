function h = getOutputFunctionList

    h.outputPharmacyUptake = @outputPharmacyUptake;
    h.plotUptakebyPCT = @plotUptakebyPCT;
    h.plotUptakebyPCT_combined = @plotUptakebyPCT_combined;
    h.outputLocationPharmacyvsGP = @outputLocationPharmacyvsGP;
    h.plotFractionFluShotAtPharmacy = @plotFractionFluShotAtPharmacy;
    h.plotCorrelationinUptake = @plotCorrelationinUptake;
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
                               % + sum(datafileGP.Allpatients.aged6monthstounder2years.Vaccinated(arr.(looppct)))...
                               % + sum(datafileGP.Allpatients.aged2yearstounder16years.Vaccinated(arr.(looppct)))...
                                + sum(datafileGP.Allpatients.aged16tounder65.Vaccinated(arr.(looppct)));
        TotalReg.(looppct) = sum(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct)))...
                               % + sum(datafileGP.Allpatients.aged6monthstounder2years.Registered(arr.(looppct)))...
                               % + sum(datafileGP.Allpatients.aged2yearstounder16years.Registered(arr.(looppct)))...
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

%% PLOTTING by PCT
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
            %PCTNames = unique(datafileGP.PCTName)';
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
            TotalVacc.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Vaccinated(arr.(looppct))))... %elderly patients
                                    + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Vaccinated(arr.(looppct)))) ... 16-65 clinical risk groups
                                     + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Vaccinated(arr.(looppct)))) ... pregnant women
                                     + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated(arr.(looppct)))); %  carers;
                                    
                                
            TotalReg.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct))))...
                                    + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Registered(arr.(looppct)))) ... 16-65 clinical risk groups
                                     + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Registered(arr.(looppct)))) ... pregnant women
                                     + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered(arr.(looppct)))); % carers;
                                    
            %calculate percentage vaccinated
            pcVacc{yearindex}.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct);                   
            sdVacc{yearindex}.(looppct) = sqrt(pcVacc{yearindex}.(looppct)*(1-pcVacc{yearindex}.(looppct))/TotalReg.(looppct));
            
            %count up rows in pharmacy data for each PCT
            if strcmp(years, '2013_2014')
                dosecount.(looppct) = sum( cellfun( @(pctname, reference)strcmpi(strtrim(pctname), strtrim(reference)), datafilePH.PCTGP, repmat(pctname, size(datafilePH.PCTGP,1),1)));
 
                % 2 rows need to be changed for more pharmacy data 2014-5
                %pcVaccPharm{1}.(looppct) = (TotalVacc.(looppct) + dosecount.(looppct))/TotalReg.(looppct); 
                %sdVaccPharm1{1}.(looppct) = sqrt(pcVaccPharm{1}.(looppct)*(1-pcVaccPharm{1}.(looppct))/TotalReg.(looppct));
                
                %overall prob that eligible person administered at pharmacy
                pcVaccPharmONLY{1}.(looppct) = dosecount.(looppct)/TotalReg.(looppct);
                sdVaccPharm2{1}.(looppct) = sqrt(pcVaccPharmONLY{1}.(looppct)*(1-pcVaccPharmONLY{1}.(looppct))/TotalReg.(looppct));
                
                % prob that given dose administered at pharmacy 
                %fracPharmONLY{1}.(looppct) = dosecount.(looppct) / (TotalVacc.(looppct) + dosecount.(looppct));
                fracPharmONLY{1}.(looppct) = dosecount.(looppct) / (TotalVacc.(looppct));
                sdVaccPharm3{1}.(looppct) = sqrt(fracPharmONLY{1}.(looppct)*(1-fracPharmONLY{1}.(looppct))/(TotalVacc.(looppct)));
                
            end
            
            
            
            
        end
    
        
        outarray(:,yearindex) = cell2mat(struct2cell(pcVacc{yearindex}));
        sdarray(:,yearindex) = cell2mat(struct2cell(sdVacc{yearindex}));
        
        if strcmp(years, '2013_2014')
            %pharmarray(:,1) = cell2mat(struct2cell(pcVaccPharm{1}));
            %sdvaccpharm1(:,1) = cell2mat(struct2cell(sdVaccPharm1{1}));
            pharmarrayONLY(:,1) = cell2mat(struct2cell(pcVaccPharmONLY{1}));
            sdvaccpharm2(:,1) = cell2mat(struct2cell(sdVaccPharm2{1}));
            fracpharmarrayONLY(:,1) = cell2mat(struct2cell(fracPharmONLY{1}));
            sdvaccpharm3(:,1) = cell2mat(struct2cell(sdVaccPharm3{1}));
        end
    end
    
        % main plot
        [allarray, sortindex] = sortrows(outarray, 4);
        allsd = sdarray(sortindex,:);
        [pharmonlyarray, sortindex_ph] = sort(pharmarrayONLY);
        sd2arr = sdvaccpharm2(sortindex_ph);
        [fracpharmonlyarray, sortindex_fracph] = sort(fracpharmarrayONLY);
        sd3arr = sdvaccpharm3(sortindex_fracph);
        
        fig = figure;
        %set(fig, 'Position', [100 100 1600 900]);
        ss = get(0,'screensize');
        set(gcf,'position',...
                 [100, 100, ss(3), ss(4)]);
        plotwidth = 0.41;
        plotheight = 0.40;
        leftmargin = 0.1;
        %rightmargin = 0.05;
        bottommargin = 0.15;
        columnspace = 0.03;
        rowspace = 0.07;
        ticksize = 14;
        titlesize = 16;
        xlimits = [0 32];
        %top row
        ax(1) = axes('Position',  [leftmargin,                           bottommargin+plotheight+rowspace, plotwidth, 0.8*plotheight]);
        ax(2) = axes('Position',  [leftmargin+plotwidth+columnspace,     bottommargin+plotheight+rowspace, plotwidth, 0.8*plotheight]);
        %middle row
        ax(3) = axes('Position',  [leftmargin,                           bottommargin, 2*plotwidth+columnspace, plotheight]);
        
        % plot main fig
        %fig = figure('Position', [100 100 1600 900]); %, 'Visible', 'off');
        %mainax = axes('Position', [0.05 0.1 0.5 1.95]);
        axes(ax(3));
        hold on;
        bar(allarray);
        numgroups = size(allarray, 1);
        numbars = size(allarray, 2);
        groupwidth = min(0.8, numbars/(numbars+1.5));
        
        for i = 1:numbars
            % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
            x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
            plot([x; x], [allarray(:,i)-1.96*allsd(:,i) allarray(:,i)+1.96*allsd(:,i)]', 'k-');
            %e = errorbar(x, allarray(:,i), allsd(:,i), 'k', 'linestyle', 'none');
            %errorbar_tick(e,80);
        end
        
        box off;
        set(gca, 'XTick', 1:size(PCTNames,2))
        set(gca, 'XTickLabel', {})
        text(1:length(PCTNames),...
            zeros(1,length(PCTNames)), ...
            PCTNames(sortindex), ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',45)
        leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP & Pharmacy)');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
        set(gca, 'FontSize', ticksize)
        title('Fraction of registered individuals vaccinated', 'FontSize', titlesize)
        xlim(xlimits) 



        % plot top row (1)
        axes(ax(1)), hold on;
        %inset = axes('Position', [mainax(1) mainax(2)+mainax(4) 0.5*mainax(3) mainax(4)]);
        h = bar(fracpharmonlyarray);
        x = get(h, 'XData');
        plot([x; x], [fracpharmonlyarray-1.96*sdvaccpharm2 fracpharmonlyarray+1.96*sdvaccpharm2]', 'k-');
            %e = errorbar(x, allarray(:,i), allsd(:,i), 'k', 'linestyle', 'none');
            %errorbar_tick(e,80);
        
        set(h, 'FaceColor', [0.8, 0.8, 0.9]);
        box off;
        %ylim([0 0.22])
        shortnames = cellfun( @f.getShortNames, PCTNames(sortindex_fracph), 'UniformOutput', false);
        set(gca, 'XTick', 1:size(shortnames,2))
        set(gca, 'XTickLabel', {})
        text(1:length(shortnames),...
            zeros(1,length(shortnames)), ...
            shortnames, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',45)
        %leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP)', '2013-14 (GP & Pharmacy)');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
        set(gca, 'FontSize', ticksize)
        title('Fraction of doses administered at pharmacy', 'FontSize', titlesize)
        xlim(xlimits)
                %% inset histogram
                rax = get(gca, 'Position');
                axes('Position', [rax(1)+0.15*rax(4) rax(2)+0.35*rax(3) 0.35*rax(3) 0.5*rax(4)]);
                hist(fracpharmonlyarray);
                hq = findobj(gca,'Type','patch');
                hq.FaceColor = [0.8, 0.8, 0.9];
                ylabel('Frequency', 'FontSize', 12);
                box off;
        % plot top row two
        axes(ax(2)), hold on;
        %inset = axes('Position', [ax(1)+0.5*ax(3) ax(2)+0.6*ax(4) 0.5*ax(3) 0.4*ax(4)]);
        h = bar(pharmonlyarray);
        x = get(h, 'XData');
        plot([x; x], [pharmonlyarray-1.96*sdvaccpharm3 pharmonlyarray+1.96*sdvaccpharm3]', 'k-');
        set(h, 'FaceColor', [0.8, 0.9, 0.8]);
        box off;
        %ylim([0 0.22])
        shortnames = cellfun( @f.getShortNames, PCTNames(sortindex_ph), 'UniformOutput', false);
        set(gca, 'XTick', 1:size(shortnames,2))
        set(gca, 'XTickLabel', {})
        text(1:length(shortnames),...
            zeros(1,length(shortnames)), ...
            shortnames, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',45)
        %leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP)', '2013-14 (GP & Pharmacy)');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
        set(gca, 'FontSize', ticksize)
        title('Fraction of registered patients receiving dose at pharmacy', 'FontSize', titlesize)
        xlim(xlimits)
            %% inset histogram
                rax = get(gca, 'Position');
                axes('Position', [rax(1)+0.15*rax(4) rax(2)+0.35*rax(3) 0.35*rax(3) 0.5*rax(4)]);
                hist(pharmonlyarray);
                hq = findobj(gca,'Type','patch');
                hq.FaceColor = [0.8, 0.9, 0.8];
                ylabel('Frequency', 'FontSize', 12);
                box off;
 end 


%% HOW MANY PEOPLE GET THE FLU SHOT AT A PHARMACY BY PCT (relative to number of people registered)
function plotFractionFluShotAtPharmacy(GPdata, PHdata, f)
    %% streamline the 
    GPdata.PCTName = cellfun(f.RemovePCT, GPdata.PCTName, 'UniformOutput', false);
    %% MOVE CCG Names to PCT Names so easily comparable
    GPdata.PCTName = cellfun(f.RelabelCCGasPCT, GPdata.PCTName, 'UniformOutput', false);
    
     %get the PCTs
    PCTNames = unique(GPdata.PCTName)';
        for pctname = PCTNames
            looppct = pctname(1);
            looppct = regexprep(looppct,'[^\w'']','');
            looppct = looppct{1};
            %locate logicals for PCT
            arr.(looppct) = cellfun(@(a)strcmp(a, pctname), GPdata.PCTName);
            %add up number of people registered in each PCT/CCG           
            TotalReg.(looppct) = sum(GPdata.Allpatients.aged65andover.Registered(arr.(looppct)))...
                                    + sum(GPdata.TotalAtRiskpatients.aged6monthstounder65yearsallagescombined.Registered(arr.(looppct)));
                                   
            %count up rows in pharmacy data for each PCT
            dosecount.(looppct) = sum( cellfun( @(pctname, reference)strcmpi(strtrim(pctname), strtrim(reference)), PHdata.PCTGP, repmat(pctname, size(PHdata.PCTGP,1),1))); 
            % next rows need to be changed for more pharmacy data 2014-5
            pcVaccPharm{1}.(looppct) = dosecount.(looppct)/TotalReg.(looppct);  
                
        end
        
        %make into array to plot
        pharmarray(:,1) = cell2mat(struct2cell(pcVaccPharm{1}));
            
        [sortarray, sortindex] = sortrows(pharmarray);
        figure;
        bar(sortarray);
        box off;
        %ylim([0 0.22])
        set(gca, 'XTick', 1:size(PCTNames,2))
        set(gca, 'XTickLabel', PCTNames(sortindex))
        xticklabel_rotate();
        %leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP)', '2013-14 (GP & Pharmacy)');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
           
            
            
end

function plotCorrelationinUptake(datafileGP_year0, datafileGP_year1, datafileGP_year2, datafilePH, dataIncome, f)

        
        
        yearindex = 0;
        for years = {'2011_2012','2012_2013', '2013_2014'}   
            years = years{1};
            yearindex = yearindex + 1;
            % pick the year
            if strcmp(years, '2011_2012')
                datafileGP = datafileGP_year0;
                datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
            elseif strcmp(years, '2012_2013')
                datafileGP = datafileGP_year1;
                datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
            elseif strcmp(years, '2013_2014')
                datafileGP = datafileGP_year2;
                datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
                %% MOVE CCG Names to PCT Names so easily comparable
                datafileGP.PCTName = cellfun(f.RelabelCCGasPCT, datafileGP.PCTName, 'UniformOutput', false);
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
                                            + sum(datafileGP.TotalAtRiskpatients.aged6monthstounder65yearsallagescombined.Vaccinated(arr.(looppct)));
                    TotalReg.(looppct) = sum(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct)))...
                                            + sum(datafileGP.TotalAtRiskpatients.aged6monthstounder65yearsallagescombined.Registered(arr.(looppct)));

                    %calculate percentage vaccinated
                    pcVacc{yearindex}.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct); 
                    if strcmp(years, '2013_2014')
                        % grab number of doses for each PCT (where GP is)
                        dosecount.(looppct) = sum( cellfun( @(pctname, reference)strcmpi(strtrim(pctname), strtrim(reference)), datafilePH.PCTGP, repmat(pctname, size(datafilePH.PCTGP,1),1)));

                        % 2 rows need to be changed for more pharmacy data 2014-5
                        %pcVacc{yearindex}.(looppct) = (TotalVacc.(looppct) + dosecount.(looppct))/TotalReg.(looppct); 
                        % prob that given dose administered at pharmacy 
                        fracPharmONLY{1}.(looppct) = dosecount.(looppct) / (TotalVacc.(looppct));
                    else
                                      
                    end
                  
                end
                uptakearray(:,yearindex) = cell2mat(struct2cell(pcVacc{yearindex}));
        
        end
        fracpharmarrayONLY = cell2mat(struct2cell(fracPharmONLY{1}));
        shortnames = cellfun( @f.getShortNames, PCTNames, 'UniformOutput', false);
        
        %% get income data collated

        for index = 1:size(dataIncome.Borough,1)
           curr_pct = dataIncome.Borough{index};
           
           if strcmpi(curr_pct,'Merton')
              mertonindex = index;
%               incomeMertonSutton_mean =  dataIncome.Mean;
%               incomeMertonSutton_median =  dataIncome.Median;
           elseif strcmpi(curr_pct,'Sutton')
               % udpate mean and median for Sutton and Merton
              dataIncome.Mean(index) =  0.5*(dataIncome.Mean(mertonindex) + dataIncome.Mean(index));
              dataIncome.Median(index) =  0.5*(dataIncome.Median(mertonindex) + dataIncome.Median(index));
           elseif strcmpi(curr_pct, 'Hackney')
                   hackneyindex = index;
           end
        end
        %delete merton as combined with Sutton
        dataIncome.Mean(mertonindex) = [];
        dataIncome.Median(mertonindex) = [];
        firstarray = dataIncome;
        secondarray = dataIncome;
        % first array - Move city to Hackney place, delete Hackney
        firstarray.Mean(hackneyindex) = dataIncome.Mean(1);
        firstarray.Median(hackneyindex) = dataIncome.Median(1);
        firstarray.Mean(1) = [];
        firstarray.Median(1) = [];
        % second array - Delete city.
        secondarray.Mean(1) = [];
        secondarray.Median(1) = [];
        
        %lines of best fit (uptakes)
        X1 = uptakearray(:,2); %2012-3
        X2 = uptakearray(:,3); %2013-4
        y1 = uptakearray(:,3); %2013-4
        y2 = fracpharmarrayONLY; %2013-4 pharmacy prob
        mdl1 = fitlm(X1, y1); coeff1 = table2array(mdl1.Coefficients); int1 = coeff1(1,1); grad1 = coeff1(2,1);
        mdl2 = fitlm(X2, y2); coeff2 = table2array(mdl2.Coefficients); int2 = coeff2(1,1); grad2 = coeff2(2,1);
        
        %lines of best fit (income)
        mdl_income1a = fitlm(firstarray.Mean, fracpharmarrayONLY); coeff_income1a = table2array(mdl_income1a.Coefficients); int_income1a = coeff_income1a(1,1); grad_income1a = coeff_income1a(2,1);
        mdl_income2a = fitlm(firstarray.Median, fracpharmarrayONLY); coeff_income2a = table2array(mdl_income2a.Coefficients); int_income2a = coeff_income2a(1,1); grad_income2a = coeff_income2a(2,1);
        
        
        mdl_income1b = fitlm(secondarray.Mean, fracpharmarrayONLY); coeff_income1b = table2array(mdl_income1b.Coefficients); int_income1b = coeff_income1b(1,1); grad_income1b = coeff_income1b(2,1);
        mdl_income2b = fitlm(secondarray.Median, fracpharmarrayONLY); coeff_income2b = table2array(mdl_income2b.Coefficients); int_income2b = coeff_income2b(1,1); grad_income2b = coeff_income2b(2,1);
        
        %lines of best fit (uptake)
        mdl_income3a = fitlm(firstarray.Mean, y1); %coeff_income1a = table2array(mdl_income1a.Coefficients); int_income1a = coeff_income1a(1,1); grad_income1a = coeff_income1a(2,1);
        mdl_income4a = fitlm(firstarray.Median, y1); %coeff_income2a = table2array(mdl_income2a.Coefficients); int_income2a = coeff_income2a(1,1); grad_income2a = coeff_income2a(2,1);
        
        
        mdl_income3b = fitlm(secondarray.Mean, y1); %coeff_income1b = table2array(mdl_income1b.Coefficients); int_income1b = coeff_income1b(1,1); grad_income1b = coeff_income1b(2,1);
        mdl_income4b = fitlm(secondarray.Median, y1); %coeff_income2b = table2array(mdl_income2b.Coefficients); int_income2b = coeff_income2b(1,1); grad_income2b = coeff_income2b(2,1);
        
        
        
        %plots
        subplot(2,2,1)
        hold on;
        % 2012-3 (2) and 2013-4 (3)
        plot(uptakearray(:,2), uptakearray(:,3), 'k.', 'MarkerSize',14)
        plot([min(uptakearray(:,2)), max(uptakearray(:,2))] , int1 + grad1*[min(uptakearray(:,2)), max(uptakearray(:,2))] , 'r--', 'LineWidth', 1.6)
        text(uptakearray(:,2), uptakearray(:,3), shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Fraction of eligible people vaccinated 2012-3', 'FontSize', 14)
        ylabel('Fraction of eligible people vaccinated 2013-4', 'FontSize', 14)
        set(gca, 'FontSize', 14)
        
        subplot(2,2,2)
        hold on;
        plot(uptakearray(:,3), fracpharmarrayONLY, 'k.', 'MarkerSize',14)
        plot([min(uptakearray(:,3)), max(uptakearray(:,3))] , int2 + grad2*[min(uptakearray(:,3)), max(uptakearray(:,3))] , 'r--', 'LineWidth', 1.6)
        text(uptakearray(:,3), fracpharmarrayONLY, shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Fraction of eligible people vaccinated 2013-4', 'FontSize', 14)
        ylabel('Fraction of doses administered at pharmacy', 'FontSize', 14)  
        set(gca, 'FontSize', 14)
        
        subplot(2,2,3)
        hold on;
        plot(secondarray.Mean, fracpharmarrayONLY, 'k.', 'MarkerSize',14)
        plot([min(secondarray.Mean), max(secondarray.Mean)] , int_income1b + grad_income1b*[min(secondarray.Mean), max(secondarray.Mean)] , 'r--', 'LineWidth', 1.6)
        rejig_shortnames = shortnames; %
        rejig_shortnames(7) = []; %delete city
        rejig_shortnames(12:(end+1)) = shortnames(12:end);
        rejig_shortnames{12} = 'HAC';
       
        text(secondarray.Mean, fracpharmarrayONLY, rejig_shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Mean household income', 'FontSize', 14)
        ylabel('Fraction of doses administered at pharmacy', 'FontSize', 14)  
        set(gca, 'FontSize', 14)
        
        subplot(2,2,4)
        hold on;
        plot(secondarray.Median, fracpharmarrayONLY, 'k.', 'MarkerSize',14)
        plot([min(secondarray.Median), max(secondarray.Median)] , int_income2b + grad_income2b*[min(secondarray.Median), max(secondarray.Median)] , 'r--', 'LineWidth', 1.6)
        text(secondarray.Median, fracpharmarrayONLY, rejig_shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Median household income', 'FontSize', 14)
        ylabel('Fraction of doses administered at pharmacy', 'FontSize', 14)  
        set(gca, 'FontSize', 14)
        
         
        testx1 = uptakearray(:,2)-uptakearray(:,1); %difference between 2011-2 and 2012-13
        testx2 = uptakearray(:,3)-uptakearray(:,2); %difference between 2012-3 and 2013-14
        [h1,p1,ci1,stats1] = ttest(testx1)
        [h2,p2,ci2,stats2] = ttest(testx2)
        
end


%% HOW MANY PEOPLE GO SOME PLACE ELSE TO GET THEIR FLU SHOT
function outputLocationPharmacyvsGP(dataPH)
    
    denominator = cellfun( @(pharmacy, GP)strcmp(pharmacy, GP), dataPH.PCTName, dataPH.PCTGP);
    numerator = sum(denominator);
    sprintf('There are %g out of %g pharmacy vaccine doses administered in the same CCG/PCT compared to where patient registered', numerator, size(denominator,1))
end