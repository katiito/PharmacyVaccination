function h = getOutputFunctionList

    h.PharmacyUptake = @outputPharmacyUptake;
    
end



function outputPharmacyUptake(GPdata, f)
% find indices that contain or don't contain brackets
        brackets = cellfun(@f.brackets, GPdata, 'UniformOutput', false);
        no_brackets_indices = find(~cellfun(@(a)~isempty(a), brackets));
        OnlyNoBrackets = GPdata(no_brackets_indices);
        
        % of the ones that don't contain brackets:
            % which ones are just Nulls
            out = cellfun(@f.nullindex,OnlyNoBrackets);
            nulls_indices = find(out);
            OnlyNulls = OnlyNoBrackets(nulls_indices);
            % which ones are just Dr names
            drs = cellfun(@f.titleindex, OnlyNoBrackets, 'UniformOutput', false);
            drs_indices = find(cellfun(@(a)~isempty(a), drs));
            OnlyDrs = OnlyNoBrackets(drs_indices);
          
        % print out
        totout = sprintf('Totals: %g', size(brackets,1));
        gpout = sprintf('GP specified: %g', size(brackets,1) - size(nulls_indices,1));
        nullout = sprintf('Nulls: %g', size(nulls_indices,1));
        nopostcode = sprintf('No Postcode: %g', size(no_brackets_indices,1));
        postcodeout = sprintf('With Postcode: %g', size(brackets,1) - size(no_brackets_indices,1));
        onlydrout = sprintf('Only Dr Name: %g - <some address,check output>', size(drs_indices,1) );
        practiceout = sprintf('Practice info: %g + <some address,check output>', size(no_brackets_indices,1) - size(nulls_indices,1) - size(drs_indices,1) );
        
        disp(sprintf('\n\n'))
        disp(gpout)
        disp(postcodeout)
        disp(practiceout)
        disp(onlydrout)        
        disp(nullout)
        disp(totout)
        disp(sprintf('\n\n'))
end