
%% Generate Trial sequence and conditions for the memory Experiment

%Adapted from "Generate Trial sequence and conditions for a Live Action
%Movie Experiment"

% Generate the appropriate trial sequence with randomization for Daniel
% Tiger Children Playing movies
%
% Practically the same script as GenerateTrials_MM.m
% Except the block order is completely forced 
%
% SC 03/15/21
%

function TrialStructure=GenerateTrials_Saycam(varargin)




Parameters.BaseExt=cd; %What is the current folder directory name
Parameters.BaseExt=Parameters.BaseExt(1:max(find(Parameters.BaseExt=='/'))); %Remove the current folder

LTsquarefile=fullfile(Parameters.BaseExt,'/Scripts/Saycam/LTsquare_rand_saycam.mat');
load(LTsquarefile);

trialstructfile=fullfile(Parameters.BaseExt,'/Data/Saycam/Saycam_trialstructure.mat');


if exist(trialstructfile, 'file')==2
   load(trialstructfile);
   fprintf('\n\n-----------------------Loading trialstruct--------------------------\n\n');

elseif exist(trialstructfile, 'file')==0


   fprintf('\n\n-----------------------Generating a new trialstruct--------------------------\n\n');

% In case no inputs are given
if nargin > 0
    Window = varargin{4};
else
    Window.ppd = 30;
    Window.centerX = 500;
    Window.centerY = 500;
end

%Set up the parameters of the experiment

Parameters.BaseExt=cd; %What is the current folder directory name
Parameters.BaseExt=Parameters.BaseExt(1:max(find(Parameters.BaseExt=='/'))); %Remove the current folder

Parameters.StimulusDirectory=fullfile(Parameters.BaseExt, '/Stimuli/Saycam/'); %Where are the video stimuli stored?

Parameters.Preload=0; %Would you like to preload the textures before playing the movie?
 
Parameters.DecayLapse=0; %How many seconds will you wait for

tmp=dir(fullfile(Parameters.StimulusDirectory,'A_PC'));
tmp=tmp(arrayfun(@(x) ~strcmp(x.name(1),'.'),tmp));

Parameters.numpseudoblocks=length(tmp); %how many files are in one of the stimuli folders?

%Specify the 4 values that define the rectangle of the movie. If the values
%are above zero then they will be treated as pixels, if below zero then it
%will be treated as proportion of the screen
%Parameters.Rect= [0.2, 0.2, 0.8, 0.8];

% When we originally ran these movies at Princeton we made them 20% of the screen size, which comes out to 22.75 x 12.75 visual degrees. For preservation, the visual angle has been preserved for these analyses. 
%If a movie is not 16:9 then it will be stretched or compressed
%For these movies, the resolution is 1280:800 (instead of 1280:720)
%So we will edit the width to be the appropriate size given the height 
ppd_width=12.75 * 4/3 *2;%12.75*2  
ppd_height=12.75*2;
x_width = ppd_width/2 * Window.ppd;
y_width = ppd_height/2 * Window.ppd;
Parameters.Rect=[Window.centerX - x_width, Window.centerY - y_width, Window.centerX + x_width, Window.centerY + y_width];

clear tmp

%% old load video
%Set up the stimuli for the experiment
% 
% Temp=[dir([Parameters.StimulusDirectory, '*.MOV']);dir([Parameters.StimulusDirectory, '*.mp4'])]; 
%  %What files are in the video directory. Both mp4 and MOV files 
% 
% 
% DirNames=Temp(arrayfun(@(x) ~strcmp(x.name(1),'.'),Temp)); %Remove all hidden files
% 
% for FileCounter=1:length(DirNames)
%     
%     %Store the movie names
%     Stimuli.MovieNames{FileCounter}=[Parameters.StimulusDirectory, DirNames(FileCounter).name]; 
%    
%     
% end


%% create stimuli structure
stim_dir =Parameters.StimulusDirectory;
video_ext = 'mp4'; 

fullcondtype = {'A_PC', 'A_Real', 'A_RV','Y_PC','Y_Real','Y_RV'}; 

 N=length(fullcondtype);
% x=mod(Parameters.numpseudoblocks,length(fullcondtype));
% Orders=Shuffle([repmat([1:length(fullcondtype)],(Parameters.numpseudoblocks-x)/N),(1:x)]);
% 
% M = [1:N ; ones(N-1,N)] ;
% M = rem(cumsum(M)-1,N)+1 ;
% 
% 
% for i=1:length(Orders)
% TrialSequences(:,i)=M(:,Orders(i));
% end

TrialSequences=M; %M, with the order sequence is loaded at the beginning
% 
% ITIrange=[6,8,10];
% ITIpercentages=[0.5, 0.3, 0.2];
% 
% ss=Parameters.numpseudoblocks*N;
% tot=round(ss*ITIpercentages);
% 
% fullmat=[];
% for i=1:length(ITIrange);
%     tmpmat=repmat(ITIrange(i),tot(i),1);
%     fullmat=[fullmat;tmpmat];
% end
% 
% ITIdist=Shuffle(fullmat);
% 
% %ITIdist=round(Shuffle(linspace(ITIrange(1),ITIrange(2),Parameters.numpseudoblocks*N)),1);
% ITIs=reshape(ITIdist,Parameters.numpseudoblocks,N);


