classdef Entity < handle
    %ENTITY Class to represent moveable objects
    %   Plots ply model, track and move its position
    
    properties (Access=private)
        pose;
        mesh_h;
        vertCount;
        verts;
    end
    
    methods
        function obj = Entity(modelFile, tr)
            %ENTITY Construct an instance of this class
            %   Construct class and draw entity in plot
            if nargin < 2
                tr = eye(4);
            end
            
            obj.pose = tr;

            [f,v,data] = plyread(modelFile, 'tri');
            obj.vertCount = size(v,1);
            vertsHomogeneous = [v, ones(obj.vertCount, 1)];
            vertsTransformed = (tr * vertsHomogeneous')';
            
            % save the original vertices to move the object later
            obj.verts = vertsHomogeneous;

            % Scale the colours to be 0-to-1 (they are originally 0-to-255)   
            try
                vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            catch
                try
                    vertexColours = [data.face.red, data.face.green, data.face.blue] / 255;        
                catch
                    vertexColours = [0.5,0.5,0.5];
                end
            end

            obj.mesh_h = trisurf(f, ...
            vertsTransformed(:, 1), vertsTransformed(:, 2), vertsTransformed(:, 3), ...
            'FaceVertexCData',vertexColours,'EdgeColor','none','EdgeLighting','none');
        end
        
        function tr = GetPose(obj)
            %GETPOS Getter function for the position of the brick
            tr = obj.pose;
        end

        function Move(obj, newPose)
            %MOVE move the brick to a new pose
            %   By multiplying all vertices by the new global pose
            % Store the new pose
            obj.pose = newPose;
            
            % Apply the new pose to the original vertices
            vertsTransformed = (newPose * obj.verts')';
            
            % Update the vertex positions in the plot
            set(obj.mesh_h, 'Vertices', vertsTransformed(:, 1:3));
        end
    end
end

