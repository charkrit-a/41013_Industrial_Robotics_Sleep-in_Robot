% function A2
%%
    clf
    clc
    Init();
    hold on
    
    % define environment
    EnvironmentA2();
    
    % plot robots
    r1 = Robot(LinearUR10e(transl(-0.3,0,0)), transl(0,0,0.1)*troty(-pi/2));
    r2 = Robot(UR3e(transl(0.5,0.2,0)*trotz(pi/2), true, 'gripper_2fg7_base'), transl(0,0,0.08), [0 -pi/2 pi/2 -pi/2 -pi/2 0]);

    % place objects
    milk = Entity("Milk.ply", transl(-1.8,0.7,0.15));
    juice = Entity("OrangeJuice.ply", transl(-1.8,0.8,0.15));
    cerealGreen = Entity("CerealBox_Green.ply", transl(-0.78,0.85,1.1)*trotz(pi/2));
    cerealPurple = Entity("CerealBox_Blue.ply", transl(-1.25,0.85,1.1)*trotz(pi/2));
    cerealRed = Entity("CerealBox_Red.ply", transl(-1.35,0.85,1.1)*trotz(pi/2));
%%
    % start GUI
    app = SleepInRobot;

    % state
    state = 0;
    brekky = 0;

    try
        while(1)
            state = app.State;
            if app.ESTOPButton.Value
                state = 99;
            end
    
            switch state
                case 0 % startup actions
                    app.StatusLamp.Color = [0 0 0];
                case 1 % jogging
                    app.StatusLamp.Color = [0 0 1];
                case 2 % breakfast
                    app.StatusLamp.Color = [0 1 0];
    
                    % example of how to make the robots move
                    switch brekky
                        case 1
                            r1Done = r1.Animate(cerealGreen.GetPose());
                            r2Done = r2.Animate(transl(0,0,1));
                            if r1Done && r2Done
                                brekky = brekky+1;
                            end
                        case 2
                            r1Done = r1.Animate(cerealGreen.GetPose());
                            r2Done = r2.Animate(transl(0,0,1));
                            if r1Done && r2Done
                                brekky = brekky+1;
                            end
                    end
    
                case 99 % ESTOP
                    app.StatusLamp.Color = [1 0 0];
                    state = 0;
            end
    
            pause(0.02)
        end

    catch
        % cleanup
        delete(app)
    end
% end

function Cereal(box, r1, r2)
end

function Drink(drink, r1, r2)
end