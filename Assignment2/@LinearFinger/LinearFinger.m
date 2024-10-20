classdef LinearFinger < RobotBaseClass


    properties(Access = public)              
        plyFileNameStem = 'LinearFinger';
    end
    
    methods
%% Define robot Function 
function self = LinearFinger(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = transl(0,0,0);				
            end
            self.model.base =  self.model.base.T * baseTr  ;
            
            self.PlotAndColourRobot();         
        end

%% Create the robot model
        function CreateModel(self)   
            link(1) = Link('d',0,'a',0.047,'alpha',0,'qlim',deg2rad([-10 25]),'offset',deg2rad(30));   
            link(2) = Link('d',0,'a',0.04,'alpha',0,'qlim',deg2rad([0 0.01]),'offset',deg2rad(30));
            self.model = SerialLink(link,'name',self.name);
            self.model.plotopt = {'noshadow','noarrow','noshading','nowrist','nojaxes'};
        end
     
    end
end