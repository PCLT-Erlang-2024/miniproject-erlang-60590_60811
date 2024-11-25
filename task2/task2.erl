-module(task2).
-export([start/0, start/3]).

% Public function w/Default values
start() -> start(5, 10, 5).

% Public function w/Customizable values
start(NumShipmentLines, TruckCapacity, MaxPackages) ->
    if
        0 >= NumShipmentLines -> io:format("Number of shipment lines is non-positive~n");
        0 >= TruckCapacity -> io:format("Truck capacity is non-positive~n");
        0 >= MaxPackages -> io:format("Max packages is non-positive~n");
        true ->
            setupModules(),
            start(0, NumShipmentLines, TruckCapacity, MaxPackages)
    end.

% Private functions
start(NumShipmentLines, NumShipmentLines, _, _) -> ok;

start(Count, NumShipmentLines, TruckCapacity, MaxPackages) -> 
    setupProcesses(Count, TruckCapacity, MaxPackages),
    start(Count+1, NumShipmentLines, TruckCapacity, MaxPackages).

setupModules() ->
    c:c(producer),
    c:c(conveyor),
    c:c(truck).

setupProcesses(Count, TruckCapacity, MaxPackages) ->
    PidTruck = spawn(truck, truck, [Count, TruckCapacity]),
    PidConveyor = spawn(conveyor, conveyor, [Count, PidTruck]),
    spawn(producer, producer, [Count, PidConveyor, TruckCapacity, MaxPackages]).