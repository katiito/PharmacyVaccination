function outputs = getOutputRiskGroupFunctionList()

outputs.plotUptakebyRisk = @plotUptakebyRisk;

end



function plotUptakebyRisk(year1data, year2data, year3data, year4data, year5data, year4pharmdata, f)
    

    % loop through years to 
    yearindex = 0;
    for years = {'2010_2011', '2011_2012', '2012_2013', '2013_2014', '2014_2015'}   
        years = years{1};
        yearindex = yearindex + 1;
        
        % pick the year
        if strcmp(years, '2010_2011')
            datafileGP = year1data;
            datafileGP.PatientswithChronicNeurologicalDisease = f.CombineNeuro(...
                                            datafileGP.PatientswithChronicNeurologicalDisease,...
                                            datafileGP.PatientswithStrokeTransientIschaemicAttackTIA);
                                            
            datafileGP = rmfield(datafileGP, 'PatientswithStrokeTransientIschaemicAttackTIA');
            
            array_vac = zeros(10,4);
            array_reg = zeros(10,4);
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
        else
            datafileGP = year5data;
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
        if ~strcmp(years, '2014_2015')
            for fld = Fields
                  fld = char(fld{1});
                  % add up the elderly
                  if strcmpi(fld, 'Elderly')
                    total_vac{yearindex}.Elderly  =  sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Vaccinated));
                    total_reg{yearindex}.Elderly = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Registered));
                  % add in pregnant women
                  elseif strcmpi(fld, 'PregnantWomen')
                      total_vac{yearindex}.PregnantWomenRiskGroup = sum(f.removeNaN(datafileGP.(fld).PregnantandINaclinicalriskgroup.Vaccinated));
                      total_reg{yearindex}.PregnantWomenRiskGroup = sum(f.removeNaN(datafileGP.(fld).PregnantandINaclinicalriskgroup.Registered));
                      total_vac{yearindex}.PregnantWomenNotRiskGroup = sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Vaccinated));
                      total_reg{yearindex}.PregnantWomenNotRiskGroup = sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Registered));
                  % add in carers in whatever capacity
                  elseif strcmpi(fld, 'Carers')
                       total_vac{yearindex}.Carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated));
                       total_reg{yearindex}.Carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Registered));
                  % add in everyone else under risk group 
                  else
                    total_vac{yearindex}.(fld)  =   sum(f.removeNaN(datafileGP.(fld).aged16tounder65.Vaccinated)); 
                                                    %sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Vaccinated))+...   
                                                    % sum(f.removeNaN(datafileGP.(fld).aged2yearstounder16years.Vaccinated))+...
                                        
                    total_reg{yearindex}.(fld) = sum(f.removeNaN(datafileGP.(fld).aged16tounder65.Registered));
                                                %sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Registered))+...  
                                      % sum(f.removeNaN(datafileGP.(fld).aged2yearstounder16years.Registered))+...        
                  end
            end
        else
            for fld = Fields
                  fld = char(fld{1});
                  % add up the elderly
                  if strcmpi(fld, 'Elderly')
                    total_vac{yearindex}.Elderly  =  sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Vaccinated));
                    total_reg{yearindex}.Elderly = sum(f.removeNaN(datafileGP.Allpatients.aged65andover.Registered));
                  % add in pregnant women
                  elseif strcmpi(fld, 'PregnantWomen')
                      total_vac{yearindex}.PregnantWomenRiskGroup = 0; %sum(f.removeNaN(datafileGP.(fld).PregnantandINaclinicalriskgroup.Vaccinated));
                      total_reg{yearindex}.PregnantWomenRiskGroup = 0; %sum(f.removeNaN(datafileGP.(fld).PregnantandINaclinicalriskgroup.Registered));
                      total_vac{yearindex}.PregnantWomenNotRiskGroup = 0; %sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Vaccinated));
                      total_reg{yearindex}.PregnantWomenNotRiskGroup = 0; %sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Registered));
                  % add in carers in whatever capacity
                  elseif strcmpi(fld, 'Carers')
                       total_vac{yearindex}.Carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated));
                       total_reg{yearindex}.Carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Registered));
                  % add in everyone else under risk group 
                  else
                    total_vac{yearindex}.(fld)  =  sum(f.removeNaN(datafileGP.(fld).aged16tounder65years.Vaccinated));
