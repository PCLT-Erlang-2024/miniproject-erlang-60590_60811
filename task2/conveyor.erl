-module(conveyor).
-export([conveyor/2]).

% Public function
conveyor(Id, TruckPid) -> 
    io:format("Conveyor ~p - Starting in process ~p~n", [Id, self()]),
    conveyor(Id, TruckPid, 0).

% Private function
conveyor(Id, TruckPid, _) -> 
    receive
        {PackageId, PackageSize} ->
            io:format("Conveyor ~p - Received package with size ~p~n", [Id, PackageSize]),
            TruckPid ! {PackageId, PackageSize},
            conveyor(Id, TruckPid, 0);
        stop ->
            io:format("Conveyor ~p - Finished~n", [Id]),
            TruckPid ! stop
    end.