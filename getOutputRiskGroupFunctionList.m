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
        
        Fields = {'Allpatients',...
                  'PatientswithChronicHeartDisease',...
                  'PatientswithChronicRespiratoryDisease',...
                  'PatientswithChronicKidneyDisease',...
                  'PatientswithChronicLiverDisease',...
                  'PatientswithDiabetes',...
                  'PatientswithImmunosuppression',...
                  'PatientswithChronicNeurologicalDisease',...
                  'PregnantWomen',...
                  'Carers'};

        for index = 1:size(Fields,2)
              fld = char(Fields{index});
              if strcmpi(fld, 'Allpatients')
                total_vac{yearindex}.elderly  =  sum(f.removeNaN(datafileGP.(fld).aged65andover.Vaccinated));
                total_reg{yearindex}.elderly = sum(f.removeNaN(datafileGP.(fld).aged65andover.Registered));
              elseif strcmpi(fld, 'PregnantWomen')
                  total_vac{yearindex}.pregnantwomen = sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Vaccinated));
                  total_reg{yearindex}.pregnantwomen = sum(f.removeNaN(datafileGP.(fld).PregnantandNOTINaclinicalriskgroup.Registered));
              elseif strcmpi(fld, 'Carers')
                   total_vac{yearindex}.carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Vaccinated));
                   total_reg{yearindex}.carers = sum(f.removeNaN(datafileGP.(fld).agedunder65notatriskwhofulfilthecarerdefinition.Registered));
              else
                total_vac{yearindex}.(fld)  =  sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Vaccinated))+...
                                     sum(f.removeNaN(datafileGP.(fld).aged2yearstounder16years.Vaccinated))+...
                                     sum(f.removeNaN(datafileGP.(fld).aged16tounder65.Vaccinated));
                total_reg{yearindex}.(fld) = sum(f.removeNaN(datafileGP.(fld).aged6monthstounder2years.Registered))+...
                                   sum(f.removeNaN(datafileGP.(fld).aged2yearstounder16years.Registered))+...
                                   sum(f.removeNaN(datafileGP.(fld).aged16tounder65.Registered));
              end
        end
        
        % combine all entries
        array_vac(:,yearindex) = struct2array(total_vac{yearindex});
        array_reg(:,yearindex) = struct2array(total_reg{yearindex});
        TOTALreg(yearindex) = sum(array_reg(:,yearindex));
        TOTALvac(yearindex) = sum(array_vac(:,yearindex));
        frac_vac(:,yearindex) = array_vac(:,yearindex) / TOTALreg(yearindex);
        dist_vac(:,yearindex) = array_vac(:,yearindex) / TOTALvac(yearindex);
    end
    
    % sort output
    [frac_vac_sort sortindex] = sortrows(frac_vac);
    frac_vac_sort = frac_vac_sort(end:-1:1,:);
    sortindex = sortindex(end:-1:1);
    dist_vac_sort = dist_vac(sortindex,:);
    labels = cellfun(f.removeCondition, Fields, 'UniformOutput', false);
    labels_sort = labels(sortindex);
    
    leftmargin = 0.1;
    bottommargin = 0.1;
    plotheight = 0.4;
    plotwidth = 0.8;
    rowspace = 0.05;
   
    fig = figure;
        %set(fig, 'Position', [100 100 1600 900]);
        ss = get(0,'screensize');
        set(gcf,'position',...
                 [100, 100, ss(3), ss(4)]);
    % axes position
    ax(1) = axes('Position',  [leftmargin, bottommargin+plotheight+rowspace,    plotwidth, plotheight]);
    ax(2) = axes('Position',  [leftmargin, bottommargin,                        plotwidth, plotheight]);
        
    
    axes(ax(1));
    hold on;
    bar(frac_vac_sort)
    set(gca, 'XTickLabel', {}, 'FontSize', 14)
    xlim([0 11])
    ylabel('w')
    
    axes(ax(2));
    hold on;
    bar(dist_vac_sort)
    set(gca, 'XTickLabel', {},  'FontSize', 14)
    text(1:length(labels_sort),...
            zeros(1,length(labels_sort)), ...
            labels_sort, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',20,...
            'FontSize', 14)
    xlim([0 11])
end