%                                             sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Vaccinated))+...       
%                                          sum(f.removeNaN(datafileGP.(fld).aged2yearstounder5years.Vaccinated))+...
%                                          sum(f.removeNaN(datafileGP.(fld).aged5yearstounder16years.Vaccinated))+...
                                         
                    total_reg{yearindex}.(fld) = sum(f.removeNaN(datafileGP.(fld).aged16tounder65years.Registered));
%                                                  sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Registered))+...
%                                        sum(f.removeNaN(datafileGP.(fld).aged2yearstounder5years.Registered))+...
%                                        sum(f.removeNaN(datafileGP.(fld).aged5yearstounder16years.Registered))+...
                                       
                  end
            end
            
        end
                % combine all entries for total in risk groups
       
                array_vac_uncombined(:,yearindex) = struct2array(total_vac{yearindex});
                array_reg_uncombined(:,yearindex) = struct2array(total_reg{yearindex});
                
                

                %% calculate totals (excluding elderly , pregnant women (not risk group), and carers)
                riskgroupsreported_vaccinated(yearindex) = sum(array_vac_uncombined(2:(end-2),yearindex));
                riskgroupsreported_registered(yearindex) = sum(array_reg_uncombined(2:(end-2),yearindex));
                
                %% calculate number of doses given to 16-65 (excluding carers, and pregnant women)
        if ~strcmp(years, '2014_2015')         
                    total_vaccinated_asreported(yearindex)  =  sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Vaccinated)) - ...
                                                               sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Vaccinated)) - ...
                                                               sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated));
                    total_registered_asreported(yearindex)  =  sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16tounder65.Registered)) - ...
                                                               sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Registered)) - ...
                                                               sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered));
        else
                    total_vaccinated_asreported(yearindex)  =  sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16yearstounder65years.Vaccinated)) - ...
                                                               sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated));
                                                               %sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Vaccinated)) - 
                                                               
                    total_registered_asreported(yearindex)  =  sum(f.removeNaN(datafileGP.TotalAtRiskpatients.aged16yearstounder65years.Registered)) - ...
                                                               sum(f.removeNaN(datafileGP.Carers.agedunder65notatriskwhofulfilthecarerdefinition.Registered));
                                                               %sum(f.removeNaN(datafileGP.PregnantWomen.PregnantandNOTINaclinicalriskgroup.Registered)) - 
                                                               
        end
                %% calculating over-reporting due to co-morbidity data entry
                %overcountingfactor_vaccinated(yearindex) = riskgroupsreported_vaccinated(yearindex) ./ total_vaccinated_asreported(yearindex);
                overcountingfactor_registered(yearindex) = riskgroupsreported_registered(yearindex) ./ total_registered_asreported(yearindex);
                
                %% reduce total vaccinated, registered by this over reporting factor, for 16-65 years noncarers nonpregnant(non risk)
                array_vac_uncombined(2:(end-2),yearindex) = array_vac_uncombined(2:(end-2),yearindex) / overcountingfactor_registered(yearindex);
                array_reg_uncombined(2:(end-2),yearindex) = array_reg_uncombined(2:(end-2),yearindex) / overcountingfactor_registered(yearindex);
                
                %% set as new variable so can combined
                array_vac(1:(end-2),yearindex) = array_vac_uncombined(1:(end-3),yearindex);
                array_vac(end-1, yearindex) = array_vac_uncombined(end-2,yearindex) + array_vac_uncombined(end-1,yearindex);
                array_vac(end, yearindex) = array_vac_uncombined(end,yearindex);
                
                array_reg(1:(end-2),yearindex) = array_reg_uncombined(1:(end-3),yearindex);
                array_reg(end-1, yearindex) = array_reg_uncombined(end-2,yearindex) + array_reg_uncombined(end-1,yearindex);
                array_reg(end, yearindex) = array_reg_uncombined(end,yearindex);
                
