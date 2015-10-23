function h = getCalcFunctionList

h.nulls = @calculateNulls;
h.brackets = @getBracketed;
h.titleindex = @getTitle;
h.nullindex = @locateNulls;
h.RelabelCCGasPCT = @RelabelCCGasPCT;
h.RemovePCT = @RemovePCT;
h.getShortNames = @getShortNames;
h.CombineNeuro = @CombineNeuro;
h.removeNaN = @removeNaN;
h.removeCondition = @removeCondition;
h.setInclusion = @setInclusion;
h.replaceLabel = @replaceLabel;

end


% Number of Nulls, unknowns and nones
function ss = calculateNulls(str_array)

    s(1) = sum(ismember(str_array,'NULL'));
    s(2) = sum(ismember(str_array,'Null'));
    s(3) = sum(ismember(str_array,'null'));
    s(4) = sum(ismember(str_array,'Unknown'));
    s(5) = sum(ismember(str_array,'UNKNOWN'));
    s(6) = sum(ismember(str_array,'unknown'));
    s(7) = sum(ismember(str_array,'NONE'));
    s(8) = sum(ismember(str_array,'None'));
    s(9) = sum(ismember(str_array,'none'));
    
    ss = sum(s);
end


% indices of entries with brackets in them
function index = getBracketed(i_str)

    index = regexp(i_str, '\([^\)]*\)');
end

% indices of entries with the title "dr" in them
function index = getTitle(i_str)

    index = regexpi(i_str, 'dr[ |.]');
%     if ~isempty(index)
%         disp(0)
%     end
end

% logical output showing position of unknowns
function out = locateNulls(i_str)

a{1} = strcmp(i_str, 'NULL');
a{2} = strcmp(i_str, 'Null');
a{3} = strcmp(i_str, 'null');
a{4} = strcmp(i_str, 'UNKNOWN');
a{5} = strcmp(i_str, 'Unknown');
a{6} = strcmp(i_str, 'unknown');
a{7} = strcmp(i_str, 'NONE');
a{8} = strcmp(i_str, 'None');
a{9} = strcmp(i_str, 'none');

out = a{1} | a{2} | a{3} | a{4} | a{5} | a{6} | a{7} | a{8} | a{9};
end


%% CCG --> PCT
function newstring = RelabelCCGasPCT(pctstring)

    
    newstring = regexprep(pctstring,'(WEST LONDON \(K&C & QPP\))','KENSINGTON AND CHELSEA');
    newstring = regexprep(newstring,'(CENTRAL LONDON \(WESTMINSTER\))','WESTMINSTER');

    newstring = regexprep(newstring,'(RICHMOND)','RICHMOND AND TWICKENHAM');
    
    newstring = regexprep(newstring,'(MERTON CCG)','SUTTON AND MERTON');
    newstring = regexprep(newstring,'(SUTTON CCG)','SUTTON AND MERTON');
    newstring = regexprep(newstring,'(CCG)','');


end

function newstring = RemovePCT(pctstring)

    newstring = regexprep(pctstring,'(PCT)','');
    newstring = regexprep(newstring,'( TEACHING)','');
    newstring = regexprep(newstring,'( CARE TRUST)','');
end

function ss = getShortNames(anystring)

    ss = regexp(anystring, '^\S{4}', 'match');
    ss = [char(ss), ' '];
end

function [totstr orig] = CombineNeuro(mainstring, extrastring)
    allfields = fields(mainstring);
    
    for i = 1:size(allfields)
        fld = char(allfields(i));
        totstr.(fld).Registered = arrayfun( @(c1,c2) (c1+c2), mainstring.(fld).Registered, extrastring.(fld).Registered);
        totstr.(fld).Vaccinated = arrayfun( @(c1,c2) (c1+c2), mainstring.(fld).Vaccinated, extrastring.(fld).Vaccinated);
    end
    
    orig = [];
end

function arraywithoutnans = removeNaN(array)

  nanlocate = isnan(array);
  arraywithoutnans = array(~nanlocate);
    
end

%% get nicer looking labels for plotting
function outstring = removeCondition(string)

    outstring = regexprep(string,'Allpatients','Elderly');
    outstring = regexprep(outstring,'(Patientswith)','');
    outstring = [outstring(1), regexprep(outstring(2:end),'([A-Z])',' $1')];
    
end

%% if inclusion criteria for pharmacy is 13-65, get the subcriteria
function outstring = setInclusion(str1, str2)
    if strcmpi(str1, '13 to 65')
       outstring = str2; 
    else
       outstring = str1;
    end
end


%% replace label for Pharmacy so it matches the GP labels
function outstring = replaceLabel(old_str)

    old_string = {'Aged 65 and over', 'Chronic heart disease', 'Chronic respiratory disease',...
                            'Chronic kidney disease', 'Chronic liver disease', 'Diabetes mellitus', 'Immunosuppression due to disease or treatment',...
                            'Chronic neurological disease', 'Pregnant woman', 'Carer of an elderly or disabled person'};
                        
    Fields = {'Elderly',...
                  'PatientswithChronicHeartDisease',...
                  'PatientswithChronicRespiratoryDisease',...
                  'PatientswithChronicKidneyDisease',...
                  'PatientswithChronicLiverDisease',...
                  'PatientswithDiabetes',...
                  'PatientswithImmunosuppression',...
                  'PatientswithChronicNeurologicalDisease',...
                  'PregnantWomen',...
                  'Carers'}';
              
     index = find( ismember(old_string, old_str));
     if ~isempty(index)
         outstring = Fields(index);
         outstring = outstring{1};
     else
         outstring = 'Other';
     end
    
     
end