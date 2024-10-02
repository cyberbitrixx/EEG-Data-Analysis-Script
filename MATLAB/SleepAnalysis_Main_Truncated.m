% November 2022- update to LM_SleepAnalysis_100622.m 
% Michael Rempe  
 
close all hidden;
clear all;


%  --- Load all parameters from InputParameters.m (Change this line to your input file name saved in the same directory. ie if your file is called MyInputParams.m you will have S=MyInputParams;)
%S = InputParamsLizzy;
%S = InputParamsAbrar;
S = InputParamsKatelynP24;
%S = InputParamsKatelynP30;





% ----- You shouldn't need to change anything below this line ------------------------------------------
% ------------------------------------------------------------------------------------------------------
disp(['I am using the input parameters file ',S.FileName,' which contains the function ',S.FuncName])
disp('If this is not what you intended, please cancel and start over.')
epochs = S.epochs;               
numhrs = S.numhrs;
Light  = S.Light;       
Dark   = S.Dark;        
swa    = S.swa;         
WakeEpocsDWTBL      = S.WakeEpocsDWTBL;         
NREMEpocsDWTBL      = S.NREMEpocsDWTBL;
REMEpocsDWTBL       = S.REMEpocsDWTBL;
SD_length_hrs       = S.SD_length_hrs;
epoch_duration_secs = S.epoch_duration_secs;
firstNREM_episode_duration_epochs = S.firstNREM_episode_duration_epochs;  
NREM_char = S.NREM_char; 
EEGLowerLimit_Hz = S.EEGLowerLimit_Hz; 

Bout_Minimums.W = S.Bout_Minimums.W;        
Bout_Minimums.N = S.Bout_Minimums.N;
Bout_Minimums.R = S.Bout_Minimums.R;
LegendLabels = S.LegendLabels; 

% If Analyze_TIS_DP_6hr_segments is not there, assume a reasonable default
if isfield(S,'Analyze_TIS_DP_6hr_segments')
    Analyze_TIS_DP_6hr_segments = S.Analyze_TIS_DP_6hr_segments;
else
    Analyze_TIS_DP_6hr_segments = false;
end 

if isfield(S,'EEGLowerLimit_Hz')
    EEGLowerLimit_Hz = S.EEGLowerLimit_Hz;
else
    EEGLowerLimit_Hz = 0.25;
end 

if isfield(S,'Normalization')
    Normalization = S.Normalization;
else
    Normalization = 'MeanPowerAllStates'; %'AreaUnderCurve'; %3.22.24: Marcos said to make MeanPower the default
end 

if isfield(S,'PlotHourlyBaselineNREM_Delta')
    PlotHourlyBaselineNREM_Delta = S.PlotHourlyBaselineNREM_Delta;
else
    PlotHourlyBaselineNREM_Delta = false;
end

if isfield(S,'SeparateSpectralIntoLPDP')
    SeparateSpectralIntoLPDP = S.SeparateSpectralIntoLPDP;
else
    SeparateSpectralIntoLPDP = false;
end


if isfield(S,'Analyze_Recovery_2hr_bins')
    Analyze_Recovery_2hr_bins = S.Analyze_Recovery_2hr_bins;
else
    Analyze_Recovery_2hr_bins = false;
end


% Paths to data
path_to_WT_BL_Males_files    = S.path_to_WT_BL_Males_files;
path_to_WT_SD_Males_files    = S.path_to_WT_SD_Males_files;
path_to_Mut_BL_Males_files   = S.path_to_Mut_BL_Males_files;
path_to_Mut_SD_Males_files   = S.path_to_Mut_SD_Males_files;
path_to_WT_BL_Females_files  = S.path_to_WT_BL_Females_files;
path_to_WT_SD_Females_files  = S.path_to_WT_SD_Females_files;
path_to_Mut_BL_Females_files = S.path_to_Mut_BL_Females_files;
path_to_Mut_SD_Females_files = S.path_to_Mut_SD_Females_files;

load_data_from_mat_file_instead = S.load_data_from_mat_file_instead; 
MatFileContainingData = S.MatFileContainingData; 



if ~isempty(path_to_WT_BL_Males_files)
    ffl_list_WT_BL_Males    = {dir(fullfile(path_to_WT_BL_Males_files, '*.mat')).name};     else ffl_list_WT_BL_Males    = {}; end
if ~isempty(path_to_WT_SD_Males_files)
    ffl_list_WT_SD_Males    = {dir(fullfile(path_to_WT_SD_Males_files, '*.mat')).name};     else ffl_list_WT_SD_Males    = {}; end
if ~isempty(path_to_Mut_BL_Males_files)
    ffl_list_Mut_BL_Males   = {dir(fullfile(path_to_Mut_BL_Males_files,'*.mat')).name};    else ffl_list_Mut_BL_Males   = {}; end
if ~isempty(path_to_Mut_SD_Males_files)
    ffl_list_Mut_SD_Males   = {dir(fullfile(path_to_Mut_SD_Males_files,'*.mat')).name};    else ffl_list_Mut_SD_Males   = {}; end
if ~isempty(path_to_WT_BL_Females_files)
    ffl_list_WT_BL_Females  = {dir(fullfile(path_to_WT_BL_Females_files, '*.mat')).name}; else ffl_list_WT_BL_Females  = {}; end
if ~isempty(path_to_WT_SD_Females_files)
    ffl_list_WT_SD_Females  = {dir(fullfile(path_to_WT_SD_Females_files, '*.mat')).name}; else ffl_list_WT_SD_Females  = {}; end 
if ~isempty(path_to_Mut_BL_Females_files)
    ffl_list_Mut_BL_Females = {dir(fullfile(path_to_Mut_BL_Females_files,'*.mat')).name};else ffl_list_Mut_BL_Females = {}; end
if ~isempty(path_to_Mut_SD_Females_files)
    ffl_list_Mut_SD_Females = {dir(fullfile(path_to_Mut_SD_Females_files,'*.mat')).name};else ffl_list_Mut_SD_Females = {}; end

total_recordings = length(ffl_list_WT_BL_Males)  + length(ffl_list_WT_SD_Males)  + ...
                   length(ffl_list_Mut_BL_Males) + length(ffl_list_Mut_SD_Males) + ...
                   length(ffl_list_WT_BL_Females)  + length(ffl_list_WT_SD_Females)  + ...
                   length(ffl_list_Mut_BL_Females) + length(ffl_list_Mut_SD_Females);                
disp(['You are running the code on ',num2str(total_recordings),' recordings total.'])
% -------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------

% Male Mut SleepDep
[swaNREMMutSDhourly,swaREMMutSDhourly,swaWakeMutSDhourly,EEGMutSDWake,EEGMutSDNREM,EEGMutSDREM,Wake24hMutSD,NREM24hMutSD,REM24hMutSD,Scores.Male.Mut.SD,EEG_bin_edgesMutSDM] = Extract_EEG_data(path_to_Mut_SD_Males_files,ffl_list_Mut_SD_Males,epochs,numhrs,swa,EEGLowerLimit_Hz); 
