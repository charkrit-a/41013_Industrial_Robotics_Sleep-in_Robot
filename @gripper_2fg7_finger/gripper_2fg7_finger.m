classdef gripper_2fg7_finger < RobotBaseClass
    %% GRIPPER_2FG7 OnRobot 2fg7 gripper for UR3e robot arm

    properties(Access = public)              
        plyFileNameStem = 'gripper_2fg7_finger';
    end
    
    methods
        %% Define robot Function 
        function obj = gripper_2fg7_finger(baseTr)
            if nargin < 1			
				baseTr = transl(0,0,0);				
            end

            obj.CreateModel();

            obj.model.base =  obj.model.base.T * baseTr;
            obj.PlotAndColourRobot();
        end
        
        %% Create the robot model
        function CreateModel(obj)
            link(1) = Link('theta', 0, 'a', 0, 'alpha', 0, 'prismatic', 'qlim', [-0.025, 0]);

            obj.model = SerialLink(link,'name',obj.name);
            obj.model.plotopt = {'noshadow','noarrow','noshading','nowrist','nojaxes'};
        end
    end
end
