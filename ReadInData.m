function data = ReadInData(datatype, years)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PHARMACY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(datatype, 'pharmacy')
        filename = ['readin_PharmacyData_',years];
        fid = fopen(filename, 'r');
        str = fgets(fid);
        readinformat = '%s %s %s %s %s %s %s %s %s %s %s'; 

        % read in header and data and close the file
        headerlines = textscan(str, readinformat, 'Delimiter', '\t');
        dataout = textscan(fid, readinformat, 'Delimiter', '\t');
        fclose(fid);

        % save as separate cells
        for i = 1:size(headerlines,2)
            header = headerlines{i};
            header = header{1};
            data.(header) = dataout{i};
        end


        % fill in ends of last columns of strings
        presize = size(data.Inclusion2,1);
        dif = size(data.LocationID,1) - presize;
        if dif>0
            for i = 1:dif
                data.Inclusion2{presize+i} = '';
            end
        end

        % grab postcode at the end of the Location member
        data.PostCodes = cellfun(@getPostCode, data.LocationName);

        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(datatype, 'GP')
        % constants
        NumHeaderLines = 3;
        if strcmp(years, '2010_2011')
            NumCols = 118;
            NumColsPre = 9;
            MergedIndices1 = [9,12,12,9*ones(1,8),1,9,3];
            MergedIndices2 = [9, 3*ones(1,29),1,3*ones(1,3) 1, 1, 1];
        elseif strcmp(years, '2013_2014')
            NumCols = 127;
            NumColsPre = 10;
            MergedIndices1 = [10,12,12,9*ones(1,10),3];
            MergedIndices2 = [10, 3*ones(1,38), 1, 1, 1];
        else
            NumCols = 109;
            NumColsPre = 10;
            MergedIndices1 = [10,12,12,9*ones(1,8),3];
            MergedIndices2 = [10, 3*ones(1,32), 1, 1, 1];
        end
        
        
        % file open
        filename = ['readin_GPData_', years];
        fid = fopen(filename, 'r');
        for hl = 1:NumHeaderLines
            hstring{hl} = fgets(fid);
        end
        headerformat = repmat('%s ', 1, NumCols);
        readinformat = [repmat('%s ', 1, NumColsPre), repmat('%f ', 1, NumCols-NumColsPre)];
        headerformat(end) = [];
        readinformat(end) = [];
      

        % read in header and data and close the file
        for hl = 1:NumHeaderLines
            headerlines{hl} = textscan(hstring{hl}, headerformat, 'Delimiter', '\t');
        end
        dataout = textscan(fid, readinformat, 'Delimiter', '\t');
        fclose(fid);

        % remove whitespace from headers
        for icol = 1:NumCols
            for hl = 1:NumHeaderLines
               headerlines{hl}{icol} = regexprep(headerlines{hl}{icol},'[^\w'']','');
               headerlines{hl}{icol} = regexprep(headerlines{hl}{icol},'['''']','');
            end
        end
        
        % unmerge headers 
        for icol = (MergedIndices1+1):NumCols
            if ~strcmp(headerlines{1}{icol}, '')
                lastfixed = headerlines{1}{icol};
            end
            headerlines{1}{icol} = lastfixed;
        end
        
        for icol = (MergedIndices2+1):NumCols
            if ~strcmp(headerlines{2}{icol}, '')
                lastfixed = headerlines{2}{icol};
            end
            headerlines{2}{icol} = lastfixed;
        end
        
        % save as separate cells
        for i = 1:MergedIndices1
            header = headerlines{3}{i};
            header = header{1};
            data.(header) = dataout{i};
        end
        
        for i = (MergedIndices1+1):NumCols
            headerA = headerlines{1}{i}; headerA = headerA{1};
            headerB = headerlines{2}{i}; headerB = headerB{1};
            headerC = headerlines{3}{i}; headerC = headerC{1};
            data.(headerA).(headerB).(headerC) = dataout{i};
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OTHER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    else
        data = NaN;
        error('Please specify whether pharmacy or GP data');
    end
end

function pc = getPostCode(i_str)
    pc = regexp(i_str,'\(([^:]*)\)','tokens');
end

