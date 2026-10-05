%% Show a movie.
%
% Opens a movie to be played to the infant to capture attention.
% The movie will end if there is a key press. However, the volume buttons
% can still be used and the left and right arrow keys can be used to
% rewind/fastforward
%
%
%SC 03/15/2021 (modeled off of Childplay)

function Data=Experiment_Saycam(varargin)

% If debugging on mac then do this, otherwise don't
if ismac == 1
    Screen('Preference', 'SkipSyncTests', 1);
end

%Set variables
ChosenBlock=varargin{1};
Window=varargin{2};
Conditions=varargin{3};
%OldData=varargin{4}; % add this to keep track of when last started

KbQueueFlush(Window.KeyboardNum);
fprintf('Saycam. %s\n\n', Conditions.Parameters.BlockNames{ChosenBlock});

fprintf('\n\n-----------------------Start of Block--------------------------\n\n');

Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('Start_of_Block_Time:_%0.3f', GetSecs));

%% Parameter conditions

% Set up the video size
%video_width = 40 * Window.ppd;

% platform-independent responses
%KbName('UnifyKeyNames');
flipTime = Screen('GetFlipInterval',Window.onScreen);

%store the ITI
%Data.Timing.Starting_Delay=round(ITI/flipTime)*flipTime;

%% attention getter
%flipTime = Window.frameTime;

% What frame will the turn end
%total_turn_frames = (Conditions.Parameters.Pre_turn_frames + Conditions.Parameters.interpolation_steps);

%Stimulus  conditions
Fixation_Size=5*Window.ppd; %How many fixual degrees does the image take up
Fixation_OscillationPeriod=2.5; %What is the period of a rotation
Fixation_ScalingRange= [.5, 1.5]; %What proportion of the image is the min and max?
FramesPerOscillation=round(Fixation_OscillationPeriod/flipTime); %How many frames fit into an oscillation

% Get the colors used for the fixation
ColorList=[91,192,235;... %Blue
    253,231,76;... %Yellow
    250,53,226;... %Purple
    155,197,61;... %Green
    229,89,52];    %Orange

% Set up the video size
video_width = 40 * Window.ppd;

%Specify some screen attributes
screenX = Window.screenX;
screenY = Window.screenY;
centerX = Window.centerX;
centerY = Window.centerY;

% What movie do you have to be on before a quit will result in data that is
% usable. If it is 2 then it means that at least one movie must be viewed
% before a quit for you to use it.
min_movie_number = 2;

%%

% Decide whether you are waiting for TR based on whether you are connected
% to the scanner
VideoStruct.WaitforTR=Window.isfMRI;

%Is the rect value a proportion of the screen or in pixels?
if all(Conditions.Parameters.Rect<1)
    
    RectValues([1,3])=Conditions.Parameters.Rect([1,3]).*Window.Rect(3);
    RectValues([2,4])=Conditions.Parameters.Rect([2,4]).*Window.Rect(4);
    
else %If pixels then just use that value
    
    RectValues=Conditions.Parameters.Rect;
end

VideoStruct.MovieRect= RectValues;


%Set no timing constraints
TimingStruct.Preload=Conditions.Parameters.Preload;
TimingStruct.PlannedOnset=0;

%Set the input constraints
InputStruct.isEyeTracking=Window.isEyeTracking; %Is eye tracking being used?

%No longer used in most recent Utils_PlayAV
%InputStruct.isAnticipationError=Conditions.Parameters.isAnticipationError; %Will a sound be played if there is a key press?

% Make it so a key press terminates the video
% InputStruct.isResponseTermination=1; % No longer used

% Start the eye tracker
Utils_EyeTracker_TrialStart(Window.EyeTracking);
Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('Start_of_Block_Time:_%0.3f', GetSecs));

%%

% Preset
Data.Timing.TR=[];
Data.Quit=0;
Quit=Data.Quit;

%Preset some variables

Data.MovieChoice={};
Data.MovieStartTime=[];
Data.setname=[];

%%


%while Quit == 0

