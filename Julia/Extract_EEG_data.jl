# Define the function

function Extract_EEG_data(path_to_files, ffl_list, epochs, numhrs, swa, EEGLowerLimit_Hz)
    # Function body

    # DEBUG
    println("Function Extract_EEG_data called")
    println("Input parameters:")
    println("  path_to_files: ", path_to_files)
    println("  ffl_list: ", ffl_list)
    println("  epochs: ", epochs)
    println("  numhrs: ", numhrs)
    println("  swa: ", swa)
    println("  EEGLowerLimit_Hz: ", EEGLowerLimit_Hz)

    # First make sure the structs being read in are not empty (if no female data, for instance)
    if isempty(ffl_list)
        # If emoty, return empty arrays for all outputs (MATLAB approach since MATLAB is strict about fixated amount of types that should be returned)
        println("ffl_list is empty, returning empty arrays") # DEBUG
        #return [], [], [], [], [], [], [], [], [], [], []

        # More clean approach (sine Julia provides more flexibility with it)
        return [] # or "return nothing" (return nil, None, "no data")
    end


    println("ffl_list is not empty, continuing with function execution")
    # return [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11]

    # Return statement in the end
    swaNREMhourly = 0
    swaREMhourly = 0
    swaWakehourly = 0
    EEG_Wake = 0
    EEG_NREM = 0
    EEG_REM = 0
    Wake24h = 0
    NREM24h = 0
    REM24h = 0
    Scores = 0
    EEG_bin_edges = 0
    return swaNREMhourly, swaREMhourly, swaWakehourly, EEG_Wake, EEG_NREM, EEG_REM, Wake24h, NREM24h, REM24h, Scores, EEG_bin_edges
end
