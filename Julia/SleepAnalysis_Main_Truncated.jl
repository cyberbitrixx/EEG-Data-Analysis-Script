# November 2022- update to LM_SleepAnalysis_100622.m
# Michael Rempe


# Load all parameters from InputParameters.jl
include("InputParamsKatelynP24.jl")
include("Extract_EEG_data.jl")
S = InputParamsKatelynP24()

println("I am using the input parameters file $(S["FileName"]) which contains the function $(S["FuncName"])")
println("If this is not what you intended, please cancel and start over.")

epochs = S["epochs"]
numhrs = S["numhrs"]
Light = S["Light"]
Dark = S["Dark"]
swa = S["swa"]
WakeEpocsDWTBL = S["WakeEpocsDWTBL"]
NREMEpocsDWTBL = S["NREMEpocsDWTBL"]
REMEpocsDWTBL = S["REMEpocsDWTBL"]
SD_length_hrs = S["SD_length_hrs"]
epoch_duration_secs = S["epoch_duration_secs"]
firstNREM_episode_duration_epochs = S["firstNREM_episode_duration_epochs"]
NREM_char = S["NREM_char"]
EEGLowerLimit_Hz = S["EEGLowerLimit_Hz"]

Bout_Minimums = S["Bout_Minimums"]

LegendLabels = S["LegendLabels"]

# If Analyze_TIS_DP_6hr_segments is not there, assume a reasonable default
Analyze_TIS_DP_6hr_segments = get(S, "Analyze_TIS_DP_6hr_segments", false)

EEGLowerLimit_Hz = get(S, "EEGLowerLimit_Hz", 0.25)

Normalization = get(S, "Normalization", "MeanPowerAllStates")

PlotHourlyBaselineNREM_Delta = get(S, "PlotHourlyBaselineNREM_Delta", false)

SeparateSpectralIntoLPDP = get(S, "SeparateSpectralIntoLPDP", false)

Analyze_Recovery_2hr_bins = get(S, "Analyze_Recovery_2hr_bins", false)

# Paths to data
path_to_WT_BL_Males_files = S["path_to_WT_BL_Males_files"]
path_to_WT_SD_Males_files = S["path_to_WT_SD_Males_files"]
path_to_Mut_BL_Males_files = S["path_to_Mut_BL_Males_files"]
path_to_Mut_SD_Males_files = S["path_to_Mut_SD_Males_files"]
path_to_WT_BL_Females_files = S["path_to_WT_BL_Females_files"]
path_to_WT_SD_Females_files = S["path_to_WT_SD_Females_files"]
path_to_Mut_BL_Females_files = S["path_to_Mut_BL_Females_files"]
path_to_Mut_SD_Females_files = S["path_to_Mut_SD_Females_files"]

load_data_from_mat_file_instead = S["load_data_from_mat_file_instead"]
MatFileContainingData = S["MatFileContainingData"]

# Function to get file list
function get_file_list(path)
    isempty(path) ? String[] : filter(f -> endswith(f, ".csv"), readdir(path))
end

ffl_list_WT_BL_Males = get_file_list(path_to_WT_BL_Males_files)
ffl_list_WT_SD_Males = get_file_list(path_to_WT_SD_Males_files)
ffl_list_Mut_BL_Males = get_file_list(path_to_Mut_BL_Males_files)
ffl_list_Mut_SD_Males = get_file_list(path_to_Mut_SD_Males_files)
ffl_list_WT_BL_Females = get_file_list(path_to_WT_BL_Females_files)
ffl_list_WT_SD_Females = get_file_list(path_to_WT_SD_Females_files)
ffl_list_Mut_BL_Females = get_file_list(path_to_Mut_BL_Females_files)
ffl_list_Mut_SD_Females = get_file_list(path_to_Mut_SD_Females_files)

total_recordings = sum(length.([
    ffl_list_WT_BL_Males, ffl_list_WT_SD_Males,
    ffl_list_Mut_BL_Males, ffl_list_Mut_SD_Males,
    ffl_list_WT_BL_Females, ffl_list_WT_SD_Females,
    ffl_list_Mut_BL_Females, ffl_list_Mut_SD_Females
]))

println("You are running the code on $total_recordings recordings total.")

# Testing
(swaNREMhourly, swaREMhourly, swaWakehourly, EEG_Wake, EEG_NREM, EEG_REM, Wake24h, NREM24h, REM24h, Scores, EEG_bin_edges) = Extract_EEG_data(path_to_WT_BL_Males_files, ffl_list_WT_BL_Males, epochs, numhrs, swa, EEGLowerLimit_Hz)


# DEBUG
# Here's what we're checking with these print statements:

# Whether the script runs to completion
# If it's finding the WT BL Males files correctly
# If the Extract_EEG_data function is returning data as expected
# The shape and content of some of the key variables

println("Script executed successfully!")
println("Number of WT BL Males files: ", length(ffl_list_WT_BL_Males))
println("First few NREM hourly SWA values: ", swaNREMhourly[1:min(5, length(swaNREMhourly))])
println("Size of EEG_NREM: ", size(EEG_NREM))
println("First few Scores: ", Scores[1:min(10, length(Scores))])