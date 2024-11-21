%% File: task1.erl
-module(task1).
-export([start/2, startN/3, producer/3, conveyor/1, truck/2, createPackage/1]).


startN(0, _, _) -> ok;

startN(N_SHIPMENTLINES, MAX_CAPACITY, MAX_PACKAGES) -> 
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    spawn(?MODULE, producer, [Counter, PidConveyor, MAX_PACKAGES]),
    startN(N_SHIPMENTLINES-1, MAX_CAPACITY, MAX_PACKAGES).


start(MAX_CAPACITY, MAX_PACKAGES) ->
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    spawn(?MODULE, producer, [Counter, PidConveyor, MAX_PACKAGES]).

conveyor(TruckPid) -> 
    receive
        {PackageId, PackageSize} ->
            io:format("Conveyor ~p - Received package with size ~p~n", [self(), PackageSize]),
            TruckPid ! {PackageId, PackageSize},
            conveyor(TruckPid);
        stop ->
            io:format("Conveyor ~p - Finished~n", [self()]),
            TruckPid ! stop,
            true
    end.

truck(Cap, MAX_CAPACITY) -> 
    receive
        {PackageId, PackageSize} ->
            io:format("Truck ~p - Received package ~p with size ~p~n",[self(), PackageId, PackageSize]),
            if 
                PackageSize + Cap > MAX_CAPACITY -> 
                    io:format("Truck ~p - Capacity exceeded. Emptying truck~n", [self()]),
                    NewCap = Cap+PackageSize-MAX_CAPACITY,
                    io:format("Truck ~p - Loaded package. Capacity:~p/~p~n", [self(), NewCap, MAX_CAPACITY]),
                    truck(NewCap, MAX_CAPACITY);
                true -> 
                    io:format("Truck ~p - Loaded package. Capacity:~p/~p~n", [self(), Cap+PackageSize, MAX_CAPACITY]), 
                    truck(Cap + PackageSize, MAX_CAPACITY)
            end;
        stop ->
            io:format("Truck ~p - Finished~n", [self()]),
            true
    end.



producer(C, ConveyorPid, C) -> 
    io:format("Producer ~p - Reached max packages produced ~p and Finished~n", [self(), C]),
    ConveyorPid ! stop;


producer(Counter, ConveyorPid, MAX_PACKAGES) -> 
    {PackageId, PackageSize} = createPackage(Counter),
    io:format("Producer ~p - New package with size ~p~n", [self(), PackageSize]),
    ConveyorPid ! {PackageId, PackageSize},
    timer:sleep(500),
    producer(Counter+1, ConveyorPid, MAX_PACKAGES).

createPackage(Counter) -> {Counter, 1}.