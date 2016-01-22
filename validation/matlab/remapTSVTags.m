% This function takes in a file containing the HED tags associated with a
% particular study and replaces the old HED tags with the new HED tags
% that are specified in a HED remap file.
%
% Usage:
%
%   >>  updateTSVTags(remapFile, tsvFile, tsvTagColumns);
%
%   >>  updateTSVTags(remapFile, tsvFile, tsvTagColumns, varargin);
%
% Input:
%
%       remapFile
%                   The name or the path of the HED remap file containing
%                   the mappings of old HED tags to new HED tags. This
%                   file is a two column tab-delimited file with the old
%                   HED tags in one column and the new HED tags in another
%                   column.
%
%       tsvFile
%                   The name or the path of a tab-delimited text file
%                   containing HED tags associated with a particular study.
%
%       tsvTagColumns
%                   The columns that contain the HED study tags. The
%                   columns can be a scalar value or a vector.
%
%       Optional:
%
%       'outputFile'
%                   The name or the path to the file that the output is
%                   written to. The output file will be a tab-delimited
%                   text file consisting of the new HED tags which replaced
%                   the old HED tags in each specified columns.
%
% Examples:
%                   To replace the old HED tags in file
%                   'Reward Two Back Study.txt' with new HED tags in the
%                   fourth column using HED remap file 'HEDRemap.txt'.
%
%                   updateTSVTags('HEDRemap.txt', ...
%                   'Reward Two Back Study.txt', 4)
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function remapTSVTags(remapFile, tsvFile, tsvTagColumns, varargin)
p = parseArguments();
output = '';
remapMap = remap2Map(p.remapFile);
try
    fileId = fopen(p.tsvFile);
    tLine = fgetl(fileId);
    while ischar(tLine)
        readTags(tLine, tsvTagColumns);
        tLine = fgetl(fileId);
    end
    fclose(fileId);
    writeOutput(output)
catch me
    fclose(fileId);
    rethrow(me);
end

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('remapFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('tsvFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('tsvTagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        [path, file] = fileparts(tsvFile);
        p.addParamValue('OutputFile', ...
            fullfile(path, [file '_output.txt']), ...
            @(x) ~isempty(x) && ischar(x));  %#ok<NVREPL>
        p.parse(remapFile, tsvFile, tsvTagColumns, varargin{:});
        p = p.Results;
    end % parseArguments

    function readTags(tLine, tagColumns)
        % Reads the tag columns from a tab-delimited row
        splitLine = textscan(tLine, '%s', 'delimiter', '\t', ...
            'multipleDelimsAsOne', 1)';
        numCols = size(splitLine{1}, 1);
        for a = 1:numCols
            if ismember(a, tagColumns)
                splitTags = splitLine{a};
                splitCellTags = str2cell(splitTags);
                replacedTags = remapTags(splitCellTags);
                replacedTags = cell2str(replacedTags);
                output = sprintf('%s%s\t', output, replacedTags);
            else
                output = sprintf('%s%s\t', output, splitLine{a});
            end
        end
        output = sprintf('%s\n', output); 
    end % readTags

    function remappedTags = remapTags(tags)
        % Remaps the old tags with the new tags
        remappedTags = {};
        for a = 1:length(tags)
            if iscellstr(tags{a})
                remappedTags{end+1} = remapTags(tags{a}); %#ok<AGROW>
            else
                if remapMap.isKey(lower(tags{a}))
                    remappedTags{end+1} = ...
                        remapMap(lower(tags{a}));   %#ok<AGROW>
                else
                    remappedTags{end+1} = tags{a}; %#ok<AGROW>
                end
            end
        end
    end % remapTags

    function tags = str2cell(tags)
        % Converts the tags from a string to a cell array
        tags = formatTags(tags, true);
    end % str2cell

    function tagStr = cell2str(tags)
        % Converts the tags from a cell array to a string
        numTags = size(tags, 2);
        tagStr = convertTag(tags{1});
        for a = 2:numTags
            tagStr = [tagStr ', ' convertTag(tags{a})]; %#ok<AGROW>
        end
    end % cell2str

    function tagStr = convertTag(tag)
        % Converts a cell array containing a tag or a tag group into a string
        if iscellstr(tag)
            tagStr = joinTagGroup(tag);
        else
            tagStr = tag;
        end
    end % convertTag

    function groupStr = joinTagGroup(group)
        % Joins a cell array containing a tag group into a comma delimited
        % string
        numTags = size(group, 2);
        groupStr = ['(' group{1}];
        previousTag = false;
        for a = 2:numTags
            if strcmp('~', group{a})
                previousTag = false;
                groupStr = [groupStr ' ' group{a}]; %#ok<AGROW>
            elseif previousTag
                groupStr = [groupStr ',' group{a}]; %#ok<AGROW>
            else
                groupStr = [groupStr ' ' group{a}]; %#ok<AGROW>
                previousTag = true;
            end
        end
        groupStr = [groupStr ')'];
    end % joinTagGroup

    function writeOutput(output)
        % Writes the output to the file
        outputFile = p.OutputFile;
        fileId = fopen(outputFile,'w');
        fprintf(fileId, '%s', output);
        fclose(fileId);
    end % writeOutput

end % remapTSVTags