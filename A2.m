% function A2
%%
    clear
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
    milk = Entity("Milk.ply", transl(-1.8,0.7,0.15)*trotz(pi));
    juice = Entity("OrangeJuice.ply", transl(-1.8,0.8,0.15)*trotz(pi));
    cerealGreen = Entity("CerealBox_Green.ply", transl(-0.65,0.85,1.1)*trotz(pi/2));
    cerealPurple = Entity("CerealBox_Blue.ply", transl(-0.75,0.85,1.1)*trotz(pi/2));
    cerealRed = Entity("CerealBox_Red.ply", transl(-0.85,0.85,1.1)*trotz(pi/2));
    bowl = Entity("Bowl.ply", transl(0.5,-0.1,0));
%%
    % start GUI
    app = SleepinRobot(r1,r2);

    % state
    state = 0;
    brekky = 0;

    while(1)
        state = app.State;
        if app.ESTOPButton.Value
            state = 99;
        end

        switch state
            case 0 % landing
                app.StatusLamp.Color = [0 0 0];
            case 1 % jogging
                app.StatusLamp.Color = [0 0 1];
            case 2 % breakfast
                app.StatusLamp.Color = [0 1 0];
                % example of how to make the robots move
                switch brekky
                    case 0
                        if app.BreakfastApp.BreakfastGo
                            brekky = 1;
                            app.BreakfastApp.BreakfastGo = false;
                        end
                        if app.BreakfastApp.EnableBreakfastTimeSwitch.Value
                            % if 
                            %   brekky = 1;
                            % end
                        end
                    case 1 %UR10e moves to predetermined joint positions before picking up cereal box
                        r1.SetTargetQ([-0.45 0 1 -1 0 -1.5 pi/2])
                        r2.SetTargetTr(transl(0,0,1))
                        r1Done = r1.Animate();
                        r2Done = r2.Animate();
                        if r1Done && r2Done
                            brekky = brekky+1;
                        end
                    case 2 %Ur10e moves to Cereal Box
                        r1.SetTargetTr(cerealGreen.GetPose());
                        r1Done = r1.Animate();
                        if r1Done
                            brekky = brekky+1;
                        end
                    case 3 %UR10e moves to predetermined joint positions before placing cereal box on the table
                        r1.SetTargetQ([-0.8 3*pi/5 -pi/4 -pi/2 -pi/4 -2*pi/5 -pi/2]);
                        r1Done = r1.Animate(cerealGreen);
                        if r1Done
                            brekky = brekky+1;
                        end
                    case 4 %UR10e places cereal box on the table    
                        r1.SetTargetTr(transl(-0.1, 0, 0.07))
                        r1Done = r1.Animate(cerealGreen);
                        if r1Done
                            brekky = brekky+1;
                        end
                    case 5  %UR10e  and UR3 moves to predetermined joint positions before picking up cereal box   
                        r1.SetTargetQ([-0.5, pi/4, pi/4 pi/4 pi/2 pi/4 -pi/2]);
                        r2.SetTargetQ([-8*pi/16 -pi/4 pi/2 pi 0 0])
                        r1Done = r1.Animate();
                        r2Done = r2.Animate();
                        if r1Done && r2Done
                            brekky = brekky+1;
                        end
                    case 6 %UR10e moves to the milk carton and UR3 moves to cereal box
                        r1.SetTargetTr(milk.GetPose());
                        r2.SetTargetTr(transl(0.1, 0, 0.07)*troty(pi/2))
                        r1Done = r1.Animate();
                        r2Done = r2.Animate();
                        if r1Done && r2Done
                            brekky = brekky+1;
                        end
                    case 7 %Ur10e moves to place the milk carton on the table and UR3 moves cereal box to pour into the bowl
                        r1.SetTargetTr(transl(0.1, 0.1, 0.05))
                        r1Done = r1.Animate(milk);
                        if r1Done
                            brekky = 0; % last step should return to 0
                        end
                end

            case 99 % ESTOP
                app.StatusLamp.Color = [1 0 0];
                state = 0;
        end

        pause(0.02)
    end
% end

function Cereal(box, r1, r2)
end

function Drink(drink, r1, r2)
end