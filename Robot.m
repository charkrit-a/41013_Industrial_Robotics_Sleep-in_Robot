classdef Robot < handle
    %ROBOT Wrapper for convenient use of robotics toolbox
    %   Helper and convenience functions for robotics toolbox
    
    properties (Access=private)
        r
        qCurrent
        qTarget
        qTraj
        trTarget
        endEffectorOffset
    end
    
    methods
        function obj = Robot(r,q,endEffectorOffset)
            %ROBOT Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 3
                endEffectorOffset = transl(0,0,0);
            end
            if nargin < 2
                q = GenerateInitialQ(r);
            end

            obj.r = r;
            obj.qCurrent = q;
            obj.endEffectorOffset = endEffectorOffset;
            obj.trTarget = r.model.fkine(obj.qCurrent);
            r.model.animate(q);
        end

        function SetTarget(obj,tr,steps)
            %SETTARGET Set a end effector position target
            %   Accepts a global pose and generates a trajectory to reach
            %   that pose.
            if nargin < 3
                steps = 100;
            end
            
            obj.trTarget = tr;
            % obj.qTarget = obj.r.model.ikine(tr, obj.qCurrent, 'mask', [1 1 1 0 0 0]);
            obj.qTarget = obj.r.model.ikcon(tr, obj.qCurrent);
            obj.qTraj = jtraj(obj.qCurrent,obj.qTarget,steps);
        end

        function StepArm(obj)
            obj.qCurrent = obj.qTraj(1,:);
            obj.r.model.animate(obj.qTraj(1,:));
            obj.qTraj(1,:) = [];
            drawnow;
        end

        function StepFingers(obj)
        end
        
        function status = Animate(obj,tr,entity)
            %ANIMATE Move the robot arm end effector to a pose
            %   Detailed explanation goes here
            if nargin < 2
                tr = obj.trTarget;
            end
            if nargin < 3
                entity = "none";
            end 

            status = false;

            if any(obj.trTarget ~= tr, 'all')
                obj.SetTarget(tr);
                return
            end

            if isempty(obj.qTraj)
                status = true;
                return
            end

            obj.StepArm();
            if entity ~= "none"
                entity.Move(obj.r.model.fkine(obj.qCurrent).T);
            end 
        end

    end
end

function q = GenerateInitialQ(robot)
    %GENERATEINITIALQ Generate joint states for 
    % Initialize the joint configuration vector
    numJoints = numel(robot.model.links);  % Number of joints in the robot
    q = zeros(1, numJoints);  % Preallocate the joint angle vector

    % Loop over each joint to set its initial configuration
    for i = 1:numJoints
        % Get the joint limits for this link
        qlim = robot.model.links(i).qlim;

        % If joint limits are defined, set the joint value in the middle of the range
        if ~isempty(qlim)
            q(i) = mean(qlim);  % Set the joint angle to the middle of the joint limits
        else
            q(i) = 0;  % Default value if no limits are set
        end
    end
end