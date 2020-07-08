classdef musicalgesture < mgobject
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = musicalgesture(f, varargin)
            
            %obj.varargin_i = varargin;
            x = varargin;
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            %obj.Property1 = inputArg1 + inputArg2;
            
            obj=obj@mgobject(f);
            %obj=obj@mgmotion(f,varargin);
            %obj=obj@mghistory(f,varargin);
            %obj=obj@mgaverage(f,varargin);
            
            fileCount = length(obj.video);
            
            for argi = 1:nargin-1
                
                if (strcmpi(varargin{argi},'startTime'))
                    if(fileCount <= 1)
                        if(argi + 1 <= nargin-1 &&  isnumeric(varargin{argi + 1}))
                            disp('start time specified');
                            obj.startTime = varargin{argi+1};
                        end
                    else
                        cprintf('*Magenta', 'startTime cannot be defined when loading multiple files\n');
                    end
                    
                elseif (strcmpi(varargin{argi},'stopTime'))
                    if(fileCount <= 1)
                        if(argi + 1 <= nargin-1 &&  isnumeric(varargin{argi + 1}))
                            disp('stop time specified');
                            obj.stopTime = varargin{argi+1};
                        end
                    else
                        cprintf('*Magenta', 'stopTime cannot be defined when loading multiple files\n');
                    end
                elseif (strcmpi(varargin{argi},'Interval'))
                    if(argi + 1 <= nargin-1 &&  isnumeric(varargin{argi + 1}))
                        obj.frameInterval = varargin{argi+1};
                    end
                end
                
            end
            
            
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
            
        end
        
        function out = foo(self,arg1, arg2)
            out =  arg2 + arg1;
        end
        
        
        
        
    end
end

