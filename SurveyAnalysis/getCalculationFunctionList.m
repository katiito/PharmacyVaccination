function cost = getCalculationFunctionList()


    cost.CalculateAdminCost = @CalculateAdminCost;


end


function cost = CalculateAdminCost(data, func)

    %initialization
    total_number_responses = size(data.ID,1);
    for i = 1:2
        individual_costs{i} = zeros(total_number_responses, 1);
    end
    % fridge, gauze/tape, waste disposal, waste removal, hire asst (per hour), hire dispenser (per hour),
    % hire pharmacist (per hour)
    costs = [200, 50, 100, 100, 0, 0, 0];
    % asst, disp/technician, pharmacist, pre-reg, 
    annual_salary = [20000, 25000, 30000, 40000];
    salary_per_min = annual_salary / (365.25*24*60);
    
    %% new purchases
    newPurchases = func.countEntries(data.Purchases, 'true');
    allfields = fields(data.Purchases)';
    %remove final field (hours per week of new hire)
    allfields(end) = [];
    index = 0;
    % loop through costs, adding to individuals
    for fld = allfields
        fld = fld{1};
        index = index + 1;
        individual_costs{1} = individual_costs{1} + (costs(index) * newPurchases.(fld));
    end
    
    %% procurement
    personnelBuying = func.countEntries(data.WhoBuys, 'false');
    durationBuying = cell2mat(arrayfun(@func.zerotonan, data.HowLongBuying.Time,...
                                    'UniformOutput', false));
    allfields = fields(data.WhoBuys)';
    index = 0;
    for fld = allfields
        fld = fld{1};
        index = index + 1;
        individual_costs{2} = individual_costs{2} + (personnelBuying.(fld) .* salary_per_min(index) ) ;
    end
    % reimbursement paperwork
    
    % administering
    
    % inputting data
    
    
end