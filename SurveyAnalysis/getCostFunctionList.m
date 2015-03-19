function cost = getCostFunctionList()


    cost.CalculateAdminCost = @CalculateAdminCost;


end


function cost = CalculateAdminCost(data, data_gp, func, year)
    

    % fridge, gauze/tape, waste facilities, waste removal, hire asst (per hour), hire dispenser (per hour),
    % hire pharmacist (per hour)
    costs = [570, 1.75, 0, 0, 0, 0, 0];
    % asst, disp/technician, pre-reg, pharmacist  (2013 annual salaries (pre-tax))
    annual_salary = [6.31*1589, 6.93*1589, 18440, 38610*1.19];
    salary_per_min = annual_salary / (1589*60);
    if strcmp(year, '2013_2014')
        number_of_doses_per_pharmacist = 95;
        number_doses = 68220;
        total_gp_doses = 1059538;
    elseif strcmp(year, '2014_2015')
        number_of_doses_per_pharmacist = 99;
        number_doses = 108186;
        total_gp_doses = 1124204;
    else
    end
    %number_of_pharmacies = number_doses / number_of_doses_per_pharmacist;
    yearsofdepreciation = 10;
    sonar_investment_cost = 36000;
    sonar_annual_cost = 12500;
    training_promotion_annual_cost = 450746;
    nhsadmincost_perdose = 7.51;
    nhsvaccinecost_perdose = 5.90*1.2;
    brands_list_prices = 1.2*[5.22 %Influvac (Abbott) XXXX
                          6.59 %Imuvac (Abbott) XXXX
                          9.94 %FluarixTetra (AstraZeneca) XXX
                          5.39 %Fluarix (AstraZeneca) XXX
                          6.59 %ImuvacMASTA XX (set same as Imuvac Abbott)
                          5.25 %Enzira (MASTA) XX (set same as Enzira Pfizer)
                          6.29 %InactivatedInfluenzavaccineBPMASTA XX (set same as SPMSD)
                          5.22 %InfluvacMASTA XX (set same as influvacc Abbott)
                          5.25 %CSLInactivatedInfluenzavaccineMASTA (set same as Enzira)
                          6.59 %AgrippalNovartis XXX
                          6.59 %OptafluNovartis XXX
                          5.25 %CSLInactivatedInfluenzavaccinePfizer (marketed as Enzira) XXX
                          5.25 %Enzira (Pfizer) XXX
                          6.29 %InactivatedInfluenzavaccineBPSanofiPasteurMSD XXX
                          9.05]; %IntanzaSanofiPasteurMSD XXX
    
    %initialization
    total_number_responses = size(data.ID,1);
    for i = 1:5
        individual_admincosts_pharmrecurrent{i} = zeros(total_number_responses, 1);  
    end
    for i = 1:1
        individual_admincosts_pharminvestment{i} = zeros(total_number_responses, 1);
    end
    for i=1:3
        admincosts_NHSrecurrent_perseason{i} = 0;
    end
    for i=1:3
        admincosts_NHSinvestment_perseason{i} = 0;
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
                                individual_admincosts_pharmrecurrent{1} = individual_admincosts_pharmrecurrent{1} + (costs(index) * newPurchases.(fld));
                            elseif strcmp(fld, 'GauzeTapePlasters')
                                individual_admincosts_pharmrecurrent{1} = individual_admincosts_pharmrecurrent{1} + (costs(index) * newPurchases.(fld));
                            else
                                individual_admincosts_pharminvestment{1} = individual_admincosts_pharminvestment{1} + (costs(index) * newPurchases.(fld) / yearsofdepreciation);
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
                            individual_admincosts_pharmrecurrent{2} = individual_admincosts_pharmrecurrent{2} + (personnelBuying.(fld) .* salary_per_min(index) .* durationBuying ) ;
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
                            individual_admincosts_pharmrecurrent{3} = individual_admincosts_pharmrecurrent{3} + (personnelReimbursement.(fld) .* salary_per_min(index) .* durationReimbursement ) ;
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
                            individual_admincosts_pharmrecurrent{4} = individual_admincosts_pharmrecurrent{4} + (personnelAdminister.(fld) .* salary_per_min(index+2) .* durationAdminister_perdose * number_of_doses_per_pharmacist) ;
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
                            individual_admincosts_pharmrecurrent{5} = individual_admincosts_pharmrecurrent{5} + (personnelInputting.(fld) .* salary_per_min(index) .* durationInputting_perdose * number_of_doses_per_pharmacist) ;
                        end
    %% SONAR DATA (NHS)
    admincosts_NHSrecurrent_perseason{1} = sonar_annual_cost;
    admincosts_NHSinvestment_perseason{1} = sonar_investment_cost / (0.5*yearsofdepreciation);
    
    %% TRAINING/ PROMOTION (NHS)
    admincosts_NHSrecurrent_perseason{2} = training_promotion_annual_cost;
    
    %% ADMINISTRATION REIMBURSEMENT (NHS)
    admincosts_NHSrecurrent_perseason{3} = number_doses * nhsadmincost_perdose;
    
    %% VACCINE PRICE (NHS) per dose
    vaccinecosts_NHSrecurrent_perdose =  nhsvaccinecost_perdose;
    
    %% VACCINE PRICE (PHARMACY)
    vaccinebrands = fields(data.Brand);
    vaccinebrands = vaccinebrands(1:(end-2)); %delete 'don't know and i'd rather not say'
    countbrands = func.convertToLogical(data.Brand, vaccinebrands);
    countbrandsarray = struct2array(countbrands)';
    cost_distribution = repmat(brands_list_prices, 1, size(countbrandsarray,2)) .* countbrandsarray;
    
    %% VACCINE PRICE (GP)
    vaccinebrands_gp = fields(data_gp.Brand);
    vaccinebrands_gp = vaccinebrands_gp(1:(end-2)); %delete 'don't know and i'd rather not say'
    
    
    for i=1:size(cost_distribution,2)
        %perpharmacycosts = [];
        indices = find(cost_distribution(:,i));
        averagecost_perdose(i) = mean(cost_distribution(indices,i));
    end
    
    allbrands = fields(data_gp.Brand)';
    allbrands = allbrands(1:(end-2));
        
        for brand = allbrands
            brand = brand{1}; 
            countgp.(brand) = func.sumUp(data_gp.Brand.(brand)); 
        end
        
        brandsarray_gp = struct2array(countgp);
        totals_gp = sum(brandsarray_gp);
        h_gp = brandsarray_gp / totals_gp;

        
    GP_vaccinecosts_perdose   =   sum(h_gp' .* brands_list_prices);
    out1 = sprintf('Purchase Reimbursement by NHS if administered via GP: £%.2f (won''t change from year to year)', GP_vaccinecosts_perdose);
    out2 = sprintf('Total Purchase Reimbursement by NHS if administered via GP (2013): £%.f (depends on total vaccs given by year)', GP_vaccinecosts_perdose*total_gp_doses);
    disp(out1)
    disp(out2)
    PHARMACY_vaccinecosts_perdose = averagecost_perdose';
    
     
    %% CALCULATE ADMIN COSTS per dose (PHARMACY)
    pharm2dose_f = @(arr) arr/number_of_doses_per_pharmacist;
    pharmacyrecurrent_nonpers_admincost_perdose = sum(cell2mat(cellfun(pharm2dose_f, individual_admincosts_pharmrecurrent(1), 'UniformOutput', false)),2); % 
    pharmacyrecurrent_pers_admincost_perdose =  sum(cell2mat(cellfun(pharm2dose_f, individual_admincosts_pharmrecurrent(2:end), 'UniformOutput', false)),2); 
    pharmacyinvestment_admincost_perdose = sum(cell2mat(cellfun(pharm2dose_f, individual_admincosts_pharminvestment, 'UniformOutput', false)),2);
    %pharmacyrecurrent_vaccinecost_perdose = ;
    
    PHARMACY_admincosts_perdose = pharmacyrecurrent_nonpers_admincost_perdose + ...
                                  pharmacyrecurrent_pers_admincost_perdose + ...
                                  pharmacyinvestment_admincost_perdose;
    
    %% CALCULATE ADMIN COSTS per dose (NHS)
    season2dose_f = @(arr) arr/number_doses;
    nhsrecurrent_admincost_perdose = sum(cellfun(season2dose_f,  admincosts_NHSrecurrent_perseason));
    nhsinvestment_admincost_perdose = sum(cellfun(season2dose_f, admincosts_NHSinvestment_perseason));
    
    NHS_admincosts_perdose = nhsrecurrent_admincost_perdose + ...
                                    nhsinvestment_admincost_perdose;

    
   
%     total_costtonhsperdose = totalrecurrent_nonpers_costperdose + totalrecurrent_pers_costperdose...
%                                 + totalinvestment_costperdose + nhsadministration_perdose; % cost to NHS

    
    
    %% SAVE COSTS: Admin (pharmacy & NHS) -- Vaccine (pharmacy & NHS)
    cost.PHARMACY_admincosts_perdose = PHARMACY_admincosts_perdose(~isnan(PHARMACY_admincosts_perdose));
    cost.PHARMACY_vaccinecosts_perdose = PHARMACY_vaccinecosts_perdose(~isnan(PHARMACY_vaccinecosts_perdose));
    cost.NHS_admincosts_perdose = NHS_admincosts_perdose(~isnan(NHS_admincosts_perdose));
    cost.NHS_vaccinecosts_perdose = vaccinecosts_NHSrecurrent_perdose(~isnan(vaccinecosts_NHSrecurrent_perdose));
    
    cost.NHS_reimbursementadmincosts_perdose = nhsadmincost_perdose(~isnan(nhsadmincost_perdose));
    
    %% subcosts
    cost.nhsrecurrent_admincost_perdose = nhsrecurrent_admincost_perdose(~isnan(nhsrecurrent_admincost_perdose));
    cost.nhsinvestment_admincost_perdose = nhsinvestment_admincost_perdose(~isnan(nhsinvestment_admincost_perdose));
    cost.pharmacyrecurrent_nonpers_admincost_perdose = pharmacyrecurrent_nonpers_admincost_perdose(~isnan(pharmacyrecurrent_nonpers_admincost_perdose));
    cost.pharmacyrecurrent_pers_admincost_perdose = pharmacyrecurrent_pers_admincost_perdose(~isnan(pharmacyrecurrent_pers_admincost_perdose));
    cost.pharmacyinvestment_admincost_perdose = pharmacyinvestment_admincost_perdose(~isnan(pharmacyinvestment_admincost_perdose));
    
    
    cost.timeuse_durationBuying = durationBuying(~isnan(durationBuying));
    cost.timeuse_durationReimbursement = durationReimbursement(~isnan(durationReimbursement));
    cost.timeuse_durationAdminister_perdose = durationAdminister_perdose(~isnan(durationAdminister_perdose));
    cost.timeuse_durationInputting_perdose = durationInputting_perdose(~isnan(durationInputting_perdose));
%     cost.totalrecurrent_nonpers_costperdose = totalrecurrent_nonpers_costperdose(~isnan(totalrecurrent_nonpers_costperdose));
%     cost.totalrecurrent_pers_costperdose = totalrecurrent_pers_costperdose(~isnan(totalrecurrent_pers_costperdose));
%     cost.totalinvestment_costperdose = totalinvestment_costperdose(~isnan(totalinvestment_costperdose));
%     cost.totalcosttopharmacy_perdose = totalcosttopharmacy_perdose(~isnan(totalcosttopharmacy_perdose));
%     cost.totalcosttonhs_perdose = total_costtonhsperdose(~isnan(total_costtonhsperdose));
    
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