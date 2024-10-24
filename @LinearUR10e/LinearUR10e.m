classdef LinearUR10e < RobotBaseClass
    %% LinearUR10e, UR10e on a non-standard linear rail from UR5 robot

    properties(Access = public)              
        plyFileNameStem = 'LinearUR10e';
    end
    
    methods
%% Define robot Function 
        function self = LinearUR10e(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.model.base = self.model.base.T * baseTr * trotx(pi/2) * troty(pi/2);
            self.useTool = true;
            self.toolFilename = 'Gripper.ply'; % gripper name
            self.PlotAndColourRobot();
        end

%% Create the robot model
        function CreateModel(self)   
            % Create the UR10e model mounted on a linear rail
            link(1) = Link([pi     0       0       pi/2    1]); % PRISMATIC Link
            link(2) = Link('d',	0.1807,'a',       0,'alpha', pi/2,'qlim', deg2rad([-360 360]), 'offset', 0);
            link(3) = Link('d', 0     ,'a',-0.6127,'alpha',     0,'qlim', deg2rad([-360 360]), 'offset', 0);
            link(4) = Link('d', 0     ,'a',-0.57155,'alpha',    0,'qlim', deg2rad([-360 360]), 'offset', 0);
            link(5) = Link('d',0.17415,'a',       0,'alpha', pi/2,'qlim', deg2rad([-360 360]), 'offset', 0);
            link(6) = Link('d',0.11985,'a',       0,'alpha',-pi/2,'qlim', deg2rad([-360,360]), 'offset', 0);
            link(7) = Link('d',0.11655,'a',       0,'alpha',    0,'qlim', deg2rad([-360,360]), 'offset', 0);
            
            % Incorporate the joint limits of the UR10e inluding the rails
            link(1).qlim = [-0.8 -0.01];
            link(2).qlim = [-360 360]*pi/180;
            link(3).qlim = [-90 90]*pi/180;
            link(4).qlim = [-170 170]*pi/180;
            link(5).qlim = [-360 360]*pi/180;
            link(6).qlim = [-360 360]*pi/180;
            link(7).qlim = [-360 360]*pi/180;

            %Offsets for links 3 and 5
            link(3).offset = -pi/2;
            link(5).offset = -pi/2;
            
            self.model = SerialLink(link,'name',self.name);
        end
     
    end
end