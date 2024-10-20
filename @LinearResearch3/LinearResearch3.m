classdef LinearResearch3 < RobotBaseClass
    %% Research3 model on linear rails
    %
    % WARNING: This model has been created by UTS students in the subject
    % 41013. No guarentee is made about the accuracy or correctness of the
    % of the DH parameters of the accompanying ply files. Do not assume
    % that this matches the real robot!

    properties(Access = public)   
        plyFileNameStem = 'LinearResearch3';
    end
    
    methods
%% Constructor
        function self = LinearResearch3(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.model.base = self.model.base.T * trotx(pi/2) * troty(pi/2);
            self.useTool = true;
            self.toolFilename = 'Grippers.ply'; % gripper name
            self.PlotAndColourRobot();
        end


%% CreateModel
        function CreateModel(self)
    %% Define links
            L1 = Link([pi     0       0       pi/2    1]); % PRISMATIC Link
            L2 = Link('d', 0.21,  'a', 0,       'alpha', pi/2,    'qlim',deg2rad([-360 360]), 'offset', 0);
            L3 = Link('d', 0,     'a', 0,       'alpha',   -pi/2, 'qlim', [-2.7437 2.7437],   'offset', 0);
            L4 = Link('d', 0.190, 'a', 0,       'alpha', 0,   'qlim', [-1.7837 1.7837],   'offset', pi/4);
            L5 = Link('d', 0.316, 'a', 0.0,     'alpha',  -pi/2,  'qlim', [-2.9007 2.9007],   'offset', 0.088);
            L6 = Link('d',   0.0, 'a',  0.0825, 'alpha',  pi/2,   'qlim', [-3.0421 -0.1518],  'offset', 0.088);
            L7 = Link('d', 0.384, 'a', -0.0825, 'alpha', -pi/2,   'qlim', [-2.8065 2.8065],   'offset', -0.088);
            L8 = Link('d',   0.0, 'a', 0.0,     'alpha',  pi/2,   'qlim', [0.5445 4.5169],    'offset', 0);
            L9 = Link('d',   0.0, 'a', 0.088,   'alpha',  pi/2,   'qlim', [-3.0159 3.0159],   'offset', 0.088);
             
            self.model = SerialLink([L1 L2 L3 L4 L5 L6 L7 L8 L9],'name',self.name);
        end      
    end
end