function h = getCalcFunctionList

h.nulls = @calculateNulls;
h.brackets = @getBracketed;
h.titleindex = @getTitle;
h.nullindex = @locateNulls;

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



 


