function plots = getPlotFunctionList()

plots.plotOpinions = @plotOpinions;
plots.plotAwareness = @plotAwareness;
plots.plotBrands = @plotBrands;
plots.plotGPservice = @plotGPservice;
plots.plotCosts = @plotCosts;

end



function plotOpinions(pharmacydata, gpdata, f)


%% pharmacy data
allfields_pharm = fields(pharmacydata.PharmacyReasons)';
allfields_pharm(end) = [];
total_number_patients_pharm = size(pharmacydata.ID, 1);
for fld = allfields_pharm
   fld = fld{1};
   fracpharm.(fld) = f.sumUp(pharmacydata.PharmacyReasons.(fld)) / total_number_patients_pharm;
end

%% gp data
allfields_gp = fields(gpdata.GPReasons)';
allfields_gp(end) = [];
total_number_patients_gp = size(gpdata.ID, 1);
for fld = allfields_gp
   fld = fld{1};
   fracgp.(fld) = f.sumUp(gpdata.GPReasons.(fld)) / total_number_patients_gp;
end


plotarray_pharmacy = struct2array(fracpharm)';
pharmacyopinions = plotarray_pharmacy([6,7]);
plotarray_gp = struct2array(fracgp)';
gpopinions = plotarray_gp([3,5,6,9,10]);
combinedopinions = [plotarray_pharmacy([1,2,4,3,5]), plotarray_gp([1,2,7,4,8])];

% error bar calculations
pharmacyopinions_sd = sqrt(pharmacyopinions.*(1-pharmacyopinions)/total_number_patients_pharm);
gpopinions_sd = sqrt(gpopinions.*(1-gpopinions)/total_number_patients_gp);
combinedopinions_sd = sqrt(combinedopinions.*(1-combinedopinions)./repmat([total_number_patients_pharm, total_number_patients_gp],5,1));

% plot variables
close all
ticksize = 16;
titlesize = 20;
legendsize = 24;
fig = figure;
ss = get(0,'screensize');
set(gcf,'position',...
         [100, 100, ss(3), ss(4)]);
plotwidth = 0.41;
plotheight = 0.38;
leftmargin = 0.1;
%rightmargin = 0.05;
bottommargin = 0.1;
columnspace = 0.01;
rowspace = 0.08;
xlimits = [0 32];
ylimits = [0 1];
%top row
ax(1) = axes('Position',  [leftmargin,                           bottommargin+plotheight+rowspace, 2*plotwidth+columnspace, plotheight]);
ax(2) = axes('Position',  [leftmargin,                           bottommargin, 0.55*plotwidth, plotheight]);
ax(3) = axes('Position',  [leftmargin+0.55*plotwidth+columnspace,     bottommargin, 1.45*plotwidth, plotheight]);


x_ticks_combined = {'Improves choice for patients'
                    'More convenient for patients'
                    'Increases vaccine coverage'
                    'Eases burden on system'
                    'Increases burden on system'};
                
x_ticks_pharm = {'Leads to efficiency issues'
                 'Leads to healthcare provision issues'};

x_ticks_gp = {'Safety concerns'
              'Loss of patient healthcare opportunity'
              'Loss of patient healthcare continuity'
              'Loss of income for GPs'
              'Issues with reporting'};
%% bar plot
axes(ax(1))
hold on;
bar(combinedopinions)
%set(gca, 'XTick', 1:size(x_ticks_combined,2))
        
