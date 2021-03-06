function mgOut = mgmotionhistory(f, varargin)
%function mgmotionhistory(vidfile,nframe,type,varargin)
% mgmotionhistory(vidfile,nframe,type,starttime,endtime)
% compute the motion history image.
%
% syntax:
% mgmotionhistory(vidfile) using defualt nframe = 5 to create grayscale motion
% history image
% mgmotionhistory(vidfile,nframe) using nframe to create grayscale motion
% image
% mgmotionhistory(vidfile,nframe,type,starttime,endtime)
%
% input:
% vidfile: video file name
% nframe: gives the number of frames to create motion history (default=20)
% type: 'gray' or 'color' (default='gray')
% starttime: starting time of the video to create motion history image
% endtime: end time of the video to create motion history image
%
% output: a history video written back to disk
%
% examples:
% mgmotionhistory(videofile,3,'gray',0,20)
% mgmotionhistory(videofile)
% mgmotionhistory(videofile,10,'color')



cmd = [];
cmd.nFrame = 20; %default fame number = 20;
cmd.color = 'off';
cmd.frameInterval = 1;
cmd.fileCount = 0;




if(ischar(f))
    disp('input is file or folder');
    if exist(f, 'dir')
        disp('folder exists');
        cmd.inputType = 'folder';
        
        files = dir(f);
        fileCount = size(files);
        
        fileCount = size(files);   
        fileCount = fileCount(1);
        %disp(fileCount);
        validFileCount = 0;
        for fileIndex= 1:fileCount
            if(files(fileIndex).isdir == 0)
                %disp(files(i).name);

                [~, ~, extension_i] = fileparts(files(fileIndex).name);
                extension_i = lower(extension_i);
                if((extension_i == ".avi")||(extension_i == ".mp4")||(extension_i == ".m4v") ||(extension_i == ".mpg") ||(extension_i == ".mov")    )
                    validFileCount = validFileCount + 1;
                    cmd.fileList{validFileCount} = files(fileIndex);
                    cmd.mg{validFileCount} = mgvideoreader([files(fileIndex).folder,'\',files(fileIndex).name]);
                    %disp[files(i).folder,files(i).name];
                    cmd.fileCount = cmd.fileCount + 1;
                end
            end
        end
        
        disp({'file count is ', cmd.fileCount});
        
        

    else
        disp('folder does not exist. probably the input is file');
        [~, ~, extension_i] = fileparts(f);
        extension_i = lower(extension_i);
        
        if exist(f, 'file')
            disp('file exists. checking file format')
            if((extension_i == ".avi")||(extension_i == ".mp4")||(extension_i == ".m4v") ||(extension_i == ".mpg") ||(extension_i == ".mov")    )
                disp('valid file format');
                cmd.fileCount = 1;
                cmd.inputType = 'file';
                cmd.mg = mgvideoreader(f);
                cmd.starttime = cmd.mg.video.starttime;
                cmd.endtime = cmd.mg.video.endtime;

            else
                disp('invalid file format');
        end
        else
            disp('file not found');
        end
    end
elseif isstruct(f) && isfield(f,'video')
    disp('input is mg struct');
    cmd.fileCount = 1;
    cmd.inputType = 'struct';
    cmd.mg = f;
    cmd.starttime = cmd.mg.video.starttime;
    cmd.endtime = cmd.mg.video.endtime;
    
else
    error('invalid input ');
end



l = length(varargin);;
for argi = 1:l
    
    if(strcmpi(cmd.inputType, 'folder') == 0)    
        if(argi == 1)
            if(argi <= l && isnumeric(varargin{argi }))
                disp('starttime specified in argument');
                cmd.starttime = varargin{argi+1};
                if(argi + 1 <= l &&isnumeric(varargin{argi + 1})) 
                    disp('stoptime specified in argument');
                    cmd.endtime = varargin{argi+2};
                end
            end
        end
    end
    
    if( ischar(varargin{argi}))   
            
        if (strcmpi(varargin{argi},'nFrame'))
            disp('nframe specified');
            cmd.nFrame = varargin{argi+1};
        elseif (strcmpi(varargin{argi},'Color'))
            disp('color mode on is specified in argument');
            cmd.color = 'on'
        elseif (strcmpi(varargin{argi},'Gray'))
            disp('color mode on is specified in argument');
            cmd.color = 'off'      
        elseif (strcmpi(varargin{argi},'Interval'))
            if(argi + 1 <= l &&  isnumeric(varargin{argi + 1}))
                cmd.frameInterval = varargin{argi+1};
            end
        end
    end
end




for fileIndex = 1:cmd.fileCount
    
    if(cmd.fileCount == 1)
        mg = cmd.mg;
    else
        mg = cmd.mg{fileIndex};
        cmd.starttime = cmd.mg{fileIndex}.video.starttime;
        cmd.endtime = cmd.mg{fileIndex}.video.endtime;
    end
    


    starttime = cmd.starttime;
    endtime = cmd.endtime;
    colorMode = cmd.color;
    frameInterval = cmd.frameInterval;
    nf = cmd.nFrame;

    mg.video.obj.CurrentTime = starttime;
    %[~,pr,ex] = mg.video.obj.Name;
    [~,pr,ex] = fileparts(mg.video.obj.Name);
    newfile = strcat(pr,'_history.avi');
    v = VideoWriter(newfile);
    v.FrameRate = mg.video.obj.FrameRate;
    open(v);

    if(strcmpi(cmd.color, 'on'))
        mg.video.obj.CurrentTime = starttime;
        temparray = zeros(mg.video.obj.Height,mg.video.obj.Width,3,nf-1,'uint8');
        %fr1 = readFrame(mg.video.obj);
        fr2 = readFrame(mg.video.obj);
        %diff = imsubtract(fr2,fr1);
        %temparray(:,:,:,1) = diff;
        %history = diff;
        %writeVideo(v,imadd(diff,fr2));

        disp('*****creating motion history video*****')
        numfr = mg.video.obj.FrameRate*(endtime-starttime)-nf;
        %while mg.video.obj.CurrentTime < endtime
        progmeter(0);
        for indf = nf:frameInterval:numfr
            progmeter(indf,numfr)
            temparray = temparray(:,:,:,[2:end 1]);
            nextf = readFrame(mg.video.obj);
            temp = imsubtract(nextf,fr2);
            fr2 = nextf;
            temparray(:,:,:,end) = temp;
            history = uint8(sum(temparray,4));
            writeVideo(v,imadd(history,nextf));
            mg.video.obj.CurrentTime = (1/mg.video.obj.FrameRate)*indf;
        end

    elseif(strcmpi(cmd.color, 'off'))
        mg.video.obj.CurrentTime = starttime;
        temparray = zeros(mg.video.obj.Height,mg.video.obj.Width,nf-1,'uint8');
        %fr1 = rgb2gray(readFrame(mg.video.obj));
        fr2 = rgb2gray(readFrame(mg.video.obj));
        %diff = imsubtract(fr2,fr1);
        %temparray(:,:,1) = diff;
        %history = diff;
        %writeVideo(v,imadd(diff,fr2));
        disp('*****creating motion history video*****')
        indf = nf;
        numfr = mg.video.obj.FrameRate*(endtime-starttime)-nf;
        %while mg.video.obj.CurrentTime < endtime
         progmeter(0);
        for indf = nf:frameInterval:numfr
            progmeter(indf,numfr);
            temparray = temparray(:,:,[2:end 1]);
            nextf = rgb2gray(readFrame(mg.video.obj));
            temp = imsubtract(nextf,fr2);
            fr2 = nextf;
            temparray(:,:,end) = temp;
            history = uint8(sum(temparray,3));
            writeVideo(v,imadd(history,nextf));

            mg.video.obj.CurrentTime = (1/mg.video.obj.FrameRate)*indf;

        end
    end



    disp(' ')
    disp(['The motion history video is created with name ',newfile]);
    
    
    close(v)
    
    disp(newfile);
    if(cmd.fileCount == 1)
        mgOut = mgvideoreader(newfile);
    else
        mgOut{fileIndex} = mgvideoreader(newfile);
    end
    
    
    
    
end



return;


