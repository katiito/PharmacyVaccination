function outputs = getOutputRiskGroupFunctionList()

outputs.plotUptakebyRisk = @plotUptakebyRisk;

end



function plotUptakebyRisk(year1data, year2data, year3data, year4data, year4pharmdata, f)
    
    % loop through years to 
    yearindex = 0;
    for years = {'2010_2011', '2011_2012', '2012_2013', '2013_2014'}   
        years = years{1};
        yearindex = yearindex + 1;
        % pick the year
        if strcmp(years, '2010_2011')
            datafileGP = year1data;
            datafileGP.PatientswithChronicNeurologicalDisease = f.CombineNeuro(...
                                            datafileGP.PatientswithChronicNeurologicalDisease,...
                                            datafileGP.PatientswithStrokeTransientIschaemicAttackTIA);
                                            
            datafileGP = rmfield(datafileGP, 'PatientswithStrokeTransientIschaemicAttackTIA');
            %datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
        elseif strcmp(years, '2011_2012')
            datafileGP = year2data;
            %datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
        elseif strcmp(years, '2012_2013')
            datafileGP = year3data;
            %datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
        elseif strcmp(years, '2013_2014')
            datafileGP = year4data;
            %datafileGP.PCTName = cellfun(f.RemovePCT, datafileGP.PCTName, 'UniformOutput', false);
            datafilePH = year4pharmdata;
            %% MOVE CCG Names to PCT Names so easily comparable
            %datafileGP.PCTName = cellfun(f.RelabelCCGasPCT, datafileGP.PCTName, 'UniformOutput', false);
            %PCTNames = unique(datafileGP.PCTName)';
        end
        
        Fields = {'Elderly',...
                  'PatientswithChronicHeartDisease',...
                  'PatientswithChronicRespiratoryDisease',...
                  'PatientswithChronicKidneyDisease',...
                  'PatientswithChronicLiverDisease',...
                  'PatientswithDiabetes',...
                  'PatientswithImmunosuppression',...
                  'PatientswithChronicNeurologicalDisease',...
                  'PregnantWomen',...
                  'Carers'};
        
        %% GP data
        for fld = Fields
              fld = char(fld{1});
              % add up the elderly
              if strcmpi(fld, 'Elderly')
                total_vac{yearindex}.Elderly  =  sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Vaccinated));
                total_reg{yearindex}.Elderly = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Registered));
              % add in pregnant women
              elseif strcmpi(fld, 'PregnantWomen')
                  total_vac{yearindex}.PregnantWomen = sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Vaccinated));
                  total_reg{yearindex}.PregnantWomen = sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Registered));
              % add in carers in whatever capacity
              elseif strcmpi(fld, 'Carers')
                   total_vac{yearindex}.Carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated));
                   total_reg{yearindex}.Carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Registered));
              % add in everyone else under risk group 
              else
                total_vac{yearindex}.(fld)  =  sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Vaccinated))+...
                                     sum(f.removeNaN(datafileGP.(fld).aged2yearstounder16years.Vaccinated))+...
                                     sum(f.removeNaN(datafileGP.(fld).aged16tounder65.Vaccinated));
                total_reg{yearindex}.(fld) = sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Registered))+...
                                   sum(f.removeNaN(datafileGP.(fld).aged2yearstounder16years.Registered))+...
                                   sum(f.removeNaN(datafileGP.(fld).aged16tounder65.Registered));
              end
        end
        
                % combine all entries for total in risk groups
       
                array_vac(:,yearindex) = struct2array(total_vac{yearindex});
                array_reg(:,yearindex) = struct2array(total_reg{yearindex});
                
                

                %% calculate totals (excluding elderly and carers)
                riskgroupsreported_vaccinated(yearindex) = sum(array_vac(2:(end-1),yearindex));
                riskgroupsreported_registered(yearindex) = sum(array_reg(2:(end-1),yearindex));
                
                %% calculate number of doses given to 16-65 (excluding carers)
                total_vaccinated_asreported(yearindex)  =  sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Vaccinated)) - ...
                                                           sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated));
                total_registered_asreported(yearindex)  =  sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Registered)) - ...
                                                           sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered));
                          
                %% calculating over-reporting due to co-morbidity data entry
                overcountingfactor_vaccinated(yearindex) = riskgroupsreported_vaccinated(yearindex) ./ total_vaccinated_asreported(yearindex);
                overcountingfactor_registered(yearindex) = riskgroupsreported_registered(yearindex) ./ total_registered_asreported(yearindex);
                
                %% reduce total vaccinated, registered by this over reporting factor, for 16-65 years noncarers
                array_vac(2:(end-1),yearindex) = array_vac(2:(end-1),yearindex) / overcountingfactor_vaccinated(yearindex);
                array_reg(2:(end-1),yearindex) = array_reg(2:(end-1),yearindex) / overcountingfactor_registered(yearindex);
                
                % add up total doses
                TOTALreg(yearindex) = sum(array_reg(:,yearindex));
                TOTALvac(yearindex) = sum(array_vac(:,yearindex));
                frac_vac(:,yearindex) = array_vac(:,yearindex) ./ array_reg(:,yearindex);
                dist_vac(:,yearindex) = array_vac(:,yearindex) / TOTALvac(yearindex);
                
                prop_vac(:,yearindex) = array_vac(:,yearindex)./array_reg(:,yearindex);
        %% pharmacy data
        if strcmpi(years, '2013_2014')


               % label inclusion criteria
               datafilePH.Inclusion = cellfun(f.setInclusion, ...
                                        datafilePH.Inclusion1, datafilePH.Inclusion2,...
                                        'UniformOutput', false);
                 
                phmapped = cellfun( f.replaceLabel, datafilePH.Inclusion,...
                                            'UniformOutput', false);
  
            
                for risk = Fields
                    risk_char = risk{1};
                    dosecount.(risk_char) = sum(  cellfun( @(riskname, reference)strcmpi(strtrim(riskname), strtrim(reference)),...
                                                    phmapped, repmat({risk_char}, size(phmapped, 1), size(phmapped, 2))));
                end

                pharm_vac = struct2array(dosecount);
                
                % fraction of doses administered at pharmacy
                frac_atpharm = pharm_vac' ./ array_vac(:,yearindex);
                frac_totatpharm = pharm_vac' ./ array_reg(:,yearindex);
                
                % calulate number of "Other" type of doses
                others = sum(ismember(phmapped, 'Other'));
                oo = sprintf('Number of doses at pharmacies given to "others" in 2013/14: %g (%.0f%%)', others, 100*others/size(phmapped,1));
                disp(oo)
                
            
        end
        
       
    end
    
    % sort output
    [frac_vac_sort sortindex] = sortrows(frac_vac, 4);
    frac_vac_sort = frac_vac_sort(end:-1:1,:);
    sortindex = sortindex(end:-1:1);
    
    dist_vac_sort = dist_vac(sortindex,:);
    frac_atpharm_sort = frac_atpharm(sortindex);
    frac_totatpharm_sort = frac_totatpharm(sortindex);
    
    labels = cellfun(f.removeCondition, Fields, 'UniformOutput', false);
    labels_sort = labels(sortindex);
    
    titlesize = 20;
    labelsize = 16;
    plotwidth = 0.41;
    plotheight = 0.40;
    leftmargin = 0.1;
    bottommargin = 0.09;
    columnspace = 0.03;
    rowspace = 0.07;
   
    fig = figure;
        %set(fig, 'Position', [100 100 1600 900]);
        ss = get(0,'screensize');
        set(gcf,'position',...
                 [100, 100, ss(3), ss(4)]);
    % axes position
    ax(1) = axes('Position',  [leftmargin,                       bottommargin+plotheight+rowspace,    plotwidth, plotheight]);
    ax(2) = axes('Position',  [leftmargin+columnspace+plotwidth, bottommargin+plotheight+rowspace,    plotwidth, plotheight]);
    ax(3) = axes('Position',  [leftmargin,                       bottommargin,                        2*plotwidth + columnspace, plotheight]);    
    
    
    %% TOP LEFT (fraction of Doses administered at pharmacy)
    axes(ax(1));
    hold on;
    h = bar(frac_atpharm_sort);
    set(h, 'FaceColor', [0.8 0.8 1.0]);
    set(gca, 'XTickLabel', {}, 'FontSize', labelsize)
    xlim([0 11])
    text(1:length(labels_sort),...
            zeros(1,length(labels_sort)), ...
            labels_sort, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',20,...
            'FontSize', labelsize)
         box off;
    title('Fraction of doses administered at pharmacy (2013-4)', 'FontSize', titlesize)
           
    %% TOP LEFT (fraction of risk groups administered vaccine at pharmacy)
    %% inset histogram
    axes(ax(2))
