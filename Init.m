function Init()
    % INIT include all required files and initialise the robotics toolbox
    
    % paths
    scriptDir = fileparts(mfilename('fullpath'));
    addpath(genpath(scriptDir));
    
    % prepare robotics toolbox
    if exist('SerialLink','class') ~= 8
        startup_rvc
    end
end