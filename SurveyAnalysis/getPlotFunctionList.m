function plots = getPlotFunctionList()

plots.plotOpinions = @plotOpinions;
plots.plotAwareness = @plotAwareness;
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
  
        numyes_gp    = f.sumUpVals(gpdata.UptakeProblem.Response, 'yes'); 
        numno_gp    = f.sumUpVals(gpdata.UptakeProblem.Response, 'no'); 

        fracyes_pharm = numyes_pharm / (numyes_pharm + numno_pharm);
        fracyes_gp    = numyes_gp / (numyes_gp + numno_gp);

        problemarray = [fracyes_pharm, fracyes_gp]';
        problemarray_sd = sqrt(problemarray.*(1-problemarray)./[total_number_patients_pharm; total_number_patients_gp]);
        
        
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
        goodideaarray_sd = sqrt(goodideaarray.*(1-goodideaarray)./repmat([total_number_patients_pharm, total_number_patients_gp], 3, 1));
        
        
        %% inputting data easy (yes / no / mixed opinions)
        inputeasy_yes = f.sumUpVals(gpdata.EasyInput.Response, 'Yes');
        inputeasy_no = f.sumUpVals(gpdata.EasyInput.Response, 'No');
        inputeasy_mb = f.sumUpVals(gpdata.EasyInput.Response, 'Mixed Opinions');
        inputeasy_total = inputeasy_yes + inputeasy_no + inputeasy_mb;
        
        inputeasyfrac_yes = inputeasy_yes / inputeasy_total;
        inputeasyfrac_no = inputeasy_no / inputeasy_total;
        inputeasyfrac_mb = inputeasy_mb / inputeasy_total;
        
        easyinputarray = [inputeasyfrac_yes, inputeasyfrac_no, inputeasyfrac_mb];
        easyinputarray_sd = sqrt(easyinputarray.*(1-easyinputarray)/total_number_patients_gp);
               
        close all
        fig = figure;
        titlesize = 16;
        labelsize = 16;
        legendsize = 14;
        ylimits = [0 1];
        plotwidth = 0.3;
        plotheight = 0.8;
        leftmargin = 0.05;
        %rightmargin = 0.05;
        bottommargin = 0.1;
        columnspace = 0.01;
        rowspace = 0.08;
        xlimits = [0 32];
        ylimits = [0 1];
        %top row
        ax(1) = axes('Position',  [leftmargin,                           bottommargin, plotwidth, plotheight]);
        ax(2) = axes('Position',  [leftmargin+plotwidth+columnspace,     bottommargin, plotwidth, plotheight]);
        ax(3) = axes('Position',  [leftmargin+2*plotwidth+2*columnspace, bottommargin, plotwidth, plotheight]);

        %ss = get(0,'screensize');
         set(gcf,'position',...
          [100, 100, 1600, 400]);
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
             set(gca, 'XTickLabel', {'Yes', 'No', 'Mixed opinions'}, 'FontSize', labelsize)
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
        %subplot(1,3,3)
        axes(ax(3)), hold on
            h2 = bar(easyinputarray);
            set(gca, 'XTickLabel', {'Yes', 'No', 'Mixed opinions'}, 'FontSize', labelsize)
             ylim(ylimits)
             title('c) Is pharmacy vaccine uptake data easy to input?', 'FontSize', titlesize)
             set(gca, 'YTickLabel', {});
             box off
             x2 = get(h2, 'XData');
             plot([x2; x2], [easyinputarray-1.96*easyinputarray_sd; easyinputarray+1.96*easyinputarray_sd], 'k-');
             
         
end


function plotGPservice(gpdata, f)


end