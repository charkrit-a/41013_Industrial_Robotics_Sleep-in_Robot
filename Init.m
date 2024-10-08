function Init()
    % INIT include all required files and initialise the robotics toolbox
    
    % paths
    scriptDir = fileparts(mfilename('fullpath'));
    addpath(genpath(scriptDir));
    
    % prepare robotics toolbox
    startup_rvc
end