using Random

# Function to create placeholder directories and files
function create_placeholder_structure(base_path)
    for condition in ["WT_BL_M", "WT_SD_M", "Ube3aHET_BL_M", "Ube3aHET_SD_M",
        "WT_BL_F", "WT_SD_F", "Ube3aHET_BL_F", "Ube3aHET_SD_F"]
        dir_path = joinpath(base_path, "P24", condition)
        mkpath(dir_path)

        # Create 3 placeholder CSV files in each directory
        for i in 1:3
            file_path = joinpath(dir_path, "placeholder_$(i).csv")
            open(file_path, "w") do f
                println(f, "This is a placeholder CSV file")
                println(f, "RandomData,Value")
                for j in 1:5
                    println(f, "$(randstring(5)),$(rand())")
                end
            end
        end
    end
end

# Create the placeholder structure
base_path = joinpath(homedir(), "Desktop", "EEG_Placeholder_Data")
create_placeholder_structure(base_path)

println("Placeholder directories and files created at: $base_path")