%for ChosenBlock=1:length(Conditions.Parameters.BlockNum)
ThisSet=Conditions.Parameters.BlockNames{ChosenBlock};
PresentationOrder = Conditions.Stimuli.(sprintf(ThisSet));%(sprintf('set_%s',num2str(ChosenBlock)))'; %convert to row
%  PresentationOrder(2,:) = repmat(str2num(Conditions.Parameters.BlockNames{ChosenBlock}),1,length(PresentationOrder));%put the block names in the next row??

F=strfind(ThisSet,'_');
if length(ThisSet)==5;
    SetNum =str2num(ThisSet(5)); 
elseif length(ThisSet)==6;
     SetNum =str2num(ThisSet(5:6)); 
end

PresentationOrder_condnames=Conditions.Parameters.Stimulitype_cell(:,SetNum)';
PresenationOrder_vidnames=Conditions.Parameters.Stimulitype_vidname(:,SetNum)';

currITI =Conditions.Parameters.ITIs(ChosenBlock,:);

for MovieCounter=1:length(PresentationOrder);
    
    ChosenVideo= PresentationOrder{MovieCounter};%video path
    ChosenStim=PresentationOrder_condnames{MovieCounter}; %exp condition name
    
    
    %playvideo
    if Quit==0
        
        VideoStruct.VideoNames=char(ChosenVideo);
        
        %eyetrack
        
        Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('Movie_Start_Time:_%0.3f', GetSecs));
        if VideoStruct.WaitforTR == 1
            Utils_EyeTracker_TrialStart(Window.EyeTracking);
        end
        
        VideoStruct.MovieWatched=0;
        
        
        %Store the video name with the starting time
        Data.MovieChoice{end+1}=ChosenVideo; %video path
        Data.MovieStartTime(end+1)=GetSecs;
        Data.setname{end+1}=ThisSet;
        %Data.setname=Conditions.Parameters.BlockNames;
        
        %                             %What movie number is this?
        %                             MovieCounter=length(Data.MovieStartTime);
        
        %Store the video struct information. Do so just before playing so
        %that Window.NextTR is up to date
        VideoStruct.window=Window;
        
        [Data.Timing.(sprintf('Movie_%d', MovieCounter)), Data.Responses.(sprintf('Movie_%d', MovieCounter)), Data.GazeData.(sprintf('Movie_%d', MovieCounter))]=Utils_PlayAV(VideoStruct, [], TimingStruct, InputStruct); %Plays the movie
        
        %stop the eyetracker
        Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('Movie_Stop_Time:_%0.3f', GetSecs));
        
        
        if VideoStruct.WaitforTR == 1
            Utils_EyeTracker_TrialEnd(Window.EyeTracking);
            Window.ScannerisRunning = 1;
        end
        
        
        %If the experimenter pressed q during the presentation then return
        if (Data.Responses.(sprintf('Movie_%d', MovieCounter)).Quit == 1)
            Quit=1;
            
            %Record whether that this was quit preemptively. Decide how
            %many movies is required before you plan to use a block
            if MovieCounter >= min_movie_number
                Data.Quit=0;
            else
                Data.Quit=1;
            end
            fprintf('\nBlock Terminated\n\n');
            
        elseif MovieCounter== length(PresentationOrder)
            
            fprintf('\nExiting experiment because movie has finished\n\n');
            
            %Once the movie has finished quit but don't record it as a quit
            Data.Quit=0;
        end
        
        
        %Append the TR values to the list that grows with every movie
        if Window.isfMRI && ~isempty(Data.Timing.(sprintf('Movie_%d', MovieCounter)).TR)
            Data.Timing.TR=[Data.Timing.TR, Data.Timing.(sprintf('Movie_%d', MovieCounter)).TR];
            Window.NextTR=Data.Timing.TR(end);
        end
        
        fprintf('\n\nMovie end');
        fprintf('\n\nFinished Movie_%d from set_%d: Condition is %s', MovieCounter, SetNum, ChosenStim);
       % fprintf('\n\nVideo name is %s', PresenationOrder_vidnames{MovieCounter});

        
        %% ITI
        %what do i want in the background? %fixation?
        %Animation
        % Screen(Window.onScreen,'FillRect',Window.bcolor);
        %Screen('DrawTexture', Window.onScreen, BackgroundTex(GifCounter), [], BackRect);
        
        %% Generate the fixation stimulus
        
        %Select one of the above colors at random for the inner and outer
        %shapes
        
        OuterColorIdx=randi([1, size(ColorList,1)]); %What color is being called?
        InnerColorIdx=randi([1, size(ColorList,1)]);
        
        Fixation_OuterColor=uint8(ColorList(OuterColorIdx, :));
        
        Fixation_InnerColor=uint8(ColorList(InnerColorIdx, :));
        
        %% Show the fixation
        %Display all the stimuli for the experiment
        
        %Display the fixation stimulus
        %Calculate the radius by using a sign wave of a given period
        %(oscillationperiod, standardized to radians) with an amplitude
        %corresponding to the size range
        Framecounter = 1;
        trialstart_actual = 0; % Preset to zero
        Fixation_Response = 0;
        
        
        %implement ITI
        ITIOns_actual = Screen('Flip',Window.onScreen);
        %Window.frameTime is equivalent to fliptime
        %(coming from Menu)
        
        %%
        % If the movie is the last then tell the
        % analysis code that you are finished
        % (hopefully)
        if (MovieCounter == length(PresentationOrder)) || (Quit == 1)
            Data.Timing.TestEnd = ITIOns_actual;
            
        end
        
        while (ITIOns_actual+currITI(MovieCounter)-Window.frameTime)>GetSecs && Quit==0 %where's ITIOns_actual & Starting_Delay?
            
            % fixation
            % Calculate the radius as a Sine wave
            Radius=round(sin((Framecounter/FramesPerOscillation)*(2*pi))*(range(Fixation_ScalingRange*Fixation_Size/4))+mean(Fixation_ScalingRange*Fixation_Size/2));
            
            % Set the background
            Screen(Window.onScreen,'FillRect',Window.bcolor);
            
            % Draw the fixation
            Fixation_Rect = [centerX-Radius, centerY-Radius, centerX+Radius, centerY+Radius];
            Screen('FillRect', Window.onScreen, Fixation_OuterColor, Fixation_Rect);
            
            Fixation_Rect = [centerX-(Radius*5/8), centerY-(Radius*5/8), centerX+(Radius*5/8), centerY+(Radius*5/8)];
            Screen('FillRect', Window.onScreen, uint8([255, 255, 255]), Fixation_Rect);
            
            Fixation_Rect = [centerX-(Radius*4/16), centerY-(Radius*4/16), centerX+(Radius*4/16), centerY+(Radius*4/16)];
            Screen('FillRect', Window.onScreen, Fixation_InnerColor, Fixation_Rect);
            
            %Do a normal flip
            Temp=Screen('Flip',Window.onScreen);
            
            %Check key presses
            [keyIsDown,keyCode_onset] = KbQueueCheck(Window.KeyboardNum);
            
            TRRecording=Utils_checkTrigger(Window.NextTR, Window.ScannerNum); %Returns the time if a TR pulse happened recent
            
            Framecounter = Framecounter + 1;
            
            Fixation_end = Temp;
            
            %If there is a recording then update the next
            %TR time and store %why update the TR for the
            %ITIs?
            %this pulse
            if any(TRRecording>0)
                Data.Timing.TR(end+1:end+length(TRRecording))=TRRecording;
                Window.NextTR=max(TRRecording)+Window.TR;
            end
            %If they have pressed q then quit
            if (keyIsDown) && sum(keyCode_onset>0)==1 && strcmp(KbName(keyCode_onset>0), 'q')
                Quit=1;
                %Data.TrialCounter=0; ???
                break;
            end
        end
    end
    
    % Break for loop if quit is received
    if Quit == 1
        break
    end
    
    
