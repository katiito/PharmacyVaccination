function plots = getPlotFunctionList()

plots.plotOpinions = @plotOpinions;
plots.plotAwareness = @plotAwareness;
plots.plotBrands = @plotBrands;
plots.plotGPservice = @plotGPservice;
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
        xlimits = [0 32];
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

    

end