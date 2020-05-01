% Create vectors
names = ["SpeedLimit 20";"SpeedLimit 30";"SpeedLimit 50";"SpeedLimit 60";"SpeedLimit 70";"SpeedLimit 80";"SpeedLimitEnd 80";"SpeedLimit 100";"SpeedLimit 120";"NoOvertaking";"NoOvertakingTrucks";"RightOfWay";"PriorityRoad";"GiveWay";"Stop";"NoTraffic";"NoEntry";"Caution";"CurveL";"CurveR";"SCurveL";"SlipperyRoad";"NarrowRoadR";"RoadWorks";"TrafficLight";"Pedestrians";"Children";"CyclistsCrossingR";"EndOfLimitations";"TurnAheadR";"TurnAheadL";"StraightOrRight";"StraightOrLeft";"PassR";"PassL";"Roundabout";"NoOvertakingEnd";"NoOvertakingTrucksEnd"];
leftRight = ["L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"L";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R";"R"];
% Shuffle them
namesShuffle = names(randperm(length(names)));
leftRightShuffle = leftRight(randperm(length(leftRight)));
% Add together
result = [namesShuffle, leftRightShuffle];