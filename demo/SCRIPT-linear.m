function SCRIPT-linear
% code used in the preparation of the paper

%% Preamble
toolboxPath = '/Users/benvincent/git-local/delayDiscounting/ddToolbox';
addpath(genpath(toolboxPath)) 

projectPath = '/Users/benvincent/git-local/delayDiscounting/demo';
cd(projectPath)


%% Create data object

% create a cell array of which participant files to import
fnames={%'AC-kirby27-DAYS.txt',...
%'CS-kirby27-DAYS.txt',...
%'NA-kirby27-DAYS.txt',...
%'SB-kirby27-DAYS.txt',...
'bv-kirby27.txt',...
'rm-kirby27.txt',...
'vs-kirby27.txt',...
'BL-kirby27.txt',...
'EP-kirby27.txt',...
'JR-kirby27.txt',...
'KA-kirby27.txt',...
'LJ-kirby27.txt',...
'LY-kirby27.txt',...
'SK-kirby27.txt',...
'VD-kirby27.txt'};
% Participant-level data will be aggregated into a larger group-level text
% file and saved in \data\groupLevelData for inspection. Choose a
% meaningful filename for this group-level data
saveName = 'methodspaper-kirby27.txt';

% create the group-level data object
kirbyData = dataClass(saveName);
kirbyData.loadDataFiles(fnames);

%% Add covariate values to the data object
% !!!! I HAVE NO COVARIATE DATA, SO TEST WITH MADE UP DATA !!!!!!!!!!!!!!!!
%covariateValues = randn([1, kirbyData.nParticipants])*5+22; % random data
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

covariateValues=[%NaN,...
%NaN,...
%NaN,...
%NaN,...
35,...
20,...
20,... %VS
19,...
20,...
18,...
19,...
21,...
19,...
19,...
23];

kirbyData.setCovariateValues(covariateValues);
kirbyData.setCovariateProbeValues([5:5:80]);




%% Analyse the data with the linear covariate model

LModel = modelLINEAR(toolboxPath);
% change some options
LModel.setMCMCtotalSamples(10000);
LModel.setMCMCnumberOfChains(2);

LModel.conductInference(kirbyData);

LModel.plotCovariates(kirbyData)


LModel.plot(kirbyData)



return