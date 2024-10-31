classdef Robot < handle
    %ROBOT Wrapper for convenient use of robotics toolbox
    %   Helper and convenience functions for robotics toolbox
    
    properties (Access=public)
        r
        qCurrent
        qTarget
        qTraj
        trTarget
        endEffectorOffset
    end
    
    methods
        function obj = Robot(r,endEffectorOffset,q)
            %ROBOT Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 3
                q = GenerateInitialQ(r);
            end
            if nargin < 2
                endEffectorOffset = transl(0,0,0);
            end

            obj.r = r;
            obj.qCurrent = q;
            obj.qTarget = q;
            obj.endEffectorOffset = endEffectorOffset;
            obj.trTarget = r.model.fkine(obj.qCurrent);
            r.model.animate(q);
        end

        function tr = Fkine(obj, q)
            %FKINE gets the transform of every joint 
            if nargin < 2
                q = obj.qCurrent;
            end
            
            baseTr = obj.r.model.base;
            L = obj.r.model.links;
            n = length(L);

            % initialise the 
            tr = zeros(4,4,n+1);

            % calculate all links using DH parameters
            tr(:,:,1) = baseTr;
            for i = 1 : n
                tr(:,:,i+1) = tr(:,:,i) * trotz(q(i)+L(i).offset) * transl(0,0,L(i).d) * transl(L(i).a,0,0) * trotx(L(i).alpha);
            end
        end 

        function Teach(obj, q)
            %TEACH animate specific q
            obj.qCurrent = q;
            obj.r.model.animate(obj.qCurrent);
        end

        function Jog(obj, input)
            %JOG Manually jog the robot
            % input [vx;vy;vz;wx;wy;wz]
            
            % simulation time step
            dt = 0.15;

            % turn joystick input into an end-effector velocity command
            Kv = 0.3; % linear velocity gain
            Kw = 0.8; % angular velocity gain
            
            vx = Kv*input(1);
            vy = Kv*input(2);
            vz = Kv*input(3);
            
            wx = Kw*input(4);
            wy = Kw*input(5);
            wz = Kw*input(6);
            
            dx = [vx;vy;vz;wx;wy;wz]; % combined velocity vector
            
            % use DLS J inverse to calculate joint velocity
            lambda = 0.5;
            J = obj.r.model.jacob0(obj.qCurrent);
            [~,n] = size(J);
            Jinv_dls = inv((J'*J)+lambda^2*eye(n))*J';
            dq = Jinv_dls*dx;
            
            % apply joint velocity to step robot joint angles 
            q = obj.qCurrent + dq'*dt;

            % animate the robot
            obj.Teach(q);
        end

        function SetTargetTr(obj,tr,qGuess,steps)
            %SETTARGET Set a end effector position target
            %   Accepts a global pose and generates a trajectory to reach
            %   that pose.
            if nargin < 3
                qGuess = obj.qCurrent;
            end
            if nargin < 4
                steps = 100;
            end

            if obj.trTarget == tr
                return
            end
            
            obj.trTarget = tr;
            trWithOffset = tr/obj.endEffectorOffset;
            % obj.qTarget = obj.r.model.ikine(tr, qGuess, 'mask', [1 1 1 0 0 0]);
            obj.qTarget = obj.r.model.ikcon(trWithOffset, qGuess);
            obj.qTraj = jtraj(obj.qCurrent, obj.qTarget, steps);
        end

        function SetTargetQ(obj,q,steps)
            %SETTARGET Set a joint position target
            if nargin < 3
                steps = 100;
            end
            
            if obj.qTarget == q
                return
            end

            obj.qTarget = q;
            obj.trTarget = obj.r.model.fkine(q);
            obj.qTraj = jtraj(obj.qCurrent, obj.qTarget, steps);
        end

        function StepArm(obj)
            obj.Teach(obj.qTraj(1,:));
            obj.qTraj(1,:) = [];
            drawnow;
        end

        function StepFingers(obj)
        end
        
        function status = Animate(obj,entity,rotation)
            %ANIMATE Move the robot arm end effector to a pose
            %   Detailed explanation goes here
            if nargin < 3
                rotation = 1;
            end
            if nargin < 2
                entity = "none";
                rotation = 1;
            end 

            status = false;

            if isempty(obj.qTraj)
                status = true;
                return
            end

            obj.StepArm();
            if entity ~= "none"
                trEntity = obj.r.model.fkine(obj.qCurrent).T * obj.endEffectorOffset * rotation;
                entity.Move(trEntity);
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