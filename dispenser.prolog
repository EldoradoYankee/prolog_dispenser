% Rules 1 - 5: Cooling Capacity Validation
%% These rules validate whether a chosen cooler can handle the specified daily volume
%% Each cooler type has a maximum capacity range for daily beverage volume
coolingCapacity(DailyVolume, ez2) :- DailyVolume >= 1, DailyVolume =< 2000.
coolingCapacity(DailyVolume, ez3) :- DailyVolume >= 1, DailyVolume =< 3000.
coolingCapacity(DailyVolume, ez4) :- DailyVolume >= 1, DailyVolume =< 4000.
coolingCapacity(DailyVolume, ez5) :- DailyVolume >= 1, DailyVolume =< 6000.
coolingCapacity(DailyVolume, ez6) :- DailyVolume >= 1.

%% Validates that the chosen cooler fits the daily volume requirements
choosenCoolerFits(DailyVolume, ChosenCooler) :- coolingCapacity(DailyVolume, ChosenCooler).
%%% Test queries: ?- choosenCoolerFits(2500, ez3). ?- choosenCoolerFits(7000, ez2).

% Rules 6 - 8: Python Tube Size Validation
%% These rules ensure the python tube configuration matches the number of flavours
%% Each flavour count requires a specific python tube size for proper operation
pythonTube(NumberOfFlavours, 6) :- NumberOfFlavours = 6.
pythonTube(NumberOfFlavours, 9) :- NumberOfFlavours = 9.
pythonTube(NumberOfFlavours, 12) :- NumberOfFlavours = 12.

%% Validates that the python tube configuration fits the flavour requirements
pythonConfigurationFits(NumberOfFlavours) :- pythonTube(NumberOfFlavours, _).
%%% Test queries: ?- pythonConfigurationFits(9). ?- pythonConfigurationFits(8).

% Rules 9 - 10: Regional CO2 Regulator Fitting
%% These rules specify the CO2 regulator fitting type based on geographical region
%% Different regions require different fitting standards for regulatory compliance
region(us, 3/8).
region(eu, 1/4).
region(me, 1/4).

%% Validates that the regional specifications are met for the configuration
regionalRequirementsMet(Region) :- region(Region, _).
%%% Test queries: ?- regionalRequirementsMet(us). ?- regionalRequirementsMet(asia).

% Rules 11 - 13: Rack Type Compatibility
%% These rules define which rack types are compatible with each cooler model
%% Larger coolers require larger rack types due to size and weight constraints
validRackType(ez2, small).
validRackType(ez2, medium).
validRackType(ez2, large).
validRackType(ez3, medium).
validRackType(ez3, large).
validRackType(ez4, medium).
validRackType(ez4, large).
validRackType(ez5, large).
validRackType(ez6, large).

%% Validates that the chosen rack type is compatible with the cooler
choosenRackTypeFits(Cooler, RackType) :- validRackType(Cooler, RackType).
%%% Test queries: ?- choosenRackTypeFits(ez5, small). ?- choosenRackTypeFits(ez2, medium).

% Rule 14: CO2 Mounting and Rack Type Compatibility
%% This rule ensures CO2 mounting type is compatible with the selected rack type
%% Rack mounting requires sufficient space, limiting compatible rack sizes
validRackTypeForCo2Mounting(wall, _).  % Wall mounting allows any rack type
validRackTypeForCo2Mounting(rack, medium).  % Rack mounting requires medium or large
validRackTypeForCo2Mounting(rack, large).

%% Validates that CO2 mounting type is compatible with rack type
co2MountingFits(Co2Mounting, RackType) :- validRackTypeForCo2Mounting(Co2Mounting, RackType).
%%% Test queries: ?- co2MountingFits(rack, small). ?- co2MountingFits(wall, large).

% Rules 15 - 17: BIB Pump Quantity Validation
%% These rules ensure the number of BIB pumps matches the number of flavours
%% Each flavour requires one dedicated BIB pump for proper syrup delivery
bibPumps(NumberOfFlavours, 6) :- NumberOfFlavours = 6.
bibPumps(NumberOfFlavours, 9) :- NumberOfFlavours = 9.
bibPumps(NumberOfFlavours, 12) :- NumberOfFlavours = 12.

%% Validates that the BIB pump configuration matches the flavour requirements
bibPumpConfigurationFits(NumberOfFlavours) :- bibPumps(NumberOfFlavours, _).
%%% Test queries: ?- bibPumpConfigurationFits(9). ?- bibPumpConfigurationFits(15).