%                 %% combined pregnant women again
%                 array_vac(end-1, yearindex) = array_vac(end-1, yearindex) + array_vac(end-2, yearindex); 
%                 array_vac(end-2, yearindex) = [];
%                 array_reg(end-1, yearindex) = array_reg(end-1, yearindex) + array_reg(end-2, yearindex); 
%                 array_reg(end-2, yearindex) = [];
                
                
                % add up total doses
                TOTALreg(yearindex) = sum(array_reg(:,yearindex));
                TOTALvac(yearindex) = sum(array_vac(:,yearindex));
                frac_vac(:,yearindex) = array_vac(:,yearindex) ./ array_reg(:,yearindex);
                dist_vac(:,yearindex) = array_vac(:,yearindex) / TOTALvac(yearindex);
                
                %prop_vac(:,yearindex) = array_vac(:,yearindex)./array_reg(:,yearindex);
                
                % sds
                frac_vac_sd(:,yearindex) = sqrt(frac_vac(:,yearindex).*(1-frac_vac(:,yearindex))./array_reg(:,yearindex));
                dist_vac_sd = sqrt(dist_vac(:,yearindex).*(1-dist_vac(:,yearindex))/TOTALvac(yearindex));
                
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
                
                frac_atpharm_sd = sqrt(frac_atpharm.*(1-frac_atpharm)/array_vac(:,yearindex));
                frac_totatpharm_sd = sqrt(frac_totatpharm.*(1-frac_totatpharm)/array_reg(:,yearindex));
                
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
    
    frac_vac_sort_sd = frac_vac_sd(sortindex,:);
    dist_vac_sort_sd = dist_vac_sd(sortindex,:);
    frac_atpharm_sort_sd = frac_atpharm_sd(sortindex);
    frac_totatpharm_sort_sd = frac_totatpharm_sd(sortindex);
    
    % sds for metrics
    
    
    
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
    title('a) Fraction of doses administered at pharmacy (2013-4)', 'FontSize', titlesize)
      x = get(h, 'XData');
    plot([x; x], [frac_atpharm_sort-1.96*frac_atpharm_sort_sd frac_atpharm_sort+1.96*frac_atpharm_sort_sd]', 'k-');
    
    
    %% TOP LEFT (fraction of risk groups administered vaccine at pharmacy)
    %% inset histogram
    axes(ax(2))
    hold on;
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
                title('b) Fraction of registered patients receiving dose at pharmacy (2013-4)', 'FontSize', titlesize)
                box off;
    x = get(h1, 'XData');
    plot([x; x], [frac_totatpharm_sort-1.96*frac_totatpharm_sort_sd frac_totatpharm_sort+1.96*frac_totatpharm_sort_sd]', 'k-');           
%         hold on;
%         bar(frac_vac_sort)
%         set(gca, 'XTickLabel', {}, 'FontSize', 14)
%         xlim([0 11])
%         ylabel('Fraction of risk group vaccinated', 'FontSize', labelsize)
    
%% BOTTOM (vaccine uptake by risk group)
    axes(ax(3));
    hold on;
    h2 = bar(frac_vac_sort);
    %bar(dist_vac_sort)
    set(gca, 'XTickLabel', {},  'FontSize', 18)
    text(1:length(labels_sort),...
            zeros(1,length(labels_sort)), ...
            labels_sort, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',20,...
            'FontSize', 18)
    title('c) Fraction of registered patients vaccinated', 'FontSize', titlesize)
   % title('Distribution of vaccine allocation', 'FontSize', 20)
    xlim([0 11])
    ylim([0 1.2])
    set(gca, 'YTick', 0:0.25:1.0)
    leg = legend('2010-11 (GP)', '2011-12 (GP)', '2012-13 (GP)', '2013-14 (GP & Pharmacy)', '2014-15 (GP & Pharmacy)');
    set(leg, 'Location', 'NorthWest', 'FontSize', 18)
    legend('boxoff')
    numgroups = size(frac_vac_sort, 1);
    numbars = size(frac_vac_sort, 2);
    groupwidth = min(0.8, numbars/(numbars+1.5));
    for i = 1:numbars
            % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
            x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
            plot([x; x], [frac_vac_sort(:,i)-1.96*frac_vac_sort_sd(:,i) frac_vac_sort(:,i)+1.96*frac_vac_sort_sd(:,i)]', 'k-');
            %e = errorbar(x, allarray(:,i), allsd(:,i), 'k', 'linestyle', 'none');
            %errorbar_tick(e,80);
    end
                %% inset histogram
                rax = get(gca, 'Position');
                axes('Position', [rax(1)+1.35*rax(4) rax(2)+0.26*rax(3) 0.35*rax(3) 0.4*rax(4)]);
                
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
        testx1 = frac_vac(:,3)-frac_vac(:,2); %difference between 2011-2 and 2012-13
        testx2 = frac_vac(:,4)-frac_vac(:,3); %difference between 2012-3 and 2013-14
        [h1,p1,ci1,stats1] = ttest(testx1)
        [h2,p2,ci2,stats2] = ttest(testx2)
end

