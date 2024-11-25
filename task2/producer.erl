-module(producer).
-export([producer/4]).

% Public function
producer(Id, ConveyorPid, MaxSize, MaxPackages) -> 
    io:format("Producer ~p - Starting in process ~p~n", [Id, self()]),
    producer(Id, ConveyorPid, MaxSize, 0, MaxPackages).

% Private functions
producer(Id, ConveyorPid, _, MaxPackages, MaxPackages) -> 
    io:format("Producer ~p - Produced all ~p packages~n", [Id, MaxPackages]),
    ConveyorPid ! stop;

producer(Id, ConveyorPid, MaxSize, Counter, MaxPackages) -> 
    {PackageId, PackageSize} = createPackage(Counter, MaxSize),
    
    io:format("Producer ~p - New package with size ~p~n", [Id, PackageSize]),
    ConveyorPid ! {PackageId, PackageSize},
    timer:sleep(500),
    
    producer(Id, ConveyorPid, MaxSize, Counter + 1, MaxPackages).

createPackage(Counter, MAX_CAPACITY) -> {Counter, random_between(1, MAX_CAPACITY)}.

random_between(Min, Max) when Min =< Max ->
    _ = rand:seed(exsplus, {os:system_time(millisecond), erlang:phash2(self()), erlang:monotonic_time()}),
    Min + rand:uniform(Max - Min + 1) - 1.