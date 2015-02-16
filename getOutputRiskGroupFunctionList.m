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
    [frac_vac_sort sortindex] = sortrows(frac_vac, 'descend', 1);
    dist_vac_sort = dist_vac(sortindex);
    labels = cellfun(f.removeCondition, Fields, 'UniformOutput', false);
    labels_sort = labels(sortindex);
    subplot(2,1,1)
    bar(frac_vac)
    subplot(2,1,2)
    bar(dist_vac)
    set(gca, 'XTickLabel', {})
    text(1:length(labels_sort),...
            zeros(1,length(labels_sort)), ...
            labels_sort, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',20)

end