% Rules 18 & 19: Water Manifold Selection
%% These rules determine the appropriate water manifold based on volume and flavours
%% WM5 is prioritized for overlapping conditions to provide greater capacity
waterManifold(DailyVolume, NumberOfFlavours, wm5) :- DailyVolume >= 3000 , NumberOfFlavours = 6.
waterManifold(DailyVolume, NumberOfFlavours, wm5) :- DailyVolume >= 3000 , NumberOfFlavours = 9.
waterManifold(DailyVolume, NumberOfFlavours, wm5) :- DailyVolume >= 3000 , NumberOfFlavours = 12.
waterManifold(DailyVolume, NumberOfFlavours, wm2) :- DailyVolume =< 3500 , NumberOfFlavours = 6.
waterManifold(DailyVolume, NumberOfFlavours, wm2) :- DailyVolume =< 3500 , NumberOfFlavours = 9.

%% Validates that a suitable water manifold configuration exists for the requirements
waterManifoldFits(DailyVolume, NumberOfFlavours) :- waterManifold(DailyVolume, NumberOfFlavours, _).
%%% Test queries: ?- waterManifoldFits(3200, 6). ?- waterManifoldFits(2500, 12).

% Rule 20: Python Length Validation
%% This rule validates python length compatibility with manufacturing standards and
%% provides optimal precut specifications for shipping operations
%% Validation ensures all lengths are divisible by 5 to accommodate standard precut pieces
%% Specification generation uses recursive optimization to minimize total piece count
precutPythonLength(5).
precutPythonLength(10).
precutPythonLength(15).
precutPythonLength(20).
precutPythonLength(30).

%% Validates that the total python length meets precut assembly requirements
pythonLengthIsValid(Total) :-
    Total > 0,
    0 is Total mod 5.
%%% Test queries: ?- pythonLengthIsValid(25). ?- pythonLengthIsValid(23).

%% This functionalit calculates the combinations of precut lengths
calculateOptimalPythonPrecuts(TotalLength, []) :- 
    TotalLength =< 0, !.

calculateOptimalPythonPrecuts(TotalLength, [Piece|RestPieces]) :-
    TotalLength > 0,
    findLargestPiece(TotalLength, Piece),
    RemainingLength is TotalLength - Piece,
    calculateOptimalPythonPrecuts(RemainingLength, RestPieces).

%% Helper predicate to identify the largest precut piece that fits the requirement
findLargestPiece(RequiredLength, SelectedPiece) :-
    findall(Piece, (precutPythonLength(Piece), Piece =< RequiredLength), AvailablePieces),
    max_list(AvailablePieces, SelectedPiece).

% Rules 21 - 23: Rack Accessories Configuration
%% These rules determine the required rack accessories based on cooler and rack type
%% Larger coolers require additional shelves and mounting brackets for stability
rackAccessoires(Cooler, RackType, 2, 4) :- Cooler = ez6, RackType = large, !.
rackAccessoires(Cooler, RackType, 2, 4) :- Cooler = ez5, RackType = large, !.
rackAccessoires(Cooler, RackType, 0, 2) :- Cooler = ez4, RackType = medium, !.
rackAccessoires(Cooler, RackType, 0, 2) :- Cooler = ez3, RackType = medium, !.
rackAccessoires(Cooler, RackType, 0, 0) :- Cooler = ez2, RackType = small, !.
rackAccessoires(_, _, 0, 0).

%% Validates that rack accessories configuration is available for the cooler and rack combination
rackAccessoriesConfigurationExists(Cooler, RackType, MountingBrackets) :- rackAccessoires(Cooler, RackType, _, MountingBrackets).
%%% Test queries: ?- rackAccessoriesConfigurationExists(ez5, large). ?- rackAccessoriesConfigurationExists(ez2, small).

% Rule 24: Hardware Components for Mounting Brackets
%% This rule determines required screws and dowels based on mounting bracket quantity
%% Each mounting bracket requires specific hardware components for proper installation
mountingComponents(MountingBrackets, Screws, Dowels) :-
    MountingBrackets > 0,
    Screws is MountingBrackets * 4,
    Dowels is MountingBrackets * 2, !.
mountingComponents(0, 0, 0).

%% Validates that mounting hardware configuration is available for the bracket quantity
mountingComponentsConfigurationExists(MountingBrackets) :- mountingComponents(MountingBrackets, _, _).
%%% Test queries: ?- mountingComponents(4, Screws, Dowels). ?- mountingComponents(0, Screws, Dowels).


