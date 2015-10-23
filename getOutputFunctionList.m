function h = getOutputFunctionList

    h.outputPharmacyUptake = @outputPharmacyUptake;
    h.plotUptakebyPCT = @plotUptakebyPCT;
    h.plotUptakebyPCT_combined = @plotUptakebyPCT_combined;
    h.outputLocationPharmacyvsGP = @outputLocationPharmacyvsGP;
    h.plotFractionFluShotAtPharmacy = @plotFractionFluShotAtPharmacy;
    h.plotCorrelationinUptake = @plotCorrelationinUptake;
    h.outputCompletenessofReporting = @outputCompletenessofReporting;
    
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
function plotUptakebyPCT_combined(year1data, year2data, year3data, year4data, year5data, year4pharmdata, year5pharmdata, f)
yearindex = 0;
    for years = {'2010_2011', '2011_2012', '2012_2013', '2013_2014', '2014_2015'}   
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
        elseif strcmp(years, '2014_2015')
            datafileGP = year5data;
            datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
            datafilePH = year5pharmdata;
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
            if ~strcmp(years, '2014_2015')
                TotalVacc.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Vaccinated(arr.(looppct))))... %elderly patients
                                        + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Vaccinated(arr.(looppct)))) ... 16-65 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Vaccinated(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated(arr.(looppct)))); %  carers;


                TotalReg.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct))))...
                                        + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Registered(arr.(looppct)))) ... 16-65 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Registered(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered(arr.(looppct)))); % carers;
            else
                TotalVacc.(looppct) = sum(f.removeNaN(datafileGP.AllPatients.aged65andover.Vaccinated(arr.(looppct))))... %elderly patients
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged16yearstounder65years.Vaccinated(arr.(looppct)))) ... 16-65 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged5yearstounder16years.Vaccinated(arr.(looppct)))) ... 5-16 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged2yearstounder5years.Vaccinated(arr.(looppct)))) ... 2-5 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.TotalOthers.PregnantandNOTINaclinicalriskgroup.Vaccinated(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated(arr.(looppct)))); %  carers;


                TotalReg.(looppct) = sum(f.removeNaN(datafileGP.AllPatients.aged65andover.Registered(arr.(looppct))))...
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged16yearstounder65years.Registered(arr.(looppct)))) ... 16-65 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged5yearstounder16years.Registered(arr.(looppct)))) ... 5-?6 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged2yearstounder5years.Registered(arr.(looppct)))) ... 2-5 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.TotalOthers.PregnantandNOTINaclinicalriskgroup.Registered(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered(arr.(looppct)))); % carers;
            end
            %calculate percentage vaccinated
            pcVacc{yearindex}.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct);                   
            sdVacc{yearindex}.(looppct) = sqrt(pcVacc{yearindex}.(looppct)*(1-pcVacc{yearindex}.(looppct))/TotalReg.(looppct));
            
            %count up rows in pharmacy data for each PCT
            if strcmp(years, '2013_2014') || strcmp(years, '2014_2015')
                
                if strcmp(years, '2013_2014')
                    index = 1;
                    dosecount{index}.(looppct) = sum( cellfun( @(pctname, reference)strcmpi(strtrim(pctname), strtrim(reference)), datafilePH.PCTGP, repmat(pctname, size(datafilePH.PCTGP,1),1)));
                    
                else
                    index = 2;
                    dosecount{index}.(looppct) = sum( cellfun( @(pctname, reference, numRecords) (double(numRecords) .* strcmpi(strtrim(pctname), strtrim(reference))),...
                                                                            datafilePH.PracticeBorough, ...
                                                                            repmat(pctname, size(datafilePH.PracticeBorough,1),1),...
                                                                            mat2cell(datafilePH.NoRecords, ones(size(datafilePH.NoRecords,1), 1))));
                end
                % 2 rows need to be changed for more pharmacy data 2014-5
                %pcVaccPharm{1}.(looppct) = (TotalVacc.(looppct) + dosecount.(looppct))/TotalReg.(looppct); 
                %sdVaccPharm1{1}.(looppct) = sqrt(pcVaccPharm{1}.(looppct)*(1-pcVaccPharm{1}.(looppct))/TotalReg.(looppct));
                
                %overall prob that eligible person administered at pharmacy
                pcVaccPharmONLY{index}.(looppct) = dosecount{index}.(looppct)/TotalReg.(looppct);
                sdVaccPharm2{index}.(looppct) = sqrt(pcVaccPharmONLY{1}.(looppct)*(1-pcVaccPharmONLY{1}.(looppct))/TotalReg.(looppct));
                
                % prob that given dose administered at pharmacy 
                %fracPharmONLY{1}.(looppct) = dosecount.(looppct) / (TotalVacc.(looppct) + dosecount.(looppct));
                fracPharmONLY{index}.(looppct) = dosecount{index}.(looppct) / (TotalVacc.(looppct));
                sdVaccPharm3{index}.(looppct) = sqrt(fracPharmONLY{1}.(looppct)*(1-fracPharmONLY{1}.(looppct))/(TotalVacc.(looppct)));
                
            end
            
            
            
            
        end
    
        
        outarray(:,yearindex) = cell2mat(struct2cell(pcVacc{yearindex}));
        sdarray(:,yearindex) = cell2mat(struct2cell(sdVacc{yearindex}));
        
        if strcmp(years, '2014_2015')
            for index = 1:2
                %pharmarray(:,1) = cell2mat(struct2cell(pcVaccPharm{1}));
                %sdvaccpharm1(:,1) = cell2mat(struct2cell(sdVaccPharm1{1}));
                pharmarrayONLY(:,index) = cell2mat(struct2cell(pcVaccPharmONLY{index}));
                sdvaccpharm2(:,index) = cell2mat(struct2cell(sdVaccPharm2{index}));
                fracpharmarrayONLY(:,index) = cell2mat(struct2cell(fracPharmONLY{index}));
                sdvaccpharm3(:,index) = cell2mat(struct2cell(sdVaccPharm3{index}));
            end
        end
    end
    
        % main plot
        [allarray, sortindex] = sortrows(outarray, 4);
        allsd = sdarray(sortindex,:);
        [pharmonlyarray, sortindex_ph] = sortrows(pharmarrayONLY,1);
        sd2arr = sdvaccpharm2(sortindex_ph,:);
        [fracpharmonlyarray, sortindex_fracph] = sortrows(fracpharmarrayONLY,1);
        sd3arr = sdvaccpharm3(sortindex_fracph,:);
   %%     
         fig = figure;
%         papersize = [500 300];
%         set(fig, 'Units','pixels','Position', [0 0 1600 900],...
%                     'Visible', 'off','PaperUnits','centimeters',...
%                     'PaperSize',papersize,'PaperPosition',[5,5,papersize]);
        ss = get(0,'screensize');
        set(gcf,'position',...
                 [100, 100, ss(3), ss(4)]);
%         fig = figure('units','normalized',...
%                         'outerposition',[0 0 1 1],...
%                         'Visible', 'off');     
        plotwidth = 0.41;
        plotheight = 0.40;
        leftmargin = 0.1;
        %rightmargin = 0.05;
        bottommargin = 0.15;
        columnspace = 0.03;
        rowspace = 0.07;
        ticksize = 14;
        titlesize = 20;
        xlimits = [0 32];
        %top row
        ax(1) = axes('Position',  [leftmargin,                           bottommargin+plotheight+rowspace, plotwidth, 0.8*plotheight]);
        ax(2) = axes('Position',  [leftmargin+plotwidth+columnspace,     bottommargin+plotheight+rowspace, plotwidth, 0.8*plotheight]);
        %middle row
        ax(3) = axes('Position',  [leftmargin,                           bottommargin, 2*plotwidth+columnspace, plotheight]);
        
        % plot main fig
        %fig = figure('Position', [100 100 1600 900]); %, 'Visible', 'off');
        %mainax = axes('Position', [0.05 0.1 0.5 1.95]);
        set(gcf,'CurrentAxes',ax(3)),
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
            'Rotation',45, ...
            'FontSize', ticksize)
        leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP & Pharmacy)', '2014-15 (GP & Pharmacy)');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
        set(gca, 'FontSize', ticksize)
        title('c) Fraction of registered individuals vaccinated', 'FontSize', titlesize)
        xlim(xlimits) 

        cmap = [0.2, 0.2, 0.9;
                0.8, 0.8, 0.9;
                0.8, 0.8, 0.9];

        % plot top row (1)
        %colormap(cmap)
        set(gcf,'CurrentAxes',ax(1)), hold on;
        %inset = axes('Position', [mainax(1) mainax(2)+mainax(4) 0.5*mainax(3) mainax(4)]);
        bar(fracpharmonlyarray);
%             x = get(h, 'XData');
%             plot([x{1}; x{1}], [fracpharmonlyarray(:)-1.96*sdvaccpharm2 fracpharmonlyarray+1.96*sdvaccpharm2]', 'k-');
        A = get(gca, 'Children');
        set(A(1), 'FaceColor', [0.6 0.6 0.9])
        set(A(2), 'FaceColor', [0.9 0.9 0.9])   
        numgroups = size(fracpharmonlyarray, 1);
        numbars = size(fracpharmonlyarray, 2);
        groupwidth = min(0.8, numbars/(numbars+1.5));
        
        for i = 1:numbars
            % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
            x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
            plot([x; x], [fracpharmonlyarray(:,i)-1.96*sdvaccpharm2(:,i) fracpharmonlyarray(:,i)+1.96*sdvaccpharm2(:,i)]', 'k-');
            %e = errorbar(x, allarray(:,i), allsd(:,i), 'k', 'linestyle', 'none');
            %errorbar_tick(e,80);
        end
        
        
            %e = errorbar(x, allarray(:,i), allsd(:,i), 'k', 'linestyle', 'none');
            %errorbar_tick(e,80);
        
        %set(h, 'FaceColor', [0.8, 0.8, 0.9]);
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
            'Rotation',45, ...
            'FontSize', ticksize)
        leg = legend('2013-14', '2014-15');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
        set(gca, 'FontSize', ticksize)
        title('a) Fraction of doses administered at pharmacy', 'FontSize', titlesize)
        xlim(xlimits)
        
            % inset histogram
            rax = get(gca, 'Position');
            axes('Position', [rax(1)+0.15*rax(4) rax(2)+0.35*rax(3) 0.35*rax(3) 0.5*rax(4)]);
            [hist1, mdpts1] = hist(fracpharmonlyarray);
            bar(mdpts1, hist1)
            A = get(gca, 'Children');
            set(A(1), 'FaceColor', [0.6 0.6 0.9])
            set(A(2), 'FaceColor', [0.9 0.9 0.9])   
%                 hq = findobj(gca,'Type','patch');
%                 hq.FaceColor = [0.8, 0.8, 0.9];
            ylabel('Frequency', 'FontSize', 12);
            box off;
                
                
                
        % plot top row two
        set(gcf,'CurrentAxes',ax(2)), hold on
        %inset = axes('Position', [ax(1)+0.5*ax(3) ax(2)+0.6*ax(4) 0.5*ax(3) 0.4*ax(4)]);
        bar(pharmonlyarray);
        %x = get(h, 'XData');
        A = get(gca, 'Children');
        set(A(1), 'FaceColor', [0.6 0.6 0.9])
        set(A(2), 'FaceColor', [0.9 0.9 0.9])
        
        numgroups = size(pharmonlyarray, 1);
        numbars = size(pharmonlyarray, 2);
        groupwidth = min(0.8, numbars/(numbars+1.5));
        
        for i = 1:numbars
            % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
            x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
            plot([x; x], [pharmonlyarray(:,i)-1.96*sdvaccpharm3(:,i) pharmonlyarray(:,i)+1.96*sdvaccpharm3(:,i)]', 'k-');
            %e = errorbar(x, allarray(:,i), allsd(:,i), 'k', 'linestyle', 'none');
            %errorbar_tick(e,80);
        end
%                 plot([x; x], [pharmonlyarray-1.96*sdvaccpharm3 pharmonlyarray+1.96*sdvaccpharm3]', 'k-');
%                 set(h, 'FaceColor', [0.8, 0.9, 0.8]);
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
            'Rotation',45, ...
            'FontSize', ticksize)
        leg = legend('2013-14', '2014-15');
        set(leg, 'Location', 'NorthWest', 'FontSize', 14)
        legend('boxoff')
        set(gca, 'FontSize', ticksize)
        title('b) Fraction of registered patients receiving dose at pharmacy', 'FontSize', titlesize)
        xlim(xlimits)
            % inset histogram
                rax = get(gca, 'Position');
                axes('Position', [rax(1)+0.15*rax(4) rax(2)+0.35*rax(3) 0.35*rax(3) 0.5*rax(4)]);
                [hist2, mdpts2] = hist(pharmonlyarray);
                bar(mdpts2, hist2)
                A = get(gca, 'Children');
                set(A(1), 'FaceColor', [0.6 0.6 0.9])
                set(A(2), 'FaceColor', [0.9 0.9 0.9])
%                 hq = findobj(gca,'Type','patch');
%                 hq.FaceColor = [0.8, 0.9, 0.8];
                ylabel('Frequency', 'FontSize', 12);
                box off;
                
                % SAVE FIGURE
%                 saveas(gcf, 'PharmacyUptake_byPCT_4lettercodes.fig');
                %
%                 set(gcf,'PaperPositionMode','auto')
%                 print(gcf,'PharmacyUptake_byPCT_4lettercodesPRINT.pdf','-dpdf','-r300')
%                  saveas(gcf, 'PharmacyUptake_byPCT_4lettercodesSAVE.eps', 'psc2');
 
%%

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

function plotCorrelationinUptake(datafileGP_year0, datafileGP_year1, datafileGP_year2, datafileGP_year3, datafilePH1, datafilePH2, dataIncome, f)

        
        
        yearindex = 0;
        for years = {'2011_2012','2012_2013', '2013_2014','2014_2015'}   
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
                datafilePH = datafilePH1;
            else
                datafileGP = datafileGP_year3;
                datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
                %% MOVE CCG Names to PCT Names so easily comparable
                datafileGP.PCTName = cellfun(f.RelabelCCGasPCT, datafileGP.PCTName, 'UniformOutput', false);
                datafilePH = datafilePH2;
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
%                     TotalVacc.(looppct) = sum(datafileGP.Allpatients.aged65andover.Vaccinated(arr.(looppct)))...
%                                             + sum(datafileGP.TotalAtRiskpatients.aged6monthstounder65yearsallagescombined.Vaccinated(arr.(looppct)));
%                     TotalReg.(looppct) = sum(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct)))...
%                                             + sum(datafileGP.TotalAtRiskpatients.aged6monthstounder65yearsallagescombined.Registered(arr.(looppct)));
                    if ~strcmp(years, '2014_2015')
                        TotalVacc.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Vaccinated(arr.(looppct))))... %elderly patients
                                        + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Vaccinated(arr.(looppct)))) ... 16-65 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Vaccinated(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated(arr.(looppct)))); %  carers;


                        TotalReg.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct))))...
                                        + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Registered(arr.(looppct)))) ... 16-65 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Registered(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered(arr.(looppct)))); % carers;
                    else
                        TotalVacc.(looppct) = sum(f.removeNaN(datafileGP.AllPatients.aged65andover.Vaccinated(arr.(looppct))))... %elderly patients
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged16yearstounder65years.Vaccinated(arr.(looppct)))) ... 16-65 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged5yearstounder16years.Vaccinated(arr.(looppct)))) ... 5-16 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged2yearstounder5years.Vaccinated(arr.(looppct)))) ... 2-5 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.TotalOthers.PregnantandNOTINaclinicalriskgroup.Vaccinated(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated(arr.(looppct)))); %  carers;


                        TotalReg.(looppct) = sum(f.removeNaN(datafileGP.AllPatients.aged65andover.Registered(arr.(looppct))))...
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged16yearstounder65years.Registered(arr.(looppct)))) ... 16-65 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged5yearstounder16years.Registered(arr.(looppct)))) ... 5-?6 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged2yearstounder5years.Registered(arr.(looppct)))) ... 2-5 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.TotalOthers.PregnantandNOTINaclinicalriskgroup.Registered(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered(arr.(looppct)))); % carers;
                    end
                    %calculate percentage vaccinated
                    pcVacc{yearindex}.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct); 
                    if strcmp(years, '2013_2014') || strcmp(years, '2014_2015')
                        
                            if strcmp(years, '2013_2014')
                                %index = 1;
                                dosecount{yearindex-2}.(looppct) = sum( cellfun( @(pctname, reference)strcmpi(strtrim(pctname), strtrim(reference)), datafilePH.PCTGP, repmat(pctname, size(datafilePH.PCTGP,1),1)));

                            else
                                %index = 2;
                                dosecount{yearindex-2}.(looppct) = sum( cellfun( @(pctname, reference, numRecords) (double(numRecords) .* strcmpi(strtrim(pctname), strtrim(reference))),...
                                                                                        datafilePH.PracticeBorough, ...
                                                                            repmat(pctname, size(datafilePH.PracticeBorough,1),1),...
                                                                            mat2cell(datafilePH.NoRecords, ones(size(datafilePH.NoRecords,1), 1))));
                            end
                        % grab number of doses for each PCT (where GP is)
%                         dosecount{yearindex}.(looppct) = sum( cellfun( @(pctname, reference)strcmpi(strtrim(pctname), strtrim(reference)), datafilePH.PCTGP, repmat(pctname, size(datafilePH.PCTGP,1),1)));

                        % 2 rows need to be changed for more pharmacy data 2014-5
                        %pcVacc{yearindex}.(looppct) = (TotalVacc.(looppct) + dosecount.(looppct))/TotalReg.(looppct); 
                        % prob that given dose administered at pharmacy 
                        fracPharmONLY{yearindex-2}.(looppct) = dosecount{yearindex-2}.(looppct) / (TotalVacc.(looppct));
                        
                    else
                                      
                    end
                    
                  
                end
                uptakearray(:,yearindex) = cell2mat(struct2cell(pcVacc{yearindex}));
                if strcmp(years, '2013_2014') || strcmp(years, '2014_2015')
                    fracpharmarrayONLY(:,yearindex-2) = cell2mat(struct2cell(fracPharmONLY{yearindex-2}));
                end
                
        end
        
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
        %X2 = uptakearray(:,3); %2013-4
        X3 = uptakearray(:,4); %2014-5
        y1 = fracpharmarrayONLY(:,1); %2013-4 pharmacy prob
        y2 = fracpharmarrayONLY(:,2); %2014-5 pharmacy prob
        predictors = [X1, y1];
        mdl1 = fitlm(X1, X3); coeff1 = table2array(mdl1.Coefficients); int1 = coeff1(1,1); grad1 = coeff1(2,1);
        %mdl2 = fitlm(X2, y2); coeff2 = table2array(mdl2.Coefficients); int2 = coeff2(1,1); grad2 = coeff2(2,1);
        fullmdl = fitlm(predictors,X3); 
        
        %lines of best fit (income)
        mdl_income1a = fitlm(firstarray.Mean, y2); coeff_income1a = table2array(mdl_income1a.Coefficients); int_income1a = coeff_income1a(1,1); grad_income1a = coeff_income1a(2,1);
        mdl_income2a = fitlm(firstarray.Median, y2); coeff_income2a = table2array(mdl_income2a.Coefficients); int_income2a = coeff_income2a(1,1); grad_income2a = coeff_income2a(2,1);
        
        
        mdl_income1b = fitlm(secondarray.Mean, y2); coeff_income1b = table2array(mdl_income1b.Coefficients); int_income1b = coeff_income1b(1,1); grad_income1b = coeff_income1b(2,1);
        mdl_income2b = fitlm(secondarray.Median, y2); coeff_income2b = table2array(mdl_income2b.Coefficients); int_income2b = coeff_income2b(1,1); grad_income2b = coeff_income2b(2,1);
        
%         %lines of best fit (income)
%         mdl_income3a = fitlm(firstarray.Mean, X3); %coeff_income1a = table2array(mdl_income1a.Coefficients); int_income1a = coeff_income1a(1,1); grad_income1a = coeff_income1a(2,1);
%         mdl_income4a = fitlm(firstarray.Median, X3); %coeff_income2a = table2array(mdl_income2a.Coefficients); int_income2a = coeff_income2a(1,1); grad_income2a = coeff_income2a(2,1);
%         
%         
%         mdl_income3b = fitlm(secondarray.Mean, y1); %coeff_income1b = table2array(mdl_income1b.Coefficients); int_income1b = coeff_income1b(1,1); grad_income1b = coeff_income1b(2,1);
%         mdl_income4b = fitlm(secondarray.Median, y1); %coeff_income2b = table2array(mdl_income2b.Coefficients); int_income2b = coeff_income2b(1,1); grad_income2b = coeff_income2b(2,1);
        
        
        
        %plots
        subplot(2,2,1)
        hold on;
        % 2012-3 (2) and 2014-5 (4)
        plot(uptakearray(:,2), uptakearray(:,4), 'k.', 'MarkerSize',14)
        plot([min(uptakearray(:,2)), max(uptakearray(:,2))] , int1 + grad1*[min(uptakearray(:,2)), max(uptakearray(:,2))] , 'r--', 'LineWidth', 1.6)
        text(uptakearray(:,2), uptakearray(:,4), shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Fraction of eligible people vaccinated 2012/13', 'FontSize', 14)
        ylabel('Fraction of eligible people vaccinated 2014/15', 'FontSize', 14)
        set(gca, 'FontSize', 14)
        
        subplot(2,2,2)
        hold on;
        % 2014-5 (2) and frac pharmacy
        plot(uptakearray(:,4), fracpharmarrayONLY(:,2), 'k.', 'MarkerSize',14)
        %plot([min(uptakearray(:,3)), max(uptakearray(:,3))] , int2 + grad2*[min(uptakearray(:,3)), max(uptakearray(:,3))] , 'r--', 'LineWidth', 1.6)
        text(uptakearray(:,4), fracpharmarrayONLY(:,2), shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Fraction of eligible people vaccinated 2014/15', 'FontSize', 14)
        ylabel('Fraction of doses administered at pharmacy 2014/15', 'FontSize', 14)  
        set(gca, 'FontSize', 14)
        
        subplot(2,2,3)
        hold on;
        plot(secondarray.Mean, fracpharmarrayONLY(:,2), 'k.', 'MarkerSize',14)
        %plot([min(secondarray.Mean), max(secondarray.Mean)] , int_income1b + grad_income1b*[min(secondarray.Mean), max(secondarray.Mean)] , 'r--', 'LineWidth', 1.6)
        rejig_shortnames = shortnames; %
        rejig_shortnames(7) = []; %delete city
        rejig_shortnames(12:(end+1)) = shortnames(12:end);
        rejig_shortnames{12} = 'HAC';
       
        text(secondarray.Mean, fracpharmarrayONLY(:,2), rejig_shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Mean household income, ?', 'FontSize', 14)
        ylabel('Fraction of doses administered at pharmacy 2014/15', 'FontSize', 14)  
        set(gca, 'FontSize', 14)
        
        subplot(2,2,4)
        hold on;
        plot(secondarray.Median, fracpharmarrayONLY(:,2), 'k.', 'MarkerSize',14)
        %plot([min(secondarray.Median), max(secondarray.Median)] , int_income2b + grad_income2b*[min(secondarray.Median), max(secondarray.Median)] , 'r--', 'LineWidth', 1.6)
        text(secondarray.Median, fracpharmarrayONLY(:,2), rejig_shortnames, 'horizontal','left', 'vertical','bottom')
        xlabel('Median household income, ?', 'FontSize', 14)
        ylabel('Fraction of doses administered at pharmacy 2014/15', 'FontSize', 14)  
        set(gca, 'FontSize', 14)
        
         
        testx1 = uptakearray(:,2)-uptakearray(:,1); %difference between 2011-2 and 2012-13
        testx2 = uptakearray(:,3)-uptakearray(:,2); %difference between 2012-3 and 2013-14goe
        testx3 = uptakearray(:,4)-uptakearray(:,3); %difference between 2013-4 and 2014-15
        testx4 = uptakearray(:,4)-uptakearray(:,2); %difference between 2012-3 and 2014-15
        [h1,p1,ci1,stats1] = ttest(testx1)
        [h2,p2,ci2,stats2] = ttest(testx2)
        [h3,p3,ci3,stats3] = ttest(testx3)
        [h4,p4,ci4,stats4] = ttest(testx4)
        
        
end

function outputCompletenessofReporting(datafileGP_2011, datafileGP_2012, datafileGP_2013, datafileGP_2014, datafilePH, f)

            

            yearindex = 0;
        for years = {'2011_2012', '2012_2013', '2013_2014', '2014_2015'}   
                years = years{1};
                yearindex = yearindex + 1;
                
                if strcmp(years, '2011_2012')
                    datafileGP = datafileGP_2011;
                elseif strcmp(years, '2012_2013')
                    datafileGP = datafileGP_2012;
                elseif strcmp(years, '2013_2014')
                %% MOVE CCG Names to PCT Names so easily comparable
                    datafileGP = datafileGP_2013;
                    datafileGP.PCTName = cellfun(f.RelabelCCGasPCT, datafileGP.PCTName, 'UniformOutput', false);
                elseif strcmp(years, '2014_2015')
                    datafileGP = datafileGP_2014;
                    datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
                    %% MOVE CCG Names to PCT Names so easily comparable
                    datafileGP.PCTName = cellfun(f.RelabelCCGasPCT, datafileGP.PCTName, 'UniformOutput', false);
                end
                    PCTNames = unique(datafileGP.PCTName)'; %get the PCTs
                
                for pctname = PCTNames 
                    looppct = pctname(1);
                    looppct = regexprep(looppct,'[^\w'']','');
                    looppct = looppct{1};
                    %locate logicals for PCT
                    arr.(looppct) = cellfun(@(a)strcmp(a, pctname), datafileGP.PCTName);
                    
                   if ~strcmp(years, '2014_2015')
                            TotalVacc.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Vaccinated(arr.(looppct))))... %elderly patients
                                        + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Vaccinated(arr.(looppct)))) ... 16-65 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Vaccinated(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated(arr.(looppct)))); %  carers;


                             TotalReg.(looppct) = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Registered(arr.(looppct))))...
                                        + sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Registered(arr.(looppct)))) ... 16-65 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Registered(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered(arr.(looppct)))); % carers;
                                     
                   else
                        TotalVacc.(looppct) = sum(f.removeNaN(datafileGP.AllPatients.aged65andover.Vaccinated(arr.(looppct))))... %elderly patients
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged16yearstounder65years.Vaccinated(arr.(looppct)))) ... 16-65 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged5yearstounder16years.Vaccinated(arr.(looppct)))) ... 5-16 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged2yearstounder5years.Vaccinated(arr.(looppct)))) ... 2-5 clinical risk groups
                                         + sum(f.removeNaN(datafileGP.TotalOthers.PregnantandNOTINaclinicalriskgroup.Vaccinated(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated(arr.(looppct)))); %  carers;


                        TotalReg.(looppct) = sum(f.removeNaN(datafileGP.AllPatients.aged65andover.Registered(arr.(looppct))))...
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged16yearstounder65years.Registered(arr.(looppct)))) ... 16-65 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged5yearstounder16years.Registered(arr.(looppct)))) ... 5-?6 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged2yearstounder5years.Registered(arr.(looppct)))) ... 2-5 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.TotalOthers.PregnantandNOTINaclinicalriskgroup.Registered(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered(arr.(looppct)))); % carers;
            
                                     
                        TotalVaccOther.(looppct) = sum(f.removeNaN(datafileGP.AllPatients.aged65andover.VaccineElsewhere(arr.(looppct))))... %elderly patients
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged16yearstounder65years.VaccineElsewhere(arr.(looppct)))) ... 16-65 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged5yearstounder16years.VaccineElsewhere(arr.(looppct)))) ... 5-?6 clinical risk groups
                                        + sum(f.removeNaN(datafileGP.Totalatriskpatients.aged2yearstounder5years.VaccineElsewhere(arr.(looppct)))) ... 2-5 clinical risk groups
                                            + sum(f.removeNaN(datafileGP.TotalOthers.PregnantandNOTINaclinicalriskgroup.VaccineElsewhere(arr.(looppct)))) ... pregnant women
                                         + sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.VaccineElsewhere(arr.(looppct)))); %  carers;
                   end
                   
                   
                   %calculate percentage vaccinated
                   pcVacc{yearindex}.(looppct) = TotalVacc.(looppct)/TotalReg.(looppct); 
                   %count up rows in pharmacy data for each PCT
                if strcmp(years, '2014_2015')
                
                   
                        
                        dosecount.(looppct) = sum( cellfun( @(pctname, reference, numRecords) (double(numRecords) .* strcmpi(strtrim(pctname), strtrim(reference))),...
                                                                            datafilePH.PracticeBorough, ...
                                                                            repmat(pctname, size(datafilePH.PracticeBorough,1),1),...
                                                                            mat2cell(datafilePH.NoRecords, ones(size(datafilePH.NoRecords,1), 1))));
                        percentReportedByGP.(looppct) =    TotalVaccOther.(looppct) / dosecount.(looppct);
                        TotalVacc_Estimate.(looppct) = TotalVacc.(looppct) + max(0, dosecount.(looppct) - TotalVaccOther.(looppct));
                        TotalVacc_GPOnly.(looppct) = TotalVacc.(looppct) - TotalVaccOther.(looppct);
                        pcVacc_Estimate.(looppct) = TotalVacc_Estimate.(looppct)/TotalReg.(looppct); 
                        pcVacc_ReportedGP.(looppct) = TotalVacc_GPOnly.(looppct)/TotalReg.(looppct); 
               
                end
                end
                pcVacc_Reportedarray(:,yearindex) = cell2mat(struct2cell(pcVacc{yearindex}));
        
        end
                    
      pcVacc_Estimatearray =  struct2array(pcVacc_Estimate);                   
      pcVacc_ReportedGParray = struct2array(pcVacc_ReportedGP);
      
      % make to plotting array
     percentageReportedbyGP_array = struct2array(percentReportedByGP);
     meanreportedbygp = mean(percentageReportedbyGP_array);
     stdreportedbygp = std(percentageReportedbyGP_array);
     out = sprintf('Mean Fraction reported = %f (std=%f', meanreportedbygp, stdreportedbygp);
     disp(out)
     
     [sortarray, sortindex] = sort(percentageReportedbyGP_array);
     
%      estimated = struct2array(pcVacc_Estimate);
%      reported = struct2array(pcVacc);
     % estimated number of actual doses
 
     %% PERFORM T TESTS OF DIFFERENCES
     uptake2011 = pcVacc_Reportedarray(:,1);
     uptake2012 = pcVacc_Reportedarray(:,2);
     uptake2013 = pcVacc_Reportedarray(:,3);
     uptake2014_rep = pcVacc_Reportedarray(:,4);
     uptake2014 = pcVacc_Estimatearray';
     uptake2014_gp = pcVacc_ReportedGParray';
     diff1 = uptake2014 - uptake2011;
     diff2 = uptake2014 - uptake2012;
     
     
      [h1,p1,ci1,stats1] = ttest(diff1)
       [h1,p1,ci1,stats1] = ttest(diff2)
       figure;
       
     
     shortnames = cellfun( @f.getShortNames, PCTNames, 'UniformOutput', false);
     ticksize = 14;
     titlesize = 18;
     labelsize = 16;
     
     subplot(2,1,1)
     
     %% Histogram of reporting fractions
     [h, centers] = hist(sortarray, 5, [0.8 0.8 0.9]);
     N = size(sortarray,2);
     d = diff(centers);
     bar(centers, h/N)
            A = get(gca, 'Children');
            set(A, 'FaceColor', [0.8 0.8 0.9])
            title('a) Maximum fraction of pharmacy doses reported in GP data 2014/15', 'FontSize', titlesize)
            set(gca, 'FontSize', ticksize, 'XLim', [centers(1)-d(1)/2,centers(end)+d(1)/2])
            set(gca, 'XTick', 0.3:0.1:1.0)
            box off;
%      bar(sortarray)
%          A = get(gca, 'Children');
%          set(A, 'FaceColor', [0.8 0.8 0.9])
%          title('a) Maximum pharmacy doses that are reported in GP data 2014/15', 'FontSize', titlesize)
%          ylabel('Fraction administered', 'FontSize', labelsize)
%             set(gca, 'XTick', 1:size(shortnames,2), 'FontSize', ticksize)
%             set(gca, 'XTickLabel', {})
%             text(1:length(shortnames),...
%                 zeros(1,length(shortnames)), ...
%                 shortnames(sortindex), ...
%                 'VerticalAlign','top',...
%                 'HorizontalAlign','right',...
%                 'Rotation',45, ...
%                 'FontSize', ticksize)
%             xlim([0 32])
%             box off;

    subplot(2,1,2)
    boxplot([uptake2014_gp(sortindex), uptake2014_rep(sortindex), uptake2014(sortindex)],...
            'Color', 'bbb', 'Symbol', 'b.')
        title('b) Vaccine uptake 2014/15', 'FontSize', titlesize)
        set(gca, 'FontSize', ticksize)
        set(gca, 'XTickLabel', {'GP administered', 'GP+Pharmacy administered (GP reported)', 'GP+Pharmacy administered (GP+Pharmacy reported)'});
        box off
%     bar([uptake2014_gp(sortindex), uptake2014_rep(sortindex), uptake2014(sortindex)])
%             title('b) GP administeration and pharmacy administration (reported and estimated) 2014/15', 'FontSize', titlesize)
%             ylabel('Fraction administered', 'FontSize', labelsize)
%             set(gca, 'XTick', 1:size(shortnames,2), 'FontSize', ticksize)
%             set(gca, 'XTickLabel', {})
%             text(1:length(shortnames),...
%                 zeros(1,length(shortnames)), ...
%                 shortnames(sortindex), ...
%                 'VerticalAlign','top',...
%                 'HorizontalAlign','right',...
%                 'Rotation',45, ...
%                 'FontSize', ticksize)
%             xlim([0 32])
%             box off;
%             leg = legend('GP administered', 'GP+Pharmacy administered (GP reported)', 'GP+Pharmacy administered (GP+Pharmacy reported)');
%             set(leg, 'FontSize', ticksize)
%             legend('boxoff')
          end


%% HOW MANY PEOPLE GO SOME PLACE ELSE TO GET THEIR FLU SHOT
function outputLocationPharmacyvsGP(dataPH)
    
    denominator = cellfun( @(pharmacy, GP)strcmp(pharmacy, GP), dataPH.PCTName, dataPH.PCTGP);
    numerator = sum(denominator);
    sprintf('There are %g out of %g pharmacy vaccine doses administered in the same CCG/PCT compared to where patient registered', numerator, size(denominator,1))
end