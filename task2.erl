%% File: task2.erl
-module(task2).
-export([start/1, startN/2, producer/3, conveyor/1, truck/2, createPackage/2, random_between/2]).


startN(0, _) -> ok;

startN(N_PRODUCERS, MAX_CAPACITY) -> 
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    spawn(?MODULE, producer, [Counter, PidConveyor, MAX_CAPACITY]),
    startN(N_PRODUCERS-1, MAX_CAPACITY).


start(MAX_CAPACITY) ->
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    spawn(?MODULE, producer, [Counter, PidConveyor, MAX_CAPACITY]).
    %%PidTruck ! stop,
    %%PidConveyor ! stop.

conveyor(TruckPid) -> 
    receive
        {Package} ->
            %%From ! {Ref, Package},
            TruckPid ! {Package},
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
                    io:format("Truck ~p - Capacity exceeded. Emptying truck~n", [self()]), truck(0, MAX_CAPACITY),
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

producer(Counter, ConveyorPid, MAX_CAPACITY) -> 
    %%Ref = make_ref(),
    {PackageId, PackageSize} = createPackage(Counter, MAX_CAPACITY),
    %%Package = createPackage(),
    io:format("Producer ~p - New package with size ~p~n", [self(), PackageSize]),
    ConveyorPid ! {{PackageId, PackageSize}},
    timer:sleep(1000),
    producer(Counter+1, ConveyorPid, MAX_CAPACITY).
    %%receive
    %%    {Ref, Answer} ->
    %%        io:format("~p~n",[Answer])
    %%end,
    %%ConveyorPid ! stop,
    %%TruckPid ! stop.

createPackage(Counter, MAX_CAPACITY) -> {Counter, random_between(0, MAX_CAPACITY)}.

random_between(Min, Max) when Min =< Max ->
    _ = rand:seed(exsplus, {os:system_time(millisecond), erlang:phash2(self()), erlang:monotonic_time()}),
    Min + rand:uniform(Max - Min + 1) - 1.