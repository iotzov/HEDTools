% tagstudy_input
% GUI for input needed to create inputs for tagstudy
%
% Usage:
%   >>  tagstudy_input()
%
% Description:
% tagstudy_input() brings up a GUI for input needed to create inputs for
% tagstudy
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for tagstudy_input:
%
%    doc tagstudy_input
% See also: tagstudy, pop_tagstudy
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013,
% krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: tagstudy_input.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [studyFile, baseMap, editXml, preservePrefix, ...
    rewriteOption, saveAll, saveMapFile,  selectOption, useGUI, ...
    writeTags, cancelled] =  tagstudy_input()

% Setup the variables used by the GUI
baseMap = '';
cancelled = true;
preservePrefix = false;
editXml = false;
rewriteOption = 'Both';
rewriteGroupPanel = '';
rewriteCtrl = '';
editXmlCtrl = '';
writeTagsCtrl = '';
saveAll = true;
saveMapFile = '';
selectOption = true;
studyFile = '';
useGUI = true;
title = 'Inputs for tagging EEG study';
writeTags = true;
inputFig = figure( ...
    'Color', [.94 .94 .94], ...
    'MenuBar', 'none', ...
    'Name', title, ...
    'NextPlot', 'add', ...
    'NumberTitle','off', ...
    'Resize', 'on', ...
    'Tag', title, ...
    'Toolbar', 'none', ...
    'Visible', 'off', ...
    'WindowStyle', 'modal');
createLayout();
movegui(inputFig); % Make sure it is visible
uiwait(inputFig);

    function createLayout()
        createBrowsePanel();
        createWriteGroupPanel();
        createOptionsGroupPanel();
        createButtonPanel();
    end

    function createBrowsePanel()
        browsePanel = uipanel('BorderType','none', ...
            'BackgroundColor',[.94 .94 .94],...
            'FontSize',12,...
            'Position',[0 .7 1 .3]);
        uicontrol('Parent', browsePanel, ...
            'Style','text', 'String', 'Study file', ...
            'Units','normalized',...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 0.8 0.1 0.13]);
        uicontrol('Parent', browsePanel, ...
            'Style','text', 'String', 'Base tags', ...
            'Units','normalized',...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 0.5 0.12 0.13]);
        uicontrol('Parent', browsePanel, ...
            'Style','text', 'String', 'Save tags', ...
            'Units','normalized',...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 .2 0.12 0.13]);
        studyCtrl = uicontrol('Parent', browsePanel, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'StudyEdit', 'String', '', ...
            'TooltipString', ...
            'EEG study file name', ...
            'Units','normalized',...
            'Callback', {@studyCtrlCallback}, ...
            'Position', [0.15 0.7 0.6 0.25]);
        tagsCtrl = uicontrol('Parent', browsePanel, 'style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'BaseTagsEdit', 'String', '', ...
            'TooltipString', ...
            'Directory of .set files for visualization', ...
            'Units','normalized',...
            'Callback', {@tagsCtrlCallback}, ...
            'Position', [0.15 0.4 0.6 0.25]);
        saveTagsCtrl = uicontrol('Parent', browsePanel, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'SaveTags', 'String', '', ...
            'TooltipString', ...
            'Complete path for saving the consolidated event tags', ...
            'Units','normalized',...
            'Callback', {@saveTagsCtrlCallback}, ...
            'Position', [0.15 0.1 0.6 0.25]);
        uicontrol('Parent', browsePanel, ...
            'string', 'Browse', ...
            'style', 'pushbutton', 'TooltipString', ...
            'Press to bring up file chooser chooser', ...
            'Units','normalized',...
            'Callback', {@browseStudyCallback, studyCtrl, ...
            'Browse for study file'}, ...
            'Position', [0.775 0.7 0.21 0.25]);
        uicontrol('Parent', browsePanel, ...
            'string', 'Browse', 'style', 'pushbutton', ...
            'TooltipString', 'Press to choose BaseTags file', ...
            'Units','normalized',...
            'Callback', {@browseTagsCallback, tagsCtrl, ...
            'Browse for base tags'}, ...
            'Position', [0.775 0.4 0.21 0.25]);
        uicontrol('Parent', browsePanel, ...
            'string', 'Browse', 'style', 'pushbutton', ...
            'TooltipString', 'Press to find directory to save tags object', ...
            'Units','normalized',...
            'Callback', {@browseSaveTagsCallback, saveTagsCtrl, ...
            'Browse for base tags'}, ...
            'Position', [0.775 0.1 0.21 0.25]);
    end % createBrowsePanel

    function createOptionsGroupPanel()
        % Create the button panel on the side of GUI
        optionGroupPanel = uipanel('BackgroundColor',[.94,.94,.94],...
            'FontSize',12,...
            'Title','Other options', ...
            'Position',[0.535 .2 .45 .5]);
        writeTagsCtrl = uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'WriteTagsCB', ...
            'String', 'Write tags to datasets', 'Enable', 'on', 'Tooltip', ...
            'Write tags to the .event and .etc fields of the datasets', ...
            'Units','normalized', ...
            'Callback', @writeTagsCallback, ...
            'Position', [0.1 0.85 0.8 0.1]);
        set(writeTagsCtrl, 'Value', get(writeTagsCtrl, 'Max'));
        u2 = uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'SelectOptionCB', ...
            'String', 'Use GUI to select fields to tag', 'Enable', 'on', 'Tooltip', ...
            'If checked, you will be presented with a GUI to select fields to tag', ...
            'Units','normalized', ...
            'Callback', @selectCallback, ...
            'Position', [0.1 0.7 0.8 0.1]);
        set(u2, 'Value', get(u2, 'Max'));
        u3 = uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'UseGUICB', ...
            'String', 'Use GUI to edit tags', 'Enable', 'on', 'Tooltip', ...
            'Use cTagger GUI to edit consolidated tags', ...
            'Units','normalized', ...
            'Callback', @useGUICallback, ...
            'Position', [0.1 0.55 0.8 0.1]);
        set(u3, 'Value', get(u2, 'Max'));
        u4 = uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'SaveAllCb', ...
            'String', 'Save to study datasets', 'Enable', 'on', 'Tooltip', ...
            'Save tags to study datasets in addition to study file', ...
            'Units','normalized', ...
            'Callback', @saveAllCallback, ...
            'Position', [0.1 0.4 0.8 0.1]);
        set(u4, 'Value', get(u4, 'Min'));
        editXmlCtrl = uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'editXml', ...
            'String', 'XML can be edited', 'Enable', 'on', 'Tooltip', ...
            'cTagger GUI to edit consolidated tags', ...
            'Units','normalized', ...
            'Callback', @editXmlCallback, ...
            'Position', [0.1 0.25 0.8 0.1]);
        set(editXmlCtrl, 'Value', get(editXmlCtrl, 'Min'));
        u5 = uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'PreservePrefixfield', ...
            'String', 'Preserve tag prefixes', 'Enable', 'on', 'Tooltip', ...
            'Do not consolidate tags that share prefixes', ...
            'Units','normalized', ...
            'Callback', @preservePrefixCallback, ...
            'Position', [0.1 0.1 0.8 0.1]);
        set(u5, 'Value', get(u4, 'Min'));
    end % createOptionsGroupPanel

    function createWriteGroupPanel()
        % Create the button panel on the side of GUI
