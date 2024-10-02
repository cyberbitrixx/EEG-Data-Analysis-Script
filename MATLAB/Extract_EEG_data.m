function [swaNREMhourly,swaREMhourly,swaWakehourly,EEG_Wake,EEG_NREM,EEG_REM,Wake24h,NREM24h,REM24h,Scores,EEG_bin_edges] = Extract_EEG_data(path_to_files,ffl_list,epochs,numhrs,swa,EEGLowerLimit_Hz)

% Each .mat file in ffl_list contains a table called EEG


% First make sure the structs being read in are not empty (if no female data, for instance)
if isempty(ffl_list)
	
	swaNREMhourly = [];
	swaREMhourly  = [];
	swaWakehourly = [];
	EEG_Wake      = [];
	EEG_NREM      = [];
	EEG_REM       = [];
	Wake24h       = [];
	NREM24h       = [];
	REM24h        = [];
	Scores        = [];
	EEG_bin_edges = [];

	return
end  



for anim=1:length(ffl_list)
    anim
    clear  NdxNOgood NdxWake NdxNREM NdxREM swaNonGoodNR swaNonGoodR swaNonGoodW Data
    load ([path_to_files,ffl_list{anim}]);

    
    if width(EEG)~=208
    	error('The table EEG does not have the correct number of columns.  I am expecting 208, with 0.25Hz frequency bins.')
    end
    %EEG_FFT_table = EEG(:,8:208); 		% was EEG(:,4:208) where the epoch data starts, all rows 	EEG is a table loaded with the load command.  was EEG(:,5:55) before 
    
    EEG_Score = EEG.Stage; 			% column 2 has state name (WA, N, R etc)
    Scores{anim} = EEG.Stage;
	Scores{anim} = Scores{anim}(~cellfun('isempty',Scores{anim}));

    F = EEG.Properties.VariableNames; 	% frequency data 
    
    for i=4:length(F)
    	EEG_bin_edges{anim}(i-3) = str2num(strrep(F{i},'Hz',''));
	end

	
	colHzstart  = find(abs(EEG_bin_edges{anim} - EEGLowerLimit_Hz) == min(abs(EEG_bin_edges{anim} - EEGLowerLimit_Hz)));	% find the column with Hz closest to EEGLowerLimit_Hz
	
	EEG_FFT_table = EEG(:,colHzstart+3:208);	% the +3 is because there are 3 columns we are ignoring (and they are not in EEG_bin_edges): EpochNum, Stage, Time
    EEG_FFT = table2array(EEG_FFT_table);
    if iscell(EEG_FFT_table{1,4})
    	EEG_FFT = cell2mat(EEG_FFT);
	end
	
	% find the artefact epocs and set the to NaN (Not a Number), to
	% remove from the spectral analysis

    NdxNOgood = find(strcmp(EEG_Score,'W*')| strcmp(EEG_Score,'N*')| strcmp(EEG_Score,'R*'));
    EEG_FFT(NdxNOgood,:)=NaN;

	% SPECTRA:
	% Find all epochs of each stage

    %here are you just renaming all rows with W, N, R to ND wake, REM,

    NdxWake = find(strcmp(EEG_Score,'WA')| strcmp(EEG_Score,'W')); % 
    NdxNREM = find(strcmp(EEG_Score,'N') | strcmp(EEG_Score,'NR')); % **also changed
    NdxREM  = find(strcmp(EEG_Score,'R'));
	% to get the spectra per hour-so the hourly average of that freq bin

    clear i EEGWakehourly EEGNREMhourly EEGREMhourly
    
    for i=1:numhrs  %%%% if you want to change that to 2h, change the "epochs" to 1800 

        % this is average of that frequency range per hour 

       
    	Windx = find(NdxWake>=(i*epochs-epochs+1)& NdxWake<=(i*epochs));
    	Sindx = find(NdxNREM>=(i*epochs-epochs+1)& NdxNREM<=(i*epochs));
    	Rindx = find(NdxREM >=(i*epochs-epochs+1)& NdxREM <=(i*epochs));

    	EEGWakehourly(i,:) = mean(EEG_FFT((NdxWake(Windx)),:),1,'omitnan'); % 1 creates 1 row- so this will be one row of 24 hours
    	EEGNREMhourly(i,:) = mean(EEG_FFT((NdxNREM(Sindx)),:),1,'omitnan');
    	EEGREMhourly(i,:)  = mean(EEG_FFT((NdxREM(Rindx)),:),1,'omitnan');  
	end

	% per animal over all frequency bands (205 used to be 50), averaged per hour
	% These all should be 24 x 205 (24 hours, 205 frequency bands). 

    EEG_Wake(:,:,anim) = (EEGWakehourly);  
    EEG_NREM(:,:,anim) = (EEGNREMhourly);
    EEG_REM(:,:,anim)  = (EEGREMhourly);

	% SLEEP TIMING
	% count how many epochs per hour per state, include the artefacts -->
    for i=1:numhrs
		Num_W_epochs(i) = size(find(strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'WA')|strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'W*')|strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'W')),1);
        Num_S_epochs(i) = size(find(strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'N') |strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'N*')|strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'NR')),1);
        Num_R_epochs(i) = size(find(strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'R') |strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'R*')|strcmp(EEG_Score((i*epochs-epochs+1):(i*epochs),:),'RR')),1);
    end

	% to get minutes per hour in a stage
	Wake24h(:,anim) = (Num_W_epochs*4)/60; 
    NREM24h(:,anim) = (Num_S_epochs*4)/60;
    REM24h(:,anim)  = (Num_R_epochs*4)/60;
	
	% SWA

    %get the swa in NREM/ REM and Wake extracted
	% mark every non NREM epoch as NaN (or similar for REM and Wake)

    swaNonGoodNR = find(strcmp(EEG_Score,'R')| strcmp(EEG_Score,'WA')| strcmp(EEG_Score,'R*')| strcmp(EEG_Score,'W*')| strcmp(EEG_Score,'N*')| strcmp(EEG_Score,'W') | strcmp(EEG_Score,'RR'));
    swaNonGoodR  = find(strcmp(EEG_Score,'N')| strcmp(EEG_Score,'WA')| strcmp(EEG_Score,'N*')| strcmp(EEG_Score,'W*')| strcmp(EEG_Score,'R*')| strcmp(EEG_Score,'NR'));
    swaNonGoodW  = find(strcmp(EEG_Score,'N')| strcmp(EEG_Score,'R') | strcmp(EEG_Score,'N*')| strcmp(EEG_Score,'R*')| strcmp(EEG_Score,'W*')| strcmp(EEG_Score,'NR') | strcmp(EEG_Score,'RR'));

   
   
    FFT_NR  = EEG_FFT; %assigning FFTa 
    FFT_REM = EEG_FFT;
    FFT_W   = EEG_FFT;

    FFT_NR(swaNonGoodNR,:)=NaN; %%excluding artifacts 
	FFT_REM(swaNonGoodR,:)=NaN;
	FFT_W(swaNonGoodW,:)  =NaN;
	
	% SWA as average of the bins 0.9 -3.9Hz (bin 2:5 if you are doing 1Hz bins), over 1h, if you
	%want 2h change to [epochs 12] , alternative you can sum the bins,
	% but needs to mentioned in the methods!!
	col_headers_freqs = EEG_FFT_table.Properties.VariableNames;
	binHzvalues = strrep(col_headers_freqs,'Hz','');
	binHzvalues = cellfun(@str2num,binHzvalues);
	
	ZeroPtNine_ColNum  = find(binHzvalues==interp1(binHzvalues,binHzvalues,0.9,'nearest','extrap'));
	ThreePtNine_ColNum = find(binHzvalues==interp1(binHzvalues,binHzvalues,3.9,'nearest'));


   	C = find(NdxNREM>=(i*epochs-epochs+1)& NdxNREM<=(i*epochs));
    EEGNREMhourly(i,:) = mean(EEG_FFT((NdxNREM(C)),:),1,'omitnan');

   	swaNREM(anim,:) = mean(FFT_NR(:,ZeroPtNine_ColNum:ThreePtNine_ColNum),2,'omitnan')'; %% ******is this all rows change all after talking to christine
   	swaNREMhourly(anim,:) = mean(reshape(swaNREM(anim,:),swa),1,'omitnan');  

   	% swaNREMMutSD(anim,:) = swaNREM;
   	% swaNREMMutSDhourly(anim,:)=swaNREMhourly;
   
   	swaREM(anim,:) = mean(FFT_REM(:,ZeroPtNine_ColNum:ThreePtNine_ColNum),2,'omitnan')';  % swa in REM
   	swaREMhourly(anim,:) = mean(reshape(swaREM(anim,:),swa),1,'omitnan');
   	% swaREMMutSD(anim,:)=swaREM;
   	% swaREMMutSDhourly(anim,:)=swaREMhourly;
   
   	swaWake(anim,:) = mean(FFT_W(:,ZeroPtNine_ColNum:ThreePtNine_ColNum),2,'omitnan')';  % swa in wake
   	swaWakehourly(anim,:) = mean(reshape(swaWake(anim,:),swa),1,'omitnan');

   	% swaWakeMutSD(anim,:)=swaWake;
   	% swaWakeMutSDhourly(anim,:)=swaWakehourly;
   
end  % End of main for loop (looping over .mat files)


% Make sure the frequency bin edges are the same for each animal
if ~all(cellfun(@(e) isequal(size(EEG_bin_edges{1}), size(e)) , EEG_bin_edges(2:end)))
	error('In Extract_EEG_data: Not every animal has the same frequency bins.')
else 
	EEG_bin_edges = EEG_bin_edges{1};
end 



