%%% FACTBASE %%%%

% Regulatory fitting size by regions
regulator_fitting(eu, '1/4').
regulator_fitting(me, '1/4').
regulator_fitting(us, '3/8').

% CoolingCapacity valid based on DailyVolume (>1 ez2 to ez6)
valid_cooling_capacity(DailyVolume, ez2) :- DailyVolume >= 1, DailyVolume =< 2000.
valid_cooling_capacity(DailyVolume, ez3) :- DailyVolume >= 1, DailyVolume =< 3000.
valid_cooling_capacity(DailyVolume, ez4) :- DailyVolume >= 1, DailyVolume =< 4000.
valid_cooling_capacity(DailyVolume, ez5) :- DailyVolume >= 1, DailyVolume =< 5000.
valid_cooling_capacity(DailyVolume, ez6) :- DailyVolume >= 1.

% RackSize allowed based on CoolingCapacity
rack_size(ez2, small).
rack_size(ez2, medium).
rack_size(ez2, large).
rack_size(ez3, medium).
rack_size(ez3, large).
rack_size(ez4, medium).
rack_size(ez4, large).
rack_size(ez5, large).
rack_size(ez6, large).

% Co2-Regulator Mounting sizes for Type "rack"
rack_size_type_rack(Type) :- Type = medium; Type = large.

% The RackType is independent of Co2-Regulator-Mounting when the mounting type is 'Wall'.
rack_type('wall', _).  % Any rack type allowed

% PythonType valid for exact NumberOfFlavours
python_type(6, 6).
python_type(9, 12).
python_type(12, 12).



% ---
% PYTHON LENGTH
% ---
%
% PythonLength for precut_length values
precut_python_length(5).
precut_python_length(10).
precut_python_length(15).
precut_python_length(20).
precut_python_length(30).

% python_length_sum(Total, ListOfPieces): Total is the sum of ListOfPieces, each a precut_length, Total > 30, in steps of 5
python_length_longest_sum(Total, Pieces) :-
    python_length_longest_sum_helper(0, Total, [], Pieces),
    Total > 30,
    0 is Total mod 5.

% get the longest_sum when python_length is >30
python_length_longest_sum_helper(Acc, Acc, Pieces, Pieces).
python_length_longest_sum_helper(Acc, Total, PiecesSoFar, Pieces) :-
    precut_python_length(L),
    NewAcc is Acc + L,
    NewAcc =< Total,
    % Ensure L is the largest possible piece for the remaining length
    \+ (precut_python_length(L2), L2 > L, Acc + L2 =< Total),
    python_length_longest_sum_helper(NewAcc, Total, [L|PiecesSoFar], Pieces).



% BibPump for range of NumberOfFlavours
bib_pump(NumberOfFlavours, 6) :- NumberOfFlavours =< 6, NumberOfFlavours =< 9.
bib_pump(NumberOfFlavours, 9) :- NumberOfFlavours > 10, NumberOfFlavours =< 12.
bib_pump(NumberOfFlavours, 12) :- NumberOfFlavours = 12.

% BIBPump for exact NumberOfFlavours
bib_pump(6, 6).
bib_pump(9, 9).
bib_pump(12, 12).

% ---
% WaterManifold based on DailyVolume and NumberOfFlavours
% ---
%
% WaterMainfold WM2 for DailyVolume =< 3500 and NumberOfFlavours = 6 or 9
water_manifold(wm2, DailyVolume, Flavours) :-
    DailyVolume =< 3500,
    (Flavours = 6; Flavours = 9).

% WaterMainfold WM5 for DailyVolume >3000 and NumberOfFlavours = 6 or 9 or 12
water_manifold(wm5, DailyVolume, Flavours) :-
    DailyVolume > 3000,
    (Flavours = 6; Flavours = 9; Flavours = 12).

% ---
% config
% ---
%
% Define possible components
component(water_booster).
component(air_compressor).
component(co2_regulator).
component(water_manifold).
component(python_type).

% A Config_ID got a component
config_id_has(Config_ID, Component).