% Complete Configuration Validation
%% Validation predicates provide business-readable interfaces to technical rule implementations,
%% enhancing stakeholder comprehension while maintaining logical precision
%% This comprehensive validation ensures all configuration parameters satisfy business requirements
validateCompleteConfiguration(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting) :-
    % Rule 1-5: Check if chosen cooler fits daily volume
    choosenCoolerFits(DailyVolume, CoolingCapacity),
    % Rule 6-8: Check if python tube configuration fits flavour requirements
    pythonConfigurationFits(NumberOfFlavours),
    % Rule 9-10: Check if regional requirements are met
    regionalRequirementsMet(Region),
    % Rule 11-13: Check if rack type fits cooler
    choosenRackTypeFits(CoolingCapacity, RackType),
    % Rule 14: Check if Co2 mounting fits with rack type
    co2MountingFits(Co2Mounting, RackType),
    % Rule 15-17: Check if BIB pump configuration fits requirements
    bibPumpConfigurationFits(NumberOfFlavours),
    % Rule 18-19: Check if water manifold configuration fits requirements
    waterManifoldFits(DailyVolume, NumberOfFlavours),
    % Rule 20: Check if python length meets manufacturing standards
    pythonLengthIsValid(PythonLength),
    % Rule 21-23: Check if rack accessories configuration exists
    rackAccessoriesConfigurationExists(CoolingCapacity, RackType, MountingBrackets),
    % Rule 24: Check if the calculation exists correclty
    mountingComponentsConfigurationExists(MountingBrackets).
%%% Test query: ?- validateCompleteConfiguration(2000, ez2, 6, eu, 20, small, wall).

% Test Cases from Business Requirements
%% These test cases represent the defined test cases to get the project complexity finally approved
%% Each case tests different aspects of the validation logic with known outcomes

% Configuration 1: Standard valid setup
testCase(config1, 2000, ez2, 9, eu, 40, medium, rack).

% Configuration 2: Invalid - EZ5 requires large rack, not small
testCase(config2, 7000, ez5, 6, eu, 60, small, wall).

% Configuration 3: Standard valid medium-capacity setup
testCase(config3, 4000, ez4, 9, me, 10, medium, wall).

% Configuration 4: Valid oversized cooler selection
testCase(config4, 2000, ez5, 6, us, 25, large, rack).

% Configuration 5: Invalid - EZ2 capacity exceeded
testCase(config5, 3500, ez2, 12, eu, 20, large, rack).

% Configuration 6: Invalid - Python length not divisible by 5
testCase(config6, 5000, ez5, 9, eu, 23, large, rack).

% Configuration 7: High-capacity valid setup
testCase(config7, 5000, ez5, 6, eu, 50, large, rack).

% Configuration 8: Minimal valid configuration
testCase(config8, 2000, ez2, 6, eu, 20, small, wall).

% Configuration 9: Standard medium-capacity setup
testCase(config9, 4000, ez4, 6, eu, 30, medium, wall).

% Test Execution Predicates
%% These predicates provide automated testing capabilities for configuration validation
%% They enable systematic verification of business rule compliance across test cases

%% Tests a single configuration and displays the validation result
testConfig(ConfigName) :-
    testCase(ConfigName, DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting),
    write('Testing '), write(ConfigName), write(': '),
    (validateCompleteConfiguration(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting) ->
        (write(ConfigName), write(' is VALID'), nl, writeCalculatedValues(CoolingCapacity, RackType, PythonLength))
    ;   write('INVALID ✗')
    ), nl.
%%% Test query: ?- testConfig(config1).

%% Executes validation tests for all predefined configurations
testAllExcelConfigs :-
    write('===== CONFIGURATION VALIDATION RESULTS ====='), nl,
    testConfig(config1),
    testConfig(config2),
    testConfig(config3),
    testConfig(config4),
    testConfig(config5),
    testConfig(config6),
    testConfig(config7),
    testConfig(config8),
    testConfig(config9),
    write('=========================================='), nl.
%%% Test query: ?- testAllExcelConfigs.

%% Provides quick validity assessment for individual configurations
quickCheck(ConfigName) :-
    testCase(ConfigName, DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting),
    (validateCompleteConfiguration(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting) ->
        (write(ConfigName), write(' is VALID'), nl, writeCalculatedValues(CoolingCapacity, RackType, PythonLength))
    ;   (write(ConfigName), write(' is INVALID'))
    ), nl.
%%% Test query: ?- quickCheck(config5).

% Write the calculated Mounting Brackets, screws, python precuts etc. after a valid configuration.
writeCalculatedValues(Cooler, RackType, PythonLength) :-
    write('Calculated / Auto added parts'), nl,
    rackAccessoires(Cooler, RackType, Shelves, MountingBrackets),
    write('Shelves: '), write(Shelves), nl,
    write('Mounting Brackets: '), write(MountingBrackets), nl,
    mountingComponents(MountingBrackets, Screws, Dowels),
    write('Screws: '), write(Screws), nl,
    write('Dowels: '), write(Dowels), nl,
    calculateOptimalPythonPrecuts(PythonLength, PrecutPieces),
    write('Python Precut Pieces: '), write(PrecutPieces), nl.
