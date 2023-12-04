function CopyofMappingDataRequiredFormat = importfile1(workbookFile, sheetName, dataLines)
%IMPORTFILE1 Import data from a spreadsheet
%  COPYOFMAPPINGDATAREQUIREDFORMAT = IMPORTFILE1(FILE) reads data from
%  the first worksheet in the Microsoft Excel spreadsheet file named
%  FILE.  Returns the data as a string array.
%
%  COPYOFMAPPINGDATAREQUIREDFORMAT = IMPORTFILE1(FILE, SHEET) reads from
%  the specified worksheet.
%
%  COPYOFMAPPINGDATAREQUIREDFORMAT = IMPORTFILE1(FILE, SHEET, DATALINES)
%  reads from the specified worksheet for the specified row interval(s).
%  Specify DATALINES as a positive scalar integer or a N-by-2 array of
%  positive scalar integers for dis-contiguous row intervals.
%
%  Example:
%  CopyofMappingDataRequiredFormat = importfile1("C:\Users\monghass\MATLAB Drive\MBCOS Robust Model v105 - CCD\auxiliary functions\commute assessment v1\Copy of Mapping Data Required Format.xlsx", "Address + Shift Format", [1, 273]);
%
%  See also READMATRIX.
%
% Auto-generated by MATLAB on 27-Jul-2022 18:11:23

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [1, 273];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 8);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":H" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["Employee", "EmployeeTitle", "EmployeeDept", "Address", "City", "State", "Zipcode", "Shift"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string"];

% Specify variable properties
opts = setvaropts(opts, ["Employee", "EmployeeTitle", "EmployeeDept", "Address", "City", "State", "Zipcode", "Shift"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Employee", "EmployeeTitle", "EmployeeDept", "Address", "City", "State", "Zipcode", "Shift"], "EmptyFieldRule", "auto");

% Import the data
CopyofMappingDataRequiredFormat = readmatrix(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":H" + dataLines(idx, 2);
    tb = readmatrix(workbookFile, opts, "UseExcel", false);
    CopyofMappingDataRequiredFormat = [CopyofMappingDataRequiredFormat; tb]; %#ok<AGROW>
end

end