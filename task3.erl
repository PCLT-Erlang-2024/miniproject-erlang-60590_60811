%% File: task3.erl
-module(task3).
-export([start/2, startN/3, producer/4, conveyor/1, truck/2, createPackage/2, random_between/2]).


startN(0, _, _) -> ok;

startN(N_SHIPMENTLINES, MAX_CAPACITY, MAX_PACKAGES) -> 
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    ProducerPid = spawn(?MODULE, producer, [Counter, PidConveyor, MAX_CAPACITY, MAX_PACKAGES]),
    ProducerPid ! start,
    startN(N_SHIPMENTLINES-1, MAX_CAPACITY, MAX_PACKAGES).


start(MAX_CAPACITY, MAX_PACKAGES) ->
    Capacity = 0,
    PidTruck = spawn(?MODULE, truck, [Capacity, MAX_CAPACITY]),
    PidConveyor = spawn(?MODULE, conveyor, [PidTruck]),
    Counter = 0,
    ProducerPid = spawn(?MODULE, producer, [Counter, PidConveyor, MAX_CAPACITY, MAX_PACKAGES]),
    ProducerPid ! start.

conveyor(TruckPid) -> 
    receive
        {From, {PackageId, PackageSize}} ->
            io:format("Conveyor ~p - Received package with size ~p~n", [self(), PackageSize]),
            TruckPid ! {From, {PackageId, PackageSize}},
            conveyor(TruckPid);
        stop ->
            io:format("Conveyor ~p - Finished~n", [self()]),
            TruckPid ! stop,
            true
    end.

truck(Cap, MAX_CAPACITY) -> 
    receive
        {ProducerPid, {PackageId, PackageSize}} ->
            io:format("Truck ~p - Received package ~p with size ~p~n",[self(), PackageId, PackageSize]),
            if 
                PackageSize + Cap > MAX_CAPACITY -> 
                    io:format("Truck ~p - Capacity exceeded. Emptying truck~n", [self()]),
                    ProducerPid ! wait,
                    timer:sleep(10000),
                    ProducerPid ! start,
                    NewCap = Cap+PackageSize-MAX_CAPACITY,
                    io:format("Truck ~p - Loaded package. Capacity:~p/~p~n", [self(), NewCap, MAX_CAPACITY]),
                    truck(NewCap, MAX_CAPACITY);
                true -> 
                    io:format("Truck ~p - Loaded package. Capacity:~p/~p~n", [self(), Cap+PackageSize, MAX_CAPACITY]), 
                    ProducerPid ! start,
                    truck(Cap + PackageSize, MAX_CAPACITY)
            end;
        stop ->
            io:format("Truck ~p - Finished~n", [self()]),
            true
    end.

producer(C, ConveyorPid, _, C) -> 
    io:format("Producer ~p - Reached max packages produced ~p and Finished~n", [self(), C]),
    ConveyorPid ! stop;

producer(Counter, ConveyorPid, MAX_CAPACITY, MAX_PACKAGES) -> 
    receive
        start ->
            {PackageId, PackageSize} = createPackage(Counter, MAX_CAPACITY),
            io:format("Producer ~p - New package with size ~p~n", [self(), PackageSize]),
            ConveyorPid ! {self(), {PackageId, PackageSize}},
            timer:sleep(500),
            producer(Counter+1, ConveyorPid, MAX_CAPACITY, MAX_PACKAGES);
        wait ->
            io:format("Producer ~p - Waiting for truck to be emptied~n", [self()]),
            producer(Counter, ConveyorPid, MAX_CAPACITY, MAX_PACKAGES)

    end.

createPackage(Counter, MAX_CAPACITY) -> {Counter, random_between(1, MAX_CAPACITY)}.

random_between(Min, Max) when Min =< Max ->
    _ = rand:seed(exsplus, {os:system_time(millisecond), erlang:phash2(self()), erlang:monotonic_time()}),
    Min + rand:uniform(Max - Min + 1) - 1.