%         text(1:length(x_ticks_combined),...
%             zeros(1,length(x_ticks_combined)), ...
%             x_ticks_combined, ...
%             'VerticalAlign','top',...
%             'HorizontalAlign','right',...
%             'Rotation',45)
        leg = legend('Pharmacists','GPs');
        set(leg, 'Location', 'NorthEast', 'FontSize', legendsize)
        legend('boxoff')
        set(gca, 'FontSize', ticksize)
        title('a) Opinions of GPs and pharmacists regarding flu vaccine pharmacy initiative', 'FontSize', titlesize)
        ylabel('Fraction of respondents', 'FontSize', titlesize)
        %xlim(xlimits) 
        ylim(ylimits)
        box off
        set(gca, 'XTick', 1:size(x_ticks_combined,1))
        set(gca, 'XTickLabel', {})
        set(gca, 'XTickLabel', x_ticks_combined)
        numgroups = size(combinedopinions, 1);
        numbars = size(combinedopinions, 2);
        groupwidth = min(0.8, numbars/(numbars+1.5));
        
        for i = 1:numbars
            % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
            x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
            plot([x; x], [combinedopinions(:,i)-1.96*combinedopinions_sd(:,i) combinedopinions(:,i)+1.96*combinedopinions_sd(:,i)]', 'k-');
        end
        
        
        

axes(ax(2))
hold on;
h1 = bar(pharmacyopinions);
        set(gca, 'FontSize', ticksize)
        title('b) Opinions of pharmacists about the lack of access to patient records', 'FontSize', titlesize)
        %set(gca, 'XTick', 1:size(x_ticks_pharm,2))
%         text(1:length(x_ticks_pharm),...
%             zeros(1,length(x_ticks_pharm)), ...
%             x_ticks_pharm, ...
%             'VerticalAlign','top',...
%             'HorizontalAlign','right',...
%             'Rotation',45)
        box off
        ylim(ylimits)
        x = get(h1, 'XData');
        plot([x; x], [pharmacyopinions-1.96*pharmacyopinions_sd pharmacyopinions+1.96*pharmacyopinions_sd]', 'k-');
        set(gca, 'XTick', 1:size(x_ticks_pharm,1))
        set(gca, 'XTickLabel', {})
        set(gca, 'XTickLabel', x_ticks_pharm)
        ylabel('Fraction of respondents', 'FontSize', titlesize)

axes(ax(3))
hold on
h2 = bar(gpopinions, 'y');
        
        set(gca, 'FontSize', ticksize)
        title('c) Opinions of GPs regarding flu vaccine pharmacy initiative', 'FontSize', titlesize)
        box off
        ylim(ylimits)
        x = get(h2, 'XData');
        plot([x; x], [gpopinions-1.96*gpopinions_sd gpopinions+1.96*gpopinions_sd]', 'k-');
        set(gca, 'FontSize', ticksize)
        set(gca, 'XTick', 1:size(x_ticks_gp,1))
        set(gca, 'YTickLabel', {})
        set(gca, 'XTickLabel', {})
        set(gca, 'XTickLabel', x_ticks_gp)

%         text(1:length(x_ticks_gp),...
%             zeros(1,length(x_ticks_gp)), ...
%             x_ticks_gp, ...
%             'VerticalAlign','top',...
%             'HorizontalAlign','right',...
%             'Rotation',45)
        
end


function plotAwareness(pharmacydata, gpdata, f)

        total_number_patients_pharm = size(pharmacydata.ID, 1);
        total_number_patients_gp = size(gpdata.ID, 1);

        %% vaccination uptake is an issue (no / yes)
        numyes_pharm = f.sumUp(pharmacydata.UptakeProblem.Yes); 
        numno_pharm = f.sumUp(pharmacydata.UptakeProblem.No); 
  
        num_pharm_total = numyes_pharm + numno_pharm;
        
        numyes_gp    = f.sumUpVals(gpdata.UptakeProblem.Response, 'yes'); 
        numno_gp    = f.sumUpVals(gpdata.UptakeProblem.Response, 'no'); 

        num_gp_total = numyes_gp + numno_gp;
        
        fracyes_pharm = numyes_pharm / num_pharm_total;
        fracyes_gp    = numyes_gp / num_gp_total;

        problemarray = [fracyes_pharm, fracyes_gp]';
        problemarray_sd = sqrt(problemarray.*(1-problemarray)./[num_pharm_total; num_gp_total]);
        
        
        %% pharmacy vaccination is a good idea (yes / no / mixed opinions)
        PHnumyes_pharm = f.sumUp(pharmacydata.GoodIdea.Yesitisagoodidea);
        PHnumno_pharm = f.sumUp(pharmacydata.GoodIdea.Noitisnotagoodidea);
        PHnummb_pharm = f.sumUp(pharmacydata.GoodIdea.Mixedopinions);
        PHtotal_pharm = PHnumyes_pharm + PHnumno_pharm + PHnummb_pharm;
        PHfracyes_pharm = PHnumyes_pharm/PHtotal_pharm;
        PHfracno_pharm = PHnumno_pharm/PHtotal_pharm;
        PHfracmb_pharm = PHnummb_pharm/PHtotal_pharm;
        
        PHnumyes_gp = f.sumUpVals(gpdata.GoodIdea.Response, 'Yes, it is a good idea');
        PHnumno_gp = f.sumUpVals(gpdata.GoodIdea.Response, 'No, it is not a good idea');
        PHnummb_gp = f.sumUpVals(gpdata.GoodIdea.Response, 'Mixed opinions');
        PHtotal_gp = PHnumyes_gp + PHnumno_gp + PHnummb_gp;
        PHfracyes_gp = PHnumyes_gp/PHtotal_gp;
        PHfracno_gp = PHnumno_gp/PHtotal_gp;
        PHfracmb_gp = PHnummb_gp/PHtotal_gp;
        
        goodideaarray = [[PHfracyes_pharm  PHfracno_pharm PHfracmb_pharm]; [PHfracyes_gp  PHfracno_gp PHfracmb_gp]]';
        goodideaarray_sd = sqrt(goodideaarray.*(1-goodideaarray)./repmat([PHtotal_pharm, PHtotal_gp], 3, 1));
        
        
        %% inputting data easy (yes / no / mixed opinions)
        inputeasy_yes = f.sumUpVals(gpdata.EasyInput.Response, 'Yes');
        inputeasy_no = f.sumUpVals(gpdata.EasyInput.Response, 'No');
        inputeasy_mb = f.sumUpVals(gpdata.EasyInput.Response, 'Mixed Opinions');
        inputeasy_total = inputeasy_yes + inputeasy_no + inputeasy_mb;
        
        inputeasyfrac_yes = inputeasy_yes / inputeasy_total;
        inputeasyfrac_no = inputeasy_no / inputeasy_total;
        inputeasyfrac_mb = inputeasy_mb / inputeasy_total;
        
        easyinputarray = [inputeasyfrac_yes, inputeasyfrac_no, inputeasyfrac_mb];
        easyinputarray_sd = sqrt(easyinputarray.*(1-easyinputarray)/inputeasy_total);
             
        
        
        %% would like to increase uptake
        numNoIncrease = f.sumUp(pharmacydata.IncreaseUptake.NoIwouldliketodecreasethenumberofpeople);
        numNoMaintain = f.sumUp(pharmacydata.IncreaseUptake.NoIwouldliketomaintainthesamenumberofpeople);
        numYesIncrease = f.sumUp(pharmacydata.IncreaseUptake.YesIwouldliketoincreasethenumberofpeople);
        num_increase_total = numNoIncrease + numNoMaintain + numYesIncrease;
        
        fracNoIncrease = numNoIncrease / num_increase_total;
        fracNoMaintain = numNoMaintain / num_increase_total;
        fracYesIncrease = numYesIncrease / num_increase_total;
        
        changeservicearray = [fracNoIncrease, fracNoMaintain, fracYesIncrease];
        changeservicearray_sd = sqrt(changeservicearray.*(1-changeservicearray)/num_increase_total);
        
        %% repeat customers
        numRCyes = f.sumUp(pharmacydata.RepeatCustom.Yes);
        numRCno = f.sumUp(pharmacydata.RepeatCustom.No);
        numRCunsure = f.sumUp(pharmacydata.RepeatCustom.Unsure);
        num_RC_total = numRCyes + numRCno + numRCunsure;
        
        fracRCyes = numRCyes / num_RC_total;
        fracRCno = numRCno / num_RC_total;
        fracRCunsure = numRCunsure / num_RC_total;
        
        repeatcustomerarray = [fracRCyes, fracRCno, fracRCunsure];
        repeatcustomerarray_sd = sqrt(repeatcustomerarray.*(1-repeatcustomerarray)/num_RC_total);
        
        
        %% repeat customers
        percentagearray = pharmacydata.RepeatPC.Percentage;
%         numRCyes = f.sumUp(pharmacydata.RepeatPC.Percentage);
% %         numRCno = f.sumUp(pharmacydata.RepeatCustom.No);
% %         numRCunsure = f.sumUp(pharmacydata.RepeatCustom.Unsure);
% %         num_RC_total = numRCyes + numRCno + numRCunsure;
% %         
% %         fracRCyes = numRCyes / num_RC_total;
% %         fracRCno = numRCno / num_RC_total;
% %         fracRCunsure = numRCunsure / num_RC_total;
% %         
%         repeatcustomerarray = [fracRCyes, fracRCno, fracRCunsure];
%         repeatcustomerarray_sd = sqrt(repeatcustomerarray.*(1-repeatcustomerarray)/num_RC_total);
%         
        
        
        
        close all
        fig = figure;
        titlesize = 16;
        labelsize = 16;
        legendsize = 14;
        
        plotwidth = 0.3;
        plotheight = 0.4;
        leftmargin = 0.04;
        %rightmargin = 0.05;
        bottommargin = 0.05;
        columnspace = 0.03;
        rowspace = 0.08;
        %xlimits = [0 32];
        ylimits = [0 1];
        %top row
        ax(1) = axes('Position',  [leftmargin,                           bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        ax(2) = axes('Position',  [leftmargin+plotwidth+0.5*columnspace,     bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        ax(3) = axes('Position',  [leftmargin+2*plotwidth+1.5*columnspace, bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        % bottom row
        ax(4) = axes('Position',  [leftmargin,                           bottommargin, plotwidth, plotheight]);
        ax(5) = axes('Position',  [leftmargin+plotwidth+0.5*columnspace,     bottommargin, plotwidth, plotheight]);
        ax(6) = axes('Position',  [leftmargin+2*plotwidth+1.5*columnspace, bottommargin, plotwidth, plotheight]);
        
        %ss = get(0,'screensize');
         set(gcf,'position',...
          [100, 100, 1700, 900]);
        %subplot(1,3,1),
        axes(ax(1)), hold on
            h(1) = bar(1,problemarray(1));
            h(2) = bar(2,problemarray(2), 'y');
            set(gca, 'XTick', 1:2)
            set(gca, 'XTickLabel', {'Yes', 'No'}, 'FontSize', labelsize)
            ylim(ylimits)
            title('a) Is poor vaccination uptake a concern?', 'FontSize', titlesize)
            leg = legend('Pharmacists','GPs');
            set(leg, 'FontSize', legendsize);
            legend('boxoff')
            ylabel('Fraction of respondents', 'FontSize', labelsize)
            box off
            x(1) = get(h(1), 'XData');
            x(2) = get(h(2), 'XData');
            plot([x(1); x(1)], [problemarray(1)-1.96*problemarray_sd(1) problemarray(1)+1.96*problemarray_sd(1)]', 'k-');
            plot([x(2); x(2)], [problemarray(2)-1.96*problemarray_sd(2) problemarray(2)+1.96*problemarray_sd(2)]', 'k-');
        axes(ax(2)), hold on
        %subplot(1,3,2)
             bar(goodideaarray)
             ylim(ylimits)
             title('b) Is pharmacy vaccination a good idea?', 'FontSize', titlesize)
             set(gca, 'YTickLabel', {});
             box off
             numgroups = size(goodideaarray, 1);
             numbars = size(goodideaarray, 2);
             groupwidth = min(0.8, numbars/(numbars+1.5));
            for i = 1:numbars
                % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
                x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
                plot([x; x], [goodideaarray(:,i)-1.96*goodideaarray_sd(:,i) goodideaarray(:,i)+1.96*goodideaarray_sd(:,i)]', 'k-');
                %e = errorbar(x, allarray(:,i), allsd(:,i), 'k', 'linestyle', 'none');
                %errorbar_tick(e,80);
            end
            set(gca, 'XTick', 1:3)
            set(gca, 'XTickLabel', {'Yes', 'No', 'Mixed opinions'}, 'FontSize', labelsize)
        %subplot(1,3,3)
        axes(ax(3)), hold on
            h2 = bar(easyinputarray, 'y');
             ylim(ylimits)
             title('c) Is pharmacy vaccine uptake data easy to input?', 'FontSize', titlesize)
             set(gca, 'YTickLabel', {});
             box off
             x2 = get(h2, 'XData');
             plot([x2; x2], [easyinputarray-1.96*easyinputarray_sd; easyinputarray+1.96*easyinputarray_sd], 'k-');
             set(gca, 'XTick', 1:3)
            set(gca, 'XTickLabel', {'Yes', 'No', 'Mixed opinions'}, 'FontSize', labelsize)
            
        axes(ax(4)), hold on
            h3 = bar(changeservicearray);
             ylim(ylimits)
             title('d) Woud you like to increase your flu vaccine service?', 'FontSize', titlesize)
             %set(gca, 'YTickLabel', {});
             box off
             x3 = get(h3, 'XData');
             plot([x3; x3], [changeservicearray-1.96*changeservicearray_sd; changeservicearray+1.96*changeservicearray_sd], 'k-');
             set(gca, 'XTick', 1:3)
            set(gca, 'XTickLabel', {'No, decrease', 'No, maintain', 'Yes increase'}, 'FontSize', labelsize)
             ylabel('Fraction of respondents', 'FontSize', labelsize)
        
        axes(ax(5)), hold on
            h4 = bar(repeatcustomerarray);
             ylim(ylimits)
             title('d) Do you get much repeat custom for flu vaccines?', 'FontSize', titlesize)
             set(gca, 'YTickLabel', {});
             box off
             x4 = get(h4, 'XData');
             plot([x4; x4], [repeatcustomerarray-1.96*repeatcustomerarray_sd; repeatcustomerarray+1.96*repeatcustomerarray_sd], 'k-');
             set(gca, 'XTick', 1:3)
            set(gca, 'XTickLabel', {'Yes', 'No', 'Unsure'}, 'FontSize', labelsize)
             %ylabel('Fraction of respondents', 'FontSize', labelsize)
             
        axes(ax(6)), hold on
            [h5, midpoints] = hist(percentagearray);
            total = sum(h5);
            plotarray = h5 / total;
            h6 = bar(midpoints, plotarray);
            title('e) How many customers had the flu vaccine the previous year?', 'FontSize', titlesize)
            %ylabel('Frequency of respondents', 'FontSize', labelsize)
            xlabel('Percentage', 'FontSize', labelsize)
            set(gca, 'FontSize', labelsize)
end

function plotBrands(pharmacydata, gpdata, f)

        allbrands = fields(gpdata.Brand)';
        
        for brand = allbrands
            brand = brand{1}; 
            countpharm.(brand) = f.sumUp(pharmacydata.Brand.(brand));
            countgp.(brand) = f.sumUp(gpdata.Brand.(brand)); 
        end
        
        brandsarray_pharm = struct2array(countpharm);
        brandsarray_gp = struct2array(countgp);
        
        totals_pharm = sum(brandsarray_pharm);
        totals_gp = sum(brandsarray_gp);
        
         h_pharm = brandsarray_pharm / totals_pharm;
         h_gp = brandsarray_gp / totals_gp;
        
        names = {'Influvac (Abbott)'
                'Imuvac (Abbott)'
                'FluarixTetra (AstraZeneca)'
                'Fluarix (AstraZeneca)'
                'Imuvac (MASTA)'
                'Enzira (MASTA)'
                'Inactivated Vaccine BP (MASTA)'
                'Influvac (MASTA)'
                'CSL Inactivated Vaccine (MASTA)'
                'Agrippal (Novartis)'
                'Optaflu (Novartis)'
                'CSL Inactivated Vaccine (Pfizer)'
                'Enzira (Pfizer)'
                'Inactivated Vaccine BP (SPMSD)'
                'Intanza (SPMSD)'
                'Unsure'
                'I don''t want to say'};
        
            
        labelsize = 13;
        titlesize = 16;
        leftmargin = 0.1;
        bottommargin = 0.25;
        plotwidth = 0.8;
        plotheight = 0.6;
        fig = figure;
        set(fig, 'Position', [100, 100, 1400, 600])
        ax = axes('Position', [leftmargin, bottommargin, plotwidth, plotheight]);
        axes(ax)
        bar([h_pharm; h_gp]')
        box off;
        set(gca, 'XTick', 1:size(names,1), 'FontSize', labelsize)
        set(gca, 'XTickLabel', {})
        title('Brand used for seasonal influena administration 2014/15', 'FontSize', titlesize)
        leg=  legend('Pharmacy delivery', 'GP delivery');
        legend('boxoff')
        set(leg, 'FontSize', titlesize)
        ylabel('Fraction of vaccine doses', 'FontSize', titlesize)
        text(1:length(names),...
            zeros(1,length(names)), ...
            names, ...
            'VerticalAlign','top',...
            'HorizontalAlign','right',...
            'Rotation',45,...
            'FontSize', labelsize)
end


function plotGPservice(gpdata, f)
        
        %% who administers
        admin_gponly = f.sumUpVals(gpdata.WhoAdministers.Response, 'Only GP');
        admin_mostlygp = f.sumUpVals(gpdata.WhoAdministers.Response, 'Mostly GP, but sometimes nurse');
        admin_both = f.sumUpVals(gpdata.WhoAdministers.Response, 'Both GP and nurse');
        admin_mostlynurse = f.sumUpVals(gpdata.WhoAdministers.Response, 'Mostly nurse, but sometimes GP');
        admin_nurseonly = f.sumUpVals(gpdata.WhoAdministers.Response, 'Only nurse');

        admin_total = admin_gponly + admin_nurseonly + admin_both + admin_mostlygp + admin_mostlynurse;
        
        adminfrac_gponly = admin_gponly / admin_total;
        adminfrac_mostlygp = admin_mostlygp / admin_total;
        adminfrac_both = admin_both / admin_total;
        adminfrac_mostlynurse = admin_mostlynurse / admin_total;
        adminfrac_nurseonly = admin_nurseonly / admin_total;
        
        adminarray = [adminfrac_gponly, adminfrac_mostlygp, adminfrac_both, adminfrac_mostlynurse, adminfrac_nurseonly];
        adminarray_sd = sqrt(adminarray.*(1-adminarray)/admin_total);
        
        admin_names = {'GP only'
                 'Both GP and nurse'
                 'Mostly GP'
                 'Mostly nurse'
                 'Only nurse'};
             
        %% when administered
        when_regular = f.sumUpVals(gpdata.WhenOffered.Response, 'Only during regular surgery hours');
        when_both = f.sumUpVals(gpdata.WhenOffered.Response, 'Both during regular surgery hours and extended hours');
        when_extended = f.sumUpVals(gpdata.WhenOffered.Response, 'Only during extended hours on evenings and weekends');
       
        when_total = when_regular + when_both + when_extended;
        
        fracwhen_regular = when_regular / when_total;
        fracwhen_both = when_both / when_total;
        fracwhen_extended = when_extended / when_total;
        
        whenarray = [fracwhen_regular, fracwhen_both, fracwhen_extended];
        whenarray_sd = sqrt(whenarray.*(1-whenarray)/when_total);
        
        when_names = {'Regular surgery hours'
                 'Regular hours & eve/wkend'
                 'Evenings/weekends'};  
             
        %% how administered
        how_walkin = f.sumUpVals(gpdata.HowOffered.Response, 'Walk-in clinic');
        how_both = f.sumUpVals(gpdata.HowOffered.Response, 'Both walk-in clinics and by appointment');
        how_appt = f.sumUpVals(gpdata.HowOffered.Response, 'By appointment only');
       
        how_total = how_walkin + how_both + how_appt;
        
        frachow_walkin = how_walkin / how_total;
        frachow_both = how_both / how_total;
        frachow_appt = how_appt / how_total;
        
        howarray = [frachow_walkin, frachow_both, frachow_appt];
        howarray_sd = sqrt(howarray.*(1-howarray)/how_total);
        
        how_names = {'Walk-in clinic'
                 'Walk-in & appointment'
                 'Appointment only'}; 
             
         %% shingles vaccine
        shingles_yes = f.sumUpVals(gpdata.OfferShingles.Response, 'yes');
        shingles_no = f.sumUpVals(gpdata.OfferShingles.Response, 'no');
        
        shingles_total = shingles_yes + shingles_no;
        
        frac_shingles_yes = shingles_yes / shingles_total;
        frac_shingles_no = shingles_no / shingles_total;
        
        shinglesarray = [frac_shingles_yes, frac_shingles_no];
        shinglesarray_sd = sqrt(shinglesarray.*(1-shinglesarray)/shingles_total);
        
        shingles_names = {'Yes'
                 'No'}; 
             
        %% how many oppportunistic shingles?
        [shinglesopp, xmidpts] = hist(gpdata.OfferShingles.ShinglesUptake);
        shinglesopp_total = sum(shinglesopp(~isnan(shinglesopp)));
        shinglesopparray = shinglesopp / shinglesopp_total;
             
        close all
        fig = figure;
        titlesize = 16;
        labelsize = 14;
        legendsize = 14;
        
        plotwidth = 0.45;
        plotheight = 0.35;
        leftmargin = 0.04;
        %rightmargin = 0.05;
        bottommargin = 0.11;
        columnspace = 0.03;
        rowspace = 0.13;
        %xlimits = [0 32];
        ylimits = [0 1];
        set(gcf,'position',...
          [100, 100, 1800, 1200]);
      
      
        %top row
        ax(1) = axes('Position',  [leftmargin,                           bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        ax(2) = axes('Position',  [leftmargin+plotwidth+columnspace,     bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        % bottom row
        ax(3) = axes('Position',  [leftmargin,                           bottommargin, plotwidth, plotheight]);
        ax(4) = axes('Position',  [leftmargin+plotwidth+columnspace,     bottommargin, plotwidth, plotheight]);
        % inset
        rax = get(ax(4), 'Position');
        ax(5) = axes('Position', [rax(1)+0.75*rax(4) rax(2)+0.25*rax(3) 0.35*rax(3) 0.5*rax(4)]);
        
        
        axes(ax(1))
        hold on;
        h1 = bar(adminarray, 'y');
                set(gca, 'FontSize', labelsize)
                title('a) Who administers the flu vaccine in your practice', 'FontSize', titlesize)
                set(gca, 'XTickLabel', {})
                set(gca, 'XTick', 1:size(admin_names,2))
                text(1:length(admin_names),...
                    zeros(1,length(admin_names)), ...
                    admin_names, ...
                    'VerticalAlign','top',...
                    'HorizontalAlign','right',...
                    'Rotation',45,...
                    'FontSize', labelsize)
                box off
                ylim(ylimits)
                x = get(h1, 'XData');
                plot([x; x], [adminarray-1.96*adminarray_sd; adminarray+1.96*adminarray_sd], 'k-');
                set(gca, 'XTick', 1:size(admin_names,1))                
                ylabel('Fraction of respondents', 'FontSize', titlesize)
                
        axes(ax(2))
        hold on;
        h2 = bar(whenarray, 'y');
                set(gca, 'FontSize', labelsize)
                title('b) When do you administer flu vaccines?', 'FontSize', titlesize)
                set(gca, 'YTickLabel', {})
                set(gca, 'XTick', 1:size(when_names,2))
                text(1:length(when_names),...
                    zeros(1,length(when_names)), ...
                    when_names, ...
                    'VerticalAlign','top',...
                    'HorizontalAlign','right',...
                    'Rotation',45,...
                    'FontSize', labelsize)
                box off
                ylim(ylimits)
                x = get(h2, 'XData');
                plot([x; x], [whenarray-1.96*whenarray_sd; whenarray+1.96*whenarray_sd], 'k-');
                set(gca, 'XTick', 1:size(when_names,1))                
                set(gca, 'XTick', {})
                
        axes(ax(3))
        hold on;
        h3 = bar(howarray, 'y');
                set(gca, 'FontSize', labelsize)
                title('c) How do you administer flu vaccines?', 'FontSize', titlesize)
                set(gca, 'XTickLabel', {})
                set(gca, 'XTick', 1:size(how_names,2))
                text(1:length(how_names),...
                    zeros(1,length(how_names)), ...
                    how_names, ...
                    'VerticalAlign','top',...
                    'HorizontalAlign','right',...
                    'Rotation',45,...
                    'FontSize', labelsize)
                box off
                ylim(ylimits)
                x = get(h3, 'XData');
                plot([x; x], [howarray-1.96*howarray_sd; howarray+1.96*howarray_sd], 'k-');
                set(gca, 'XTick', 1:size(how_names,1))                
                ylabel('Fraction of respondents', 'FontSize', titlesize)
        
        axes(ax(4))
        hold on;
        h4 = bar(shinglesarray, 'y');
                xlim([0.5 2.5])
                title('d) Do you offer the Shingles vaccine to eligible patients if they receive the flu vaccine?', 'FontSize', titlesize)
                set(gca, 'XTick', 1:size(shingles_names,1))
                set(gca, 'YTickLabel',{})
                set(gca, 'XTickLabel', shingles_names, 'FontSize', labelsize)
%                 text(1:length(shingles_names),...
%                     zeros(1,length(shingles_names)), ...
%                     shingles_names, ...
%                     'VerticalAlign','top',...
%                     'HorizontalAlign','right',...
%                     'Rotation',45)
                box off
                ylim(ylimits)
                x = get(h4, 'XData');
                plot([x; x], [shinglesarray-1.96*shinglesarray_sd; shinglesarray+1.96*shinglesarray_sd], 'k-');           
                set(gca, 'XTick', {})
                
       axes(ax(5))
        hold on;
        h5 = bar(xmidpts, shinglesopparray, 'y');
                %xlim([0.5 2.5])
                title('Fraction of opportunistic shingles vaccines', 'FontSize', 0.8*titlesize)
                %set(gca, 'XTick', 1:size(shingles_names,1))
                %set(gca, 'XTickLabel', shingles_names, 'FontSize', labelsize)
%                 text(1:length(shingles_names),...
%                     zeros(1,length(shingles_names)), ...
%                     shingles_names, ...
%                     'VerticalAlign','top',...
%                     'HorizontalAlign','right',...
%                     'Rotation',45)
                box off
                ylim([0 0.7])
%                 x = get(h4, 'XData');
%                 %plot([x; x], [shinglesarray-1.96*shinglesarray_sd; shinglesarray+1.96*shinglesarray_sd], 'k-');           
%                 set(gca, 'XTick', {})
       
end

function plotCosts(costdata)
close all
        fig = figure;
        titlesize = 16;
        labelsize = 14;
        legendsize = 14;
        
        plotwidth = 0.25;
        plotheight = 0.37;
        leftmargin = 0.04;
        %rightmargin = 0.05;
        bottommargin = 0.11;
        columnspace = 0.03;
        rowspace = 0.13;
        %xlimits = [0 32];
        ylimits = [0 1];
        set(gcf,'position',...
          [100, 100, 1200, 500]);
      
        % ADMIN COSTS
        subplot(1,2,1)
            hold on
            hist(costdata.PHARMACY_admincosts_perdose)
            ylims = get(gca, 'YLim');
            plot([costdata.NHS_reimbursementadmincosts_perdose costdata.NHS_reimbursementadmincosts_perdose], [0 ylims(2)],...
                        '--r', 'LineWidth', 1.2)
            plot([mean(costdata.PHARMACY_admincosts_perdose) mean(costdata.PHARMACY_admincosts_perdose)], [0 ylims(2)],...
                        '-k', 'LineWidth', 1.2)
            plot([median(costdata.PHARMACY_admincosts_perdose) median(costdata.PHARMACY_admincosts_perdose)], [0 ylims(2)],...
                        '-k', 'LineWidth', 1.2)
            title('Administration costs (Pharmacy)', 'FontSize', titlesize)
            h = findobj(gca,'Type','patch');
            h.EdgeColor = 'w';
        subplot(1,2,2)
            hold on
            hist(costdata.PHARMACY_vaccinecosts_perdose)
            plot([costdata.NHS_vaccinecosts_perdose costdata.NHS_vaccinecosts_perdose], [0 ylims(2)],...
                        '--r', 'LineWidth', 1.2)
            plot([mean(costdata.PHARMACY_vaccinecosts_perdose) mean(costdata.PHARMACY_vaccinecosts_perdose)], [0 ylims(2)],...
                        '-k', 'LineWidth', 1.2)
            plot([median(costdata.PHARMACY_vaccinecosts_perdose) median(costdata.PHARMACY_vaccinecosts_perdose)], [0 ylims(2)],...
                        '-k', 'LineWidth', 1.2)
            title('Vaccine purchase prices (Pharmacy)', 'FontSize', titlesize)
            h = findobj(gca,'Type','patch');
            h.EdgeColor = 'w';
            
            output_mean_pharmacy_admin = sprintf('Mean Pharmacy Admin Costs: %f', mean(costdata.PHARMACY_admincosts_perdose));
            output_median_pharmacy_admin = sprintf('Median Pharmacy Admin Costs: %f', median(costdata.PHARMACY_admincosts_perdose));
            output_mean_pharmacy_vaccine = sprintf('Mean Pharmacy Vaccine Costs: %f', mean(costdata.PHARMACY_vaccinecosts_perdose));
            output_median_pharmacy_vaccine = sprintf('Median Pharmacy Vaccine Costs: %f', median(costdata.PHARMACY_vaccinecosts_perdose));
            
            disp(output_mean_pharmacy_admin)
            disp(output_median_pharmacy_admin)
            disp(output_mean_pharmacy_vaccine)
            disp(output_median_pharmacy_vaccine)
            
            
    %top row
        %ax(1) = axes('Position',  [leftmargin,                           bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        %ax(2) = axes('Position',  [leftmargin+plotwidth+columnspace,     bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        %ax(3) = axes('Position',  [leftmargin+2*plotwidth+2*columnspace,   bottommargin + rowspace + plotheight, plotwidth, plotheight]);
        % bottom row
        %ax(2) = axes('Position',  [leftmargin,                               bottommargin, 1.5*plotwidth, plotheight]);
        %%ax(5) = axes('Position',  [leftmargin+1.5*plotwidth+2*columnspace,         bottommargin, 1.5*plotwidth, plotheight]);
        
%         allfields = fields(costdata);
%         index = 0;
%         for fld = allfields'
%             fld = fld{1};
%             index = index+1;
%             axes(ax(index))
%             hist(costdata.(fld), 10)
%         end

end