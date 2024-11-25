-module(producer).
-export([producer/3]).

% Public function
producer(Id, ConveyorPid, MaxPackages) -> 
    io:format("Producer ~p - Starting in process ~p~n", [Id, self()]),
    producer(Id, ConveyorPid, 0, MaxPackages).

% Private functions
producer(Id, ConveyorPid, MaxPackages, MaxPackages) -> 
    io:format("Producer ~p - Produced all ~p packages~n", [Id, MaxPackages]),
    ConveyorPid ! stop;

producer(Id, ConveyorPid, Counter, MaxPackages) -> 
    {PackageId, PackageSize} = createPackage(Counter),
    
    io:format("Producer ~p - New package with size ~p~n", [Id, PackageSize]),
    ConveyorPid ! {PackageId, PackageSize},
    timer:sleep(500),
    
    producer(Id, ConveyorPid, Counter + 1, MaxPackages).

createPackage(Counter) -> {Counter, 1}.