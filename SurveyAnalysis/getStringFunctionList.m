function f = getStringFunctionList()


    f.countEntries = @countEntries;
    f.zerotonan = @zerotonan;

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


function a = zerotonan(a)

    if a==0
        a=NaN;
    end
    

end