end


%
%                 Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('End_of_Block_Time:_%0.3f', GetSecs));
%
%                 fprintf('\n\n -----------------------End of Block-------------------------- \n\n');
%
%                 %How long must the console wait before the next sequence can run? Prep it
%                 %only if you waited for the TR at the start
%                 if VideoStruct.WaitforTR
%                     Data.Timing.DecayLapse=Conditions.Parameters.DecayLapse+GetSecs;
%                 else
%                     Data.Timing.DecayLapse=GetSecs;
%                 end

%end

%
%     %PresentationOrder = Conditions.Parameters.FinalStimuli;
%
%     %Put both the block names and stimuli directories in same place so they can
%     %be iterated through
%     %PresentationOrder(2,:) = Conditions.Parameters.BlockNames;
%
%     %which block was chosen?
%     ChosenVideo= PresentationOrder(1,ChosenBlock);
%
%     %If you aren't quiting then skip this
%     if Quit==0
%
%         %What is the name of the stim selected
%         ChosenStim={ChosenVideo{1}(4:end)};
%
%         fprintf('Playing movie: \n\n');
%
%         %Since you need the base extension for whatever reason here it is
%         %concatenate strings
%         Connected = strcat(Conditions.Parameters.BaseExt,ChosenStim);
%
%         %store here
%         VideoStruct.VideoNames=Connected;
%         VideoStruct.VideoNames=char(VideoStruct.VideoNames);
%
%
%         %Issue message
%
%         Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('Movie_Start_Time:_%0.3f', GetSecs));
%         if VideoStruct.WaitforTR == 1
%             Utils_EyeTracker_TrialStart(Window.EyeTracking);
%         end
%
%         VideoStruct.MovieWatched=0;
%
%
%         %Store the video name with the starting time
%         Data.MovieChoice{end+1}=ChosenStim;
%         Data.MovieStartTime(end+1)=GetSecs;
%
%         %What movie number is this?
%         MovieCounter=length(Data.MovieStartTime);
%
%         %Store the video struct information. Do so just before playing so
%         %that Window.NextTR is up to date
%         VideoStruct.window=Window;
%
%         [Data.Timing.(sprintf('Movie_%d', MovieCounter)), Data.Responses.(sprintf('Movie_%d', MovieCounter)), Data.GazeData.(sprintf('Movie_%d', MovieCounter))]=Utils_PlayAV(VideoStruct, [], TimingStruct, InputStruct); %Plays the movie
%
%
%         Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('Movie_Stop_Time:_%0.3f', GetSecs));
%         if VideoStruct.WaitforTR == 1
%             Utils_EyeTracker_TrialEnd(Window.EyeTracking);
%         end
%
%         %If the experimenter pressed q during the presentation then return
%         if (Data.Responses.(sprintf('Movie_%d', MovieCounter)).Quit == 1)
%             Quit=1;
%
%             %Record whether that this was quit preemptively
%             Data.Quit=1;
%             fprintf('\nBlock Terminated\n\n');
%
%         else
%             Quit=1;
%             fprintf('\nExiting experiment because movie has finished\n\n');
%
%             %Once the movie has finished quit but don't record it as a quit
%             Data.Quit=0;
%         end
%
%
%         %Append the TR values to the list that grows with every movie
%         if Window.isfMRI && ~isempty(Data.Timing.(sprintf('Movie_%d', MovieCounter)).TR)
%             Data.Timing.TR=[Data.Timing.TR, Data.Timing.(sprintf('Movie_%d', MovieCounter)).TR];
%             Window.NextTR=Data.Timing.TR(end);
%         end
%
%         fprintf('\n\nMovie end');
%     end
%
%

%end

% Pull out when the test began (need to do it after listening to the
% scanner but otherwise have no way of getting that information)
if isfield(Data.Timing, 'Movie_1')
    Data.Timing.TestStart = Data.Timing.Movie_1.movieStart.Local;
end

Window.EyeTracking = Utils_EyeTracker_Message(Window.EyeTracking, sprintf('End_of_Block_Time:_%0.3f', GetSecs));

fprintf('\n\n -----------------------End of Block-------------------------- \n\n');

%How long must the console wait before the next sequence can run? Prep it
%only if you waited for the TR at the start
if VideoStruct.WaitforTR
    Data.Timing.DecayLapse=Conditions.Parameters.DecayLapse+GetSecs;
else
    Data.Timing.DecayLapse=GetSecs;
end