ITIcat=[6, 8, 10, 6, 8, 6];
ITIs=[];
for e=1:Parameters.numpseudoblocks;
    tmpi=Shuffle(ITIcat);
    ITIs=[ITIs;tmpi];
end

for pseudoblock=1:Parameters.numpseudoblocks;
    curr_rc=TrialSequences(:,pseudoblock);
    Stimuli.(sprintf('set_%s',num2str(pseudoblock)))=cell(6,1);
   % ITIs(pseudoblock,:) = round(shuffle(linspace(ITIrange(1),ITIrange(2),6)),2); %ITIs

    for i=1:length(fullcondtype);
        condtype=fullcondtype{i};
        
        tmpdir = fullfile(stim_dir, condtype);
        tmpfull=dir([tmpdir, '/*.mp4']);
        tmpfull=tmpfull(arrayfun(@(x) ~strcmp(x.name(1),'.'),tmpfull));
        %tmpfull=shuffle(tmpfull); %method 2: shuffle the videos in directories so that a random one is selected on the next look.Select blocks in order during presentation
        tmp=tmpfull(pseudoblock); %method 1: pick the first one in each row; thus, to randomize, select different block numbers during presentation (e.g. block 1-20)
        
        video_name=tmp(arrayfun(@(x) ~strcmp(x.name(1),'.'),tmp));
        x=[tmpdir,'/',video_name.name];
        
        Stimuli.(sprintf('set_%s',num2str(pseudoblock))){curr_rc(i)} = x;
        Stimulitype{curr_rc(i),pseudoblock}=condtype;
        Stimulitype_vidname{curr_rc(i),pseudoblock}=video_name.name; %col is pseudoblock

    end
end


if Parameters.numpseudoblocks ==20; 
    %Reorder the stimuli set order. Will only work of there are full set of
    %stimuli

    t=(reshape([1:20],[5,4]))';

    for i=1:size(t,1);
        t(:,i)=Shuffle(t(:,i));
    end
    orders=reshape(t,[20,1]);

    for i=1:20;
        ordernames{i}=sprintf('set_%d', orders(i));
    end

    Stimuli=orderfields(Stimuli, ordernames);
end


%% old way where each file was in each folder

% for pseudoblock=1:Parameters.numpseudoblocks;
%     curr_rc=TrialSequences(:,pseudoblock);
%     Stimuli.(sprintf('block%s',num2str(pseudoblock)))=cell(6,1);
%     ITIs(pseudoblock,:) = round(shuffle(linspace(ITIrange(1),ITIrange(2),6)),2); %ITIs
% 
%     for i=1:length(fullcondtype);
%         condtype=fullcondtype{i};
%         
%         tmpdir = fullfile(stim_dir, condtype,num2str(pseudoblock));
%         tmp=dir([tmpdir, '/*.mp4']);
%         video_name=tmp(arrayfun(@(x) ~strcmp(x.name(1),'.'),tmp));
%         x=[video_name.folder,'/',video_name.name];
%         
%         Stimuli.(sprintf('block%s',num2str(pseudoblock))){curr_rc(i)} = x;
%         Stimulitype{curr_rc(i),pseudoblock}=condtype;
%         Stimulitype_vidname{curr_rc(i),pseudoblock}=video_name.name; %col is pseudoblock
% 
%     end
% end

%%
%i think this is the 'block'?
Parameters.FinalStimuli = Stimuli;
Parameters.Stimulitype_cell=Stimulitype;
Parameters.Stimulitype_vidname=Stimulitype_vidname;
Parameters.TrialSequences =TrialSequences;
Parameters.ITIs=ITIs;
Parameters.orders=orders;

% Iterate through the blocks and store them based on their name
Parameters.BlockNames = {};
for BlockCounter =1:Parameters.numpseudoblocks;
    Parameters.BlockNames{BlockCounter}= sprintf('set_%d', orders(BlockCounter));%['set_',num2str(BlockCounter)];%[num2str(BlockCounter)]
end
 
Parameters.BlockNum=length(Parameters.BlockNames); % How many blocks are there

%Store these
TrialStructure.Parameters=Parameters;
TrialStructure.Stimuli=Stimuli;

%LTsquarefile=fullfile(Parameters.BaseExt,'/Scripts/Saycam/LTsquare_rand_saycam.mat');

savedir=fullfile(Parameters.BaseExt,'/Data/Saycam');
    if ~exist(savedir, 'dir')
       mkdir(savedir)
    end

savename=fullfile(savedir, 'Saycam_trialstructure.mat')
save(savename, 'TrialStructure')
end
