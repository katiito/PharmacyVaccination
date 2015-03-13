function cost = getCostFunctionList()


    cost.CalculateAdminCost = @CalculateAdminCost;


end


function cost = CalculateAdminCost(data, func)
    

    % fridge, gauze/tape, waste facilities, waste removal, hire asst (per hour), hire dispenser (per hour),
    % hire pharmacist (per hour)
    costs = [570, 1.75, 0, 0, 0, 0, 0];
    % asst, disp/technician, pharmacist, pre-reg, (2013 salaries)
    annual_salary = [6.31*1589, 6.93*1589, 38610*1.19, 18440];
    salary_per_min = annual_salary / (1589*60);
    number_of_doses_per_pharmacist = 95;
    number_doses = 68220;
    number_of_pharmacies = number_doses / number_of_doses_per_pharmacist;
    yearsofdepreciation = 10;
    sonar_investment_cost = 36000;
    sonar_annual_cost = 12500;
    training_promotion_annual_cost = 450746;

    %initialization
    total_number_responses = size(data.ID,1);
    for i = 1:7
        individual_costs_recurrent{i} = zeros(total_number_responses, 1);  
    end
    for i = 1:2
        individual_costs_investment{i} = zeros(total_number_responses, 1);
    end
    
    %% REIMBURSEMENT COSTS
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
                                individual_costs_investment{1} = individual_costs_investment{1} + (costs(index) * newPurchases.(fld) / yearsofdepreciation);
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
                        durationAdminister_perdose = cell2mat(arrayfun(@func.zerotonan, data.HowLongAdministers.Time,...
                                                        'UniformOutput', false));
                        allfields = fields(data.WhoAdministers)';
                        index = 0;
                        for fld = allfields
                            fld = fld{1};
                            index = index + 1;
                            individual_costs_recurrent{4} = individual_costs_recurrent{4} + (personnelAdminister.(fld) .* salary_per_min(index) .* durationAdminister_perdose * number_of_doses_per_pharmacist) ;
                        end


                        %% inputting data (Whole season)
                        personnelInputting = func.countEntries(data.WhoInputsData, 'false');
                        durationInputting_perdose = cell2mat(arrayfun(@func.zerotonan, data.HowLongInput.Time,...
                                                        'UniformOutput', false));
                        allfields = fields(data.WhoInputsData)';
                        index = 0;
                        for fld = allfields
                            fld = fld{1};
                            index = index + 1;
                            individual_costs_recurrent{5} = individual_costs_recurrent{5} + (personnelInputting.(fld) .* salary_per_min(index) .* durationInputting_perdose * number_of_doses_per_pharmacist) ;
                        end
    %% SONAR DATA
    sonar_recurrentcosts_perpharmacy = repmat(sonar_annual_cost / number_of_pharmacies, total_number_responses, 1);
    sonar_investcosts_perpharmacy = repmat(sonar_investment_cost / (number_of_pharmacies * 0.5*yearsofdepreciation), total_number_responses, 1);
    individual_costs_recurrent{6} = sonar_recurrentcosts_perpharmacy;
    individual_costs_investment{2} = sonar_investcosts_perpharmacy;
    
    %% TRAINING/ PROMOTION
    training_promotion_recurrentcosts_perpharmacy = repmat(training_promotion_annual_cost / number_of_pharmacies, total_number_responses, 1); 
    individual_costs_recurrent{7} = training_promotion_recurrentcosts_perpharmacy;
    
    %% VACCINE PRICE
    price_perpharmacy = function of costs of vaccines and proportion choosing vaccine
    
    %% split up costs per dose and combine
    perdose_f = @(arr) arr/number_of_doses_per_pharmacist;
    recurrent_nonpers_cost_perdose = cellfun(perdose_f, individual_costs_recurrent([1,(end-1):end]), 'UniformOutput', false); % 
    recurrent_pers_cost_perdose =  cellfun(perdose_f, individual_costs_recurrent(2:(end-2)), 'UniformOutput', false); 
    investmentcost_perdose = cellfun(perdose_f, individual_costs_investment, 'UniformOutput', false);
    vaccinecost_perdose = cellfun(perdose_f, price_perpharmacy, 'UniformOutput', false);
    
    totalrecurrent_nonpers_costperdose = sum(cell2mat(recurrent_nonpers_cost_perdose), 2);
    totalrecurrent_pers_costperdose = sum(cell2mat(recurrent_pers_cost_perdose), 2);
    totalinvestment_costperdose = sum(cell2mat(investmentcost_perdose), 2);
    total_costperdose = totalrecurrent_nonpers_costperdose + totalrecurrent_pers_costperdose + totalinvestment_costperdose + ; % cost to NHS
    
    %% reimbursement costs for pharmacies: fridge {investment -- 1}, gauze {recurrent (np) -- 1}, personnel {recurrent (p) -- all}, 
    total_costtopharmacy_perdose = investmentcost_perdose{1} + recurrent_nonpers_cost_perdose{1} + totalrecurrent_pers_costperdose;
    
    
    cost.totalrecurrent_nonpers_costperdose = totalrecurrent_nonpers_costperdose;
    cost.totalrecurrent_pers_costperdose = totalrecurrent_pers_costperdose;
    cost.totalinvestment_costperdose = totalinvestment_costperdose;
    cost.totalreimbursement_costperdose = totalreimbursement_costperdose;
    cost.total_costperdose = total_costperdose;
    
%     combinedCosts_recurrentPerSeason_perpharmacy = sum(cell2mat(individual_costs_recurrent), 2);
%     
%     combinedCosts_investment_perpharmacy             = sum(cell2mat(individual_costs_investment), 2);
%     
%     combinedCosts_pervaccinedose = (combinedCosts_investment_perpharmacy + combinedCosts_recurrentPerSeason_perpharmacy) / number_of_doses_per_pharmacist;
% 
%     combinedCosts_pervaccinedose = combinedCosts_pervaccinedose(~isnan(combinedCosts_pervaccinedose));
%     
%     cost.combinedCosts_pervaccinedose = combinedCosts_pervaccinedose;
%     
%     mean(combinedCosts)
%     median(combinedCosts)
%     std(combinedCosts)
    
end