%         rewriteGroupPanel = uipanel('BackgroundColor',[.94,.94,.94],...
%             'FontSize',12,...
%             'Title','Precision and save options', ...
%             'Position',[0.015 .2 .45 .5]);
                buttonGroup = uibuttongroup('BackgroundColor',[.94,.94,.94],...
            'FontSize',12,...
            'Title','Precision and save options', ...
            'Tag', 'abc', ...
            'SelectionChangeFcn', @rewriteCallback, ...
            'Position',[0.015 .2 .45 .5]);
        uicontrol('Parent', buttonGroup, ...
            'Style', 'RadioButton', 'Tag', 'Summary', ...
            'String', 'Double (.set file)', 'Enable', 'On', ...
            'Tooltip', 'Add tag summary to .etc.tags field of data', ...
            'Units','normalized', ...
            'Position', [0.1 0.8 0.8 0.1]);
        uicontrol('Parent', buttonGroup, ...
            'Style', 'RadioButton', 'Tag', 'Individual', ...
            'String', 'Single (.set file)', 'Enable', 'on', 'Tooltip', ...
            'Add tags to individual events in .events.usertags', ...
            'Units','normalized', ...
            'Position', [0.1 0.6 0.8 0.1]);
        rewriteCtrl = uicontrol('Parent', buttonGroup, ...
            'Style', 'RadioButton', 'Tag', 'Both', ...
            'String', 'Single (.set and .fdt)', 'Enable', 'on', 'Tooltip', ...
            ['Rewrites tag summary to .etc.tags and tags to ' ...
            'individual events through .event.usertags'], ...
            'Units','normalized', ...
            'Position', [0.1 0.4 0.8 0.1]);
        set(rewriteCtrl, 'Value', get(rewriteCtrl, 'Max'));
        uicontrol('Parent', buttonGroup, ...
            'Style', 'RadioButton', 'Tag', 'None', ...
            'String', 'Preserve', 'Enable', 'on', 'Tooltip', ...
            'Don'' write any tags to the data or clear existing tags', ...
            'Units','normalized', ...
            'Position', [0.1 0.2 0.8 0.1]);
    end % createRewriteGroupPanel


    function createButtonPanel()
        % Create the button panel on the side of GUI
        buttonPanel = uipanel('BorderType','none', ...
            'BackgroundColor',[.94 .94 .94],...
            'FontSize',12,...
            'Position',[0.6 0 .4 .2]);
        uicontrol('Parent', buttonPanel, ...
            'Style', 'pushbutton', 'Tag', 'OkayButton', ...
            'String', 'Okay', 'Enable', 'on', 'Tooltip', ...
            'Save the current configuration in a file', ...
            'Units','normalized', ...
            'Callback', {@okayCallback}, ...
            'Position',[0.025 0.3 0.45 0.4]);
        uicontrol('Parent', buttonPanel, ...
            'Style', 'pushbutton', 'Tag', 'CancelButton', ...
            'String', 'Cancel', 'Enable', 'on', 'Tooltip', ...
            'Cancel the directory tagging', ...
            'Units','normalized', ...
            'Callback', {@cancelCallback}, ...
            'Position',[0.515 0.3 0.45 0.4]);
    end % createButtonPanel

    function browseSaveTagsCallback(src, eventdata, saveTagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        startPath = get(saveTagsCtrl, 'String');
        if isempty(startPath) || ~ischar(startPath) || ~isdir(startPath)
            startPath = pwd;
        end
        dName = uigetdir(startPath, myTitle);  % Get
        if ~isempty(dName) && ischar(dName) && isdir(dName)
            saveMapFile = fullfile(dName, 'fMap.mat');
            set(saveTagsCtrl, 'String', saveMapFile);
        end
    end % browseSaveTagsCallback

    function browseStudyCallback(src, eventdata, studyCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [fName, fPath] = uigetfile({'*.*', 'All files(*.*)'}, myTitle);
        fName = fullfile(fPath, fName);
        if ~isempty(fName) && ischar(fName) && exist(fName, 'file')
            set(studyCtrl, 'String', fName);
            studyFile = fName;
        end
    end % browseStudyCallback

    function browseTagsCallback(src, eventdata, tagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [tFile, tPath] = uigetfile({'*.mat', 'MATLAB Files (*.mat)'}, myTitle);
        baseMap = fullfile(tPath, tFile);
        set(tagsCtrl, 'String', baseMap);
    end % browseTagsCallback

    function cancelCallback(src, eventdata)  %#ok<INUSD>
        % Callback for browse button sets a directory for control
        baseMap = '';
        cancelled = true;
        preservePrefix = false;
        rewriteCtrl = '';
        rewriteOption = 'Both';
        saveAll = true;
        saveMapFile = '';
        selectOption = true;
        studyFile = '';
        rewriteCtrl = '';
        editXmlCtrl = '';
        useGUI = true;
        close(inputFig);
    end % cancelTagsCallback

    function okayCallback(src, eventdata)  %#ok<INUSD>
        % Callback for closing GUI window
        cancelled = false;
        close(inputFig);
    end % okayCallback

    function preservePrefixCallback(src, eventdata) %#ok<INUSD>
        preservePrefix = get(src, 'Max') == get(src, 'Value');
    end % preservePrefixCallback

    function rewriteCallback(src, eventdata)    %#ok<INUSD>
        % Callback for the updateType button group
%         if ~isempty(rewriteCtrl)
%             set(rewriteCtrl, 'Value', get(rewriteCtrl, 'Min'));
%         end
        rewriteCtrl = src;
%         rewriteOption = lower(get(src, 'Tag'));
rewriteOption = get(get(src, 'SelectedObject'), 'Tag');
    end % rewriteCallback

    function saveAllCallback(src, eventdata) %#ok<INUSD>
        saveAll = get(src, 'Max') == get(src, 'Value');
    end % saveAllCallback

    function saveTagsCtrlCallback(hObject, eventdata, saveTagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        saveMapFile = get(hObject, 'String');
    end % tagsCtrlCallback

    function selectCallback(src, eventdata) %#ok<INUSD>
        selectOption = get(src, 'Max') == get(src, 'Value');
    end % selectCallback

    function studyCtrlCallback(hObject, eventdata) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        study = get(hObject, 'String');
        if exist(study, 'file')
            studyFile = study;
        else  % if user entered invalid directory reset back
            set(hObject, 'String', studyFile);
        end
    end % dirCtrlCallback

    function tagsCtrlCallback(hObject, eventdata, tagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        baseMap = get(hObject, 'String');
    end % tagsCtrlCallback

    function useGUICallback(src, eventdata) %#ok<INUSD>
        useGUI = get(src, 'Max') == get(src, 'Value');
        if ~useGUI
            editXml = false;
            set(editXmlCtrl, 'Enable', 'off', 'Value', ...
                get(editXmlCtrl, 'Min'));
        else
            set(editXmlCtrl, 'Enable', 'on');
        end
    end % useGUICallback

    function editXmlCallback(src, eventdata) %#ok<INUSD>
        editXml = get(src, 'Max') == get(src, 'Value');
    end % editXmlCallback

    function writeTagsCallback(src, eventdata) %#ok<INUSD>
        writeTags = get(src, 'Max') == get(src, 'Value');
        if ~writeTags
            set(rewriteCtrl, 'Enable', 'off');
        end
    end % writeTagsCallback

end % tagstudy_input