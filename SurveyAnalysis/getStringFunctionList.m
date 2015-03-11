function f = getStringFunctionList()


    f.countEntries = @countEntries;
    f.zerotonan = @zerotonan;
    f.sumUp = @sumUp;
    f.sumUpVals = @sumUpVals;
end


function count = countEntries(data, removelastentry)

   allfields = fields(data);
   if strcmp(removelastentry, 'true')
    allfields(end) = [];
   else
   end
   notempty =  @(str) ~strcmpi(str, '');
   
   for fld = allfields'
        fld = fld{1};
        count.(fld) = cellfun(notempty, data.(fld));
        
   end
    
end

function count = sumUp(cell)

    f = @(str) ~strcmp(str, '');
    count = sum(cellfun(f, cell));

   

end

function count = sumUpVals(cell, ref)

    f = @(str) strcmpi(str, ref);
    count = sum(cellfun(f, cell));

end

function a = zerotonan(a)

    if a==0
        a=NaN;
    end
    

end

