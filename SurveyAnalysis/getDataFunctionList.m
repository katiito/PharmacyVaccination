function data = getDataFunctionList()

data.ReadInData = @ReadInData;

end



function data = ReadInData()

        filename = 'survey_data_pharmacist';
        NumHeaderLines = 2;
        NumCols = 83;
        MergedIndices1 = ones(1,NumCols);
        MergedIndices2 = ones(1,NumCols);
        fid = fopen(filename, 'r');
        for hl = 1:NumHeaderLines
            hstring{hl} = fgets(fid);
        end
        headerformat = repmat('%s ', 1, 83);
        readinformat = repmat('%s ', 1, 83);
        readinformat(58:60) = '%f ';
        readinformat(193:195) = '%f ';
        readinformat(208:210) = '%f ';
        readinformat(223:225) = '%f ';
        readinformat(232:234) = '%f ';
        readinformat(247:249) = '%f ';
        
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
            header = headerlines{2}{i};
            header = header{1};
            data.(header) = dataout{i};
        end
        
        for i = (MergedIndices1+1):NumCols
            headerA = headerlines{1}{i}; headerA = headerA{1};
            headerB = headerlines{2}{i}; headerB = headerB{1};
            data.(headerA).(headerB) = dataout{i};
        end
        

end