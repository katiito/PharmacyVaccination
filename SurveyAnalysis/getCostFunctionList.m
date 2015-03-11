function cost = getCostFunctionList()


    cost.CalculateAdminCost = @CalculateAdminCost;


end


function cost = CalculateAdminCost(data, func)

    %initialization
    total_number_responses = size(data.ID,1);
    for i = 1:5
        individual_costs_oneoff{i} = zeros(total_number_responses, 1);
        individual_costs_recurrent{i} = zeros(total_number_responses, 1);
        
    end
    % fridge, gauze/tape, waste facilities, waste removal, hire asst (per hour), hire dispenser (per hour),
    % hire pharmacist (per hour)
    costs = [200, 500, 2000, 100, 0, 0, 0];
    % asst, disp/technician, pharmacist, pre-reg, 
    annual_salary = [20000, 25000, 30000, 40000];
    salary_per_min = annual_salary / (365.25*24*60);
    number_of_doses_per_pharmacist = 95;
    yearsofdepreciation = 10;
    
    
    %% new purchases (One-offs & recurrents) [1]
    newPurchases = func.countEntries(data.Purchases, 'true');
    allfields = fields(data.Purchases)';
    %remove final field (hours per week of new hire)
    allfields(end) = [];
    index = 0;
    % loop through costs, adding to individuals
    for fld = allfields
        fld = fld{1};
        index = index + 1;
        if strcmp(fld, 'Wastesharpsremovalservices') 
            individual_costs_recurrent{1} = individual_costs_recurrent{1} + (costs(index) * newPurchases.(fld));
        elseif strcmp(fld, 'GauzeTapePlasters')
            individual_costs_recurrent{1} = individual_costs_recurrent{1} + (costs(index) * newPurchases.(fld));
        else
            individual_costs_oneoff{1} = individual_costs_oneoff{1} + (costs(index) * newPurchases.(fld));
        end
    end
    
    %% procurement (Whole Season) [2]
    personnelBuying = func.countEntries(data.WhoBuys, 'false');
    durationBuying = cell2mat(arrayfun(@func.zerotonan, data.HowLongBuying.Time,...
                                    'UniformOutput', false));
    allfields = fields(data.WhoBuys)';
    index = 0;
    for fld = allfields
        fld = fld{1};
        index = index + 1;
        individual_costs_recurrent{2} = individual_costs_recurrent{2} + (personnelBuying.(fld) .* salary_per_min(index) .* durationBuying ) ;
    end
    

    %% reimbursement (Whole Season) [3]
    personnelReimbursement = func.countEntries(data.WhoReimbursementPaperwork, 'false');
    durationReimbursement = cell2mat(arrayfun(@func.zerotonan, data.HowLongReimbursement.Time,...
                                    'UniformOutput', false));
    allfields = fields(data.WhoReimbursementPaperwork)';
    index = 0;
    for fld = allfields
        fld = fld{1};
        index = index + 1;
        individual_costs_recurrent{3} = individual_costs_recurrent{3} + (personnelReimbursement.(fld) .* salary_per_min(index) .* durationReimbursement ) ;
    end
    
    
    %% administering (Whole Season) [4]
    personnelAdminister = func.countEntries(data.WhoAdministers, 'false');
    durationAdminister = cell2mat(arrayfun(@func.zerotonan, data.HowLongAdministers.Time,...
                                    'UniformOutput', false));
    allfields = fields(data.WhoAdministers)';
    index = 0;
    for fld = allfields
        fld = fld{1};
        index = index + 1;
        individual_costs_recurrent{4} = individual_costs_recurrent{4} + (personnelAdminister.(fld) .* salary_per_min(index) .* durationAdminister * number_of_doses_per_pharmacist) ;
    end
    
    
    % inputting data
    personnelInputting = func.countEntries(data.WhoInputsData, 'false');
    durationInputting = cell2mat(arrayfun(@func.zerotonan, data.HowLongInput.Time,...
                                    'UniformOutput', false));
    allfields = fields(data.WhoInputsData)';
    index = 0;
    for fld = allfields
        fld = fld{1};
        index = index + 1;
        individual_costs_recurrent{5} = individual_costs_recurrent{5} + (personnelInputting.(fld) .* salary_per_min(index) .* durationInputting) ;
    end
    
    
    combinedCosts_recurrentPerSeason_perpharmacy = sum(cell2mat(individual_costs_recurrent), 2);
    
    combinedCosts_oneoff_perpharmacy             = sum(cell2mat(individual_costs_oneoff), 2);
    combinedCosts_oneoff_perpharmacy_depreciated = combinedCosts_oneoff_perpharmacy / yearsofdepreciation;
    
    combinedCosts_pervaccinedose = (combinedCosts_oneoff_perpharmacy_depreciated + combinedCosts_recurrentPerSeason_perpharmacy) / number_of_doses_per_pharmacist;

    combinedCosts_pervaccinedose = combinedCosts_pervaccinedose(~isnan(combinedCosts_pervaccinedose));
    
    cost.combinedCosts_pervaccinedose = combinedCosts_pervaccinedose;
    
%     mean(combinedCosts)
%     median(combinedCosts)
%     std(combinedCosts)
    
end