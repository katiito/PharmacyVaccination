function runAnalysis()
%handles to functions
data = getDataFunctionList();
cost = getCostFunctionList();
func = getStringFunctionList();
plots = getPlotFunctionList();


%% grab data
pharmacydata = data.ReadInData('pharmacy');
gpdata = data.ReadInData('gp');

%% Cost Data
pharmacycosts = cost.CalculateAdminCost(pharmacydata, func);

%% Opinions about scheme
%plots.plotOpinions(pharmacydata, gpdata, func);

%% Opinions about increased uptake and whether scheme is good idea
%plots.plotAwareness(pharmacydata, gpdata, func)

%% BRANDS
plots.plotBrands(pharmacydata, gpdata, func)

%% GP questions about vaccine practices
%plots.plotGPservice(gpdata, func)
end