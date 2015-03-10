function runAnalysis()
%handles to functions
data = getDataFunctionList();
cost = getCalculationFunctionList();
func = getStringFunctionList();

%% grab data
pharmacydata = data.ReadInData();

pharmacycosts = cost.CalculateAdminCost(pharmacydata, func);

end