%                 rax = get(gca, 'Position');
%                 axes('Position', [rax(1)+0.1*rax(4) rax(2)+0.25*rax(3) 0.35*rax(3) 0.5*rax(4)]);
    h1 = bar(frac_totatpharm_sort);
    set(h1, 'FaceColor', [0.8 0.8 1.0]);
    set(gca, 'XTickLabel', {}, 'FontSize', labelsize)
     xlim([0 11])
    text(1:length(labels_sort),...
            zeros(1,length(labels_sort)), ...
            labels_sort, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',20,...
            'FontSize', labelsize)
%                 hq = findobj(gca,'Type','patch');
%                 hq.FaceColor = [0.8, 0.8, 0.9];
                title('Fraction of registered patients receiving dose at pharmacy (2013-4)', 'FontSize', titlesize)
                box off;
               
%         hold on;
%         bar(frac_vac_sort)
%         set(gca, 'XTickLabel', {}, 'FontSize', 14)
%         xlim([0 11])
%         ylabel('Fraction of risk group vaccinated', 'FontSize', labelsize)
    
%% BOTTOM (vaccine uptake by risk group)
    axes(ax(3));
    hold on;
    bar(frac_vac_sort)
    %bar(dist_vac_sort)
    set(gca, 'XTickLabel', {},  'FontSize', 18)
    text(1:length(labels_sort),...
            zeros(1,length(labels_sort)), ...
            labels_sort, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',20,...
            'FontSize', 18)
    title('Fraction of registered patients vaccinated', 'FontSize', titlesize)
   % title('Distribution of vaccine allocation', 'FontSize', 20)
    xlim([0 11])
    ylim([0 1.2])
    set(gca, 'YTick', 0:0.25:1.0)
    leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP & Pharmacy)');
    set(leg, 'Location', 'NorthWest', 'FontSize', 18)
    legend('boxoff')
                %% inset histogram
                rax = get(gca, 'Position');
                axes('Position', [rax(1)+1.3*rax(4) rax(2)+0.25*rax(3) 0.35*rax(3) 0.4*rax(4)]);
                
                bar(dist_vac_sort)
                %bar(frac_vac_sort)
                set(gca, 'XTickLabel', {}, 'FontSize', 14)
                text(1:length(labels_sort),...
                        zeros(1,length(labels_sort)), ...
                        labels_sort, ...
                        'VerticalAlign','top',...
                        'HorizontalAlign','right',...
                        'Rotation',20,...
                        'FontSize', 14)
%                 hq = findobj(gca,'Type','patch');
%                 hq.FaceColor = [0.8, 0.8, 0.9];
               % title('Fraction of registered patients vaccinated', 'FontSize', titlesize)
               title('Distribution of total vaccine dose allocation', 'FontSize', 20)
                box off;
                xlim([0 11])
                
                
        %% output stats
        testx1 = prop_vac(:,3)-prop_vac(:,2); %difference between 2011-2 and 2012-13
        testx2 = prop_vac(:,4)-prop_vac(:,3); %difference between 2012-3 and 2013-14
        [h1,p1,ci1,stats1] = ttest(testx1)
        [h2,p2,ci2,stats2] = ttest(testx2)
end

