-module(truck).
-export([truck/2]).

% Public function
truck(Id, MaxCapacity) -> 
    io:format("Truck ~p - Starting in process ~p~n", [Id, self()]),
    truck(Id, 0, MaxCapacity).

% Private functions
truck(Id, CurrentCapacity, MaxCapacity) -> 
    receive
        {ConveyorPid , {PackageId, PackageSize}} ->
            io:format("Truck ~p - Received package ~p with size ~p~n",[Id, PackageId, PackageSize]),
            NewCapacity = PackageSize + CurrentCapacity,
            if 
                NewCapacity == MaxCapacity -> 
                    reloadTruck(Id, 0, MaxCapacity, ConveyorPid);
                NewCapacity > MaxCapacity -> 
                    reloadTruck(Id, PackageSize, MaxCapacity, ConveyorPid);
                true ->
                    loadTruck(Id, NewCapacity, MaxCapacity)
            end;
        stop ->
            io:format("Truck ~p - Finished. Capacity: ~p/~p~n", [Id, CurrentCapacity, MaxCapacity])
    end.

reloadTruck(Id, 0, MaxCapacity, ConveyorPid) ->
    io:format("Truck ~p - Loaded package. Capacity: ~p/~p~n", [Id, MaxCapacity, MaxCapacity]), 
    reloadTruck(Id, ConveyorPid),
    truck(Id, 0, MaxCapacity);

reloadTruck(Id, NewCapacity, MaxCapacity, ConveyorPid) ->
    reloadTruck(Id, ConveyorPid),
    loadTruck(Id, NewCapacity, MaxCapacity).

reloadTruck(Id, ConveyorPid) ->
    ConveyorPid ! wait,
    io:format("Truck ~p - Capacity exceeded. Replacing truck~n", [Id]),
    timer:sleep(3000),
    io:format("Truck ~p - Finished replacing truck~n", [Id]),
    ConveyorPid ! restart.

loadTruck(Id, NewCapacity, MaxCapacity) ->
    io:format("Truck ~p - Loaded package. Capacity: ~p/~p~n", [Id, NewCapacity, MaxCapacity]), 
    truck(Id, NewCapacity, MaxCapacity).