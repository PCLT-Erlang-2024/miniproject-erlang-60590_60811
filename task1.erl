%% File: task1.erl
-module(task1).
-export([start/1, startN/2, producer/2, conveyor/1, truck/2, createPackage/1]).


startN(0, _) -> ok;

startN(N_PRODUCERS, MAX_CAPACITY) -> 
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    spawn(?MODULE, producer, [Counter, PidConveyor]),
    startN(N_PRODUCERS-1, MAX_CAPACITY).


start(MAX_CAPACITY) ->
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    spawn(?MODULE, producer, [Counter, PidConveyor]).
    %%PidTruck ! stop,
    %%PidConveyor ! stop.

conveyor(TruckPid) -> 
    receive
        {{PackageId, PackageSize}} ->
            %%From ! {Ref, Package},
            io:format("Conveyor ~p - Received package with size ~p~n", [self(), PackageSize]),
            TruckPid ! {{PackageId, PackageSize}},
            conveyor(TruckPid);
        stop ->
            true
    end.

truck(Cap, MAX_CAPACITY) -> 
    receive
        {{PackageId, PackageSize}} ->
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
            true
    end.

producer(Counter, ConveyorPid) -> 
    %%Ref = make_ref(),
    {PackageId, PackageSize} = createPackage(Counter),
    %%Package = createPackage(),
    io:format("Producer ~p - New package with size ~p~n", [self(), PackageSize]),
    ConveyorPid ! {{PackageId, PackageSize}},
    timer:sleep(1000),
    producer(Counter+1, ConveyorPid).
    %%receive
    %%    {Ref, Answer} ->
    %%        io:format("~p~n",[Answer])
    %%end,
    %%ConveyorPid ! stop,
    %%TruckPid ! stop.

createPackage(Counter) -> {Counter, 1}.