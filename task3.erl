%% File: task3.erl
-module(task3).
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
    ProducerPid = spawn(?MODULE, producer, [Counter, PidConveyor, MAX_CAPACITY]),
    ProducerPid ! ok.

conveyor(TruckPid) -> 
    receive
        {From, Package} ->
            TruckPid ! {From, Package},
            conveyor(TruckPid)
    end.

truck(Cap, MAX_CAPACITY) -> 
    receive
        {Producer, {PackageId, PackageSize}} ->
            io:format("Truck ~p - Received package ~p with size ~p~n",[self(), PackageId, PackageSize]),
            if 
                PackageSize + Cap > MAX_CAPACITY -> 
                    io:format("Truck ~p - Capacity exceeded. Emptying truck~n", [self()]),
                    Producer ! stop,
                    timer:sleep(10000),
                    Producer ! ok,
                    NewCap = Cap+PackageSize-MAX_CAPACITY,
                    io:format("Truck ~p - Loaded package. Capacity:~p/~p~n", [self(), NewCap, MAX_CAPACITY]),
                    truck(NewCap, MAX_CAPACITY);
                true -> 
                    io:format("Truck ~p - Loaded package. Capacity:~p/~p~n", [self(), Cap+PackageSize, MAX_CAPACITY]), 
                    Producer ! ok,
                    truck(Cap + PackageSize, MAX_CAPACITY)
            end
    end.

producer(Counter, ConveyorPid, MAX_CAPACITY) -> 
    receive
        ok ->
            {PackageId, PackageSize} = createPackage(Counter, MAX_CAPACITY),
            io:format("Producer ~p - New package with size ~p~n", [self(), PackageSize]),
            ConveyorPid ! {self(), {PackageId, PackageSize}},
            timer:sleep(1000),
            producer(Counter+1, ConveyorPid, MAX_CAPACITY);
        stop ->
            io:format("Producer ~p - Stopped~n", [self()]),
            producer(Counter, ConveyorPid, MAX_CAPACITY)

    end.

createPackage(Counter, MAX_CAPACITY) -> {Counter, random_between(0, MAX_CAPACITY)}.

random_between(Min, Max) when Min =< Max ->
    _ = rand:seed(exsplus, {os:system_time(millisecond), erlang:phash2(self()), erlang:monotonic_time()}),
    Min + rand:uniform(Max - Min + 1) - 1.