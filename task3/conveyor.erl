-module(conveyor).
-export([conveyor/2]).

% Public function
conveyor(Id, TruckPid) -> 
    io:format("Conveyor ~p - Starting in process ~p~n", [Id, self()]),
    conveyor(Id, TruckPid, true).

% Private function
conveyor(Id, TruckPid, true) -> 
    receive
        {PackageId, PackageSize} ->
            io:format("Conveyor ~p - Received package with size ~p~n", [Id, PackageSize]),
            TruckPid ! {self(), {PackageId, PackageSize}},
            conveyor(Id, TruckPid, true);
        wait ->
            io:format("Conveyor ~p - Stopped~n", [Id]),
            conveyor(Id, TruckPid, false);
        stop ->
            io:format("Conveyor ~p - Finished~n", [Id]),
            TruckPid ! stop
    end;

conveyor(Id, TruckPid, false) ->
    receive
        restart -> 
            io:format("Conveyor ~p - Restarted~n", [Id]),
            conveyor(Id, TruckPid, true)
    end.