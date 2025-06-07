% Rules 1 - 5
coolingCapacity(DailyVolume, ez2) :- DailyVolume >= 1, DailyVolume =< 2000.
coolingCapacity(DailyVolume, ez3) :- DailyVolume >= 1, DailyVolume =< 3000.
coolingCapacity(DailyVolume, ez4) :- DailyVolume >= 1, DailyVolume =< 4000.
coolingCapacity(DailyVolume, ez5) :- DailyVolume >= 1, DailyVolume =< 6000.
coolingCapacity(DailyVolume, ez6) :- DailyVolume >= 1.
%% Choosen Cooler is matching output
% test with ?- choosenCoolerFits(2500, ez3). and change the cooler
choosenCoolerFits(DailyVolume, ChosenCooler) :- coolingCapacity(DailyVolume, ChosenCooler). 

% Rules 6 - 8
pythonTube(NumberOfFlavours, 6) :- NumberOfFlavours = 6.
pythonTube(NumberOfFlavours, 9) :- NumberOfFlavours = 9.
pythonTube(NumberOfFlavours, 12) :- NumberOfFlavours = 12.
%% Check the rules with ?- pythonTube(9, PythonSize). 

% Rules 9 - 10
region(us, 3/8).
region(eu, 1/4).
region(me, 1/4).
%% Check rules with ?- region(us, Co2RegulatorFitting). 

% Rules 11 - 13
validRackType(ez2, small).
validRackType(ez2, medium).
validRackType(ez2, large).
validRackType(ez3, medium).
validRackType(ez3, large).
validRackType(ez4, medium).
validRackType(ez4, large).
validRackType(ez5, large).
validRackType(ez6, large).
%% Check that the racktype fits
choosenRackTypeFits(Cooler, RackType) :- validRackType(Cooler, RackType).

% Rule 14 - Co2 Mounting influences RackType
validRackTypeForCo2Mounting(wall, _).  % Wall mounting allows any rack type
validRackTypeForCo2Mounting(rack, medium).  % Rack mounting requires medium or large
validRackTypeForCo2Mounting(rack, large).
%% Check Co2 mounting with rack type
co2MountingFits(Co2Mounting, RackType) :- validRackTypeForCo2Mounting(Co2Mounting, RackType).

% Rules 15 - 17
bibPumps(NumberOfFlavours, 6) :- NumberOfFlavours = 6.
bibPumps(NumberOfFlavours, 9) :- NumberOfFlavours = 9.
bibPumps(NumberOfFlavours, 12) :- NumberOfFlavours = 12.
%% Check the rules with ?- bibPumps(9, NumberOfPumps). 

% Rules 18 & 19
%% Auto-select with preference for larger/future-proof option  
waterManifold(DailyVolume, NumberOfFlavours, wm5) :- DailyVolume >= 3000 , NumberOfFlavours = 6.
waterManifold(DailyVolume, NumberOfFlavours, wm5) :- DailyVolume >= 3000 , NumberOfFlavours = 9.
waterManifold(DailyVolume, NumberOfFlavours, wm5) :- DailyVolume >= 3000 , NumberOfFlavours = 12.
waterManifold(DailyVolume, NumberOfFlavours, wm2) :- DailyVolume =< 3500 , NumberOfFlavours = 6.
waterManifold(DailyVolume, NumberOfFlavours, wm2) :- DailyVolume =< 3500 , NumberOfFlavours = 9.
%% System automatically determines water manifold
autoWaterManifold(DailyVolume, NumberOfFlavours, WM) :- 
    waterManifold(DailyVolume, NumberOfFlavours, WM).
%% Test it
%%% ?- autoWaterManifold(3200, 6, WM).

% Rule 20
%% PythonLength is checked for validity by calculating the longest sum of precut lengths
%% Additionally, check the list "Pieces" with the knowledge base of precut_python_lengths
%% PythonLength for precut_length values
precut_python_length(5).
precut_python_length(10).
precut_python_length(15).
precut_python_length(20).
precut_python_length(30).

%% python_length_sum(Total, ListOfPieces): Total is the sum of ListOfPieces, each a precut_length, Total > 30, in steps of 5 or the available precut_lengths
python_length_longest_sum(Total, Pieces) :-
    python_length_longest_sum_helper(0, Total, [], Pieces),
    0 is Total mod 5, !.

%% get the longest_sum when python_length is >30
python_length_longest_sum_helper(Acc, Acc, Pieces, Pieces).
python_length_longest_sum_helper(Acc, Total, PiecesSoFar, Pieces) :-
    precut_python_length(L),
    NewAcc is Acc + L,
    NewAcc =< Total,
    \+ (precut_python_length(L2), L2 > L, Acc + L2 =< Total),
    python_length_longest_sum_helper(NewAcc, Total, [L|PiecesSoFar], Pieces).

% check any number (int) can be cut into valid precut lengths
% check if each piece in the list is a valid_precut_length
python_length_is_valid(Total) :-
    Total > 30,
    0 is Total mod 5,
    python_length_longest_sum(Total, Pieces),
    forall(member(P, Pieces), precut_python_length(P)), !.



% Rules 21 - 23
%% rackAccessoires(Cooler, RackType, RackShelves, MountingBrackets)
rackAccessoires(Cooler, RackType, 2, 4) :- Cooler = ez6, RackType = large, !.
rackAccessoires(Cooler, RackType, 2, 4) :- Cooler = ez5, RackType = large, !.
rackAccessoires(Cooler, RackType, 0, 2) :- Cooler = ez4, RackType = small, !.
rackAccessoires(Cooler, RackType, 0, 2) :- Cooler = ez3, RackType = small, !.
rackAccessoires(Cooler, RackType, 0, 0) :- Cooler = ez2, RackType = small, !.
rackAccessoires(_, _, 0, 0).
%% Testing rackAccessoires(ez2, small, RackShelves, MountingBrackets)


% Complete validation with ALL 7 inputs (corrected)
validConfigurationComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting) :-
    % Rule 1-5: Check if chosen cooler fits daily volume
    choosenCoolerFits(DailyVolume, CoolingCapacity),
    % Rule 6-8: Check if python tube size matches flavours
    pythonTube(NumberOfFlavours, _),
    % Rule 9-10: Check if region is valid
    region(Region, _),
    % Rule 11-13: Check if rack type fits cooler
    choosenRackTypeFits(CoolingCapacity, RackType),
    % Rule 14: Check if Co2 mounting fits with rack type
    co2MountingFits(Co2Mounting, RackType),
    % Rule 15-17: Check if BIB pumps match flavours
    bibPumps(NumberOfFlavours, _),
    % Rule 18-19: Check if water manifold configuration exists
    waterManifold(DailyVolume, NumberOfFlavours, _),
    % Rule 20: Check if python length is valid (divisible by 5)
    pythonLengthIsValid(PythonLength, true), % change to new version
    % Rule 21-23: Check if rack accessories configuration exists
    rackAccessoires(CoolingCapacity, RackType, _, _).


%% === CREATE OUR TESTCASES === %%

% ===== CORRECTED INPUT STRUCTURE =====
% All inputs as per original specification:
% 1. DailyVolume (numerical)
% 2. CoolingCapacity (user choice - ez2, ez3, ez4, ez5, ez6)  
% 3. NumberOfFlavours (6, 9, 12)
% 4. Region (us, eu, me)
% 5. PythonLength (must be divisible by 5, precuts as well)
% 6. RackType (user preference - small, medium, large)
% 7. Co2Mounting (wall, rack)

% ===== VALIDATION FUNCTIONS =====

% Original validation (for backwards compatibility)
validConfiguration(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength) :-
    % Rule 1-5: Check if chosen cooler fits daily volume
    choosenCoolerFits(DailyVolume, Cooler),
    % Rule 6-8: Check if python tube size matches flavours
    pythonTube(NumberOfFlavours, _),
    % Rule 9-10: Check if region is valid
    region(Region, _),
    % Rule 11-13: Check if rack type fits cooler
    choosenRackTypeFits(Cooler, RackType),
    % Rule 15-17: Check if BIB pumps match flavours
    bibPumps(NumberOfFlavours, _),
    % Rule 18-19: Check if water manifold configuration exists
    waterManifold(DailyVolume, NumberOfFlavours, _),
    % Rule 20: Check if python length is valid (divisible by 5)
    python_length_longest_sum(PythonLength),
    % Rule 21-23: Check if rack accessories configuration exists
    rackAccessoires(Cooler, RackType, _, _).



% Generate complete Bill of Materials (BOM) with all auto-added parts - ORIGINAL VERSION
generateBOM(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength, BOM) :-
    % Check if Configuration is Ok
    validConfiguration(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength),
    % Get all auto-determined parts
    pythonTube(NumberOfFlavours, PythonSize),
    region(Region, Co2Fitting),
    bibPumps(NumberOfFlavours, BibPumpsCount),
    waterManifold(DailyVolume, NumberOfFlavours, WaterManifoldType),
    rackAccessoires(Cooler, RackType, RackShelves, MountingBrackets),
    % Fixed parts (always 1 piece)
    WaterBooster = 1,
    AirCompressor = 1,
    BibConnectors = NumberOfFlavours,  % Same as flavours
    PythonConnectors = 3,  % Always +3 as per your table
    % Create complete BOM structure
    BOM = bom([
        % Input specifications
        input(dailyVolume, DailyVolume, cups),
        input(numberOfFlavours, NumberOfFlavours, pieces),
        input(region, Region, code),
        input(pythonLength, PythonLength, meters),
        % Main components (chosen/validated)
        main(coolingCapacity, Cooler, 1, pieces),
        main(rackType, RackType, 1, pieces),
        % Auto-determined components
        auto(pythonTube, PythonSize, 1, pieces),
        auto(co2RegulatorFitting, Co2Fitting, 1, pieces),
        auto(bibPumps, bibPump, BibPumpsCount, pieces),
        auto(waterManifold, WaterManifoldType, 1, pieces),
        auto(rackShelves, rackShelf, RackShelves, pieces),
        auto(mountingBrackets, mountingBracket, MountingBrackets, pieces),
        % Fixed components (always included)
        fixed(waterBooster, waterBooster, WaterBooster, pieces),
        fixed(airCompressor, airCompressor, AirCompressor, pieces),
        fixed(bibConnectors, bibConnector, BibConnectors, pieces),
        fixed(pythonConnectors, pythonConnector, PythonConnectors, pieces)
    ]).

% NEW: Generate complete BOM with ALL 7 inputs (corrected)
generateBOMComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting, BOM) :-
    % Check if Configuration is Ok
    validConfigurationComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting),
    % Get all auto-determined parts
    pythonTube(NumberOfFlavours, PythonSize),
    region(Region, Co2Fitting),
    bibPumps(NumberOfFlavours, BibPumpsCount),
    waterManifold(DailyVolume, NumberOfFlavours, WaterManifoldType),
    rackAccessoires(CoolingCapacity, RackType, RackShelves, MountingBrackets),
    % Fixed parts (always 1 piece)
    WaterBooster = 1,
    AirCompressor = 1,
    BibConnectors = NumberOfFlavours,  % Same as flavours
    PythonConnectors = 3,  % Always +3 as per your table
    % Create complete BOM structure
    BOM = bom([
        % Input specifications (ALL 7 inputs)
        input(dailyVolume, DailyVolume, cups),
        input(coolingCapacity, CoolingCapacity, type),
        input(numberOfFlavours, NumberOfFlavours, pieces),
        input(region, Region, code),
        input(pythonLength, PythonLength, meters),
        input(rackType, RackType, preference),
        input(co2Mounting, Co2Mounting, type),
        % Auto-determined components
        auto(pythonTube, PythonSize, 1, pieces),
        auto(co2RegulatorFitting, Co2Fitting, 1, pieces),
        auto(bibPumps, bibPump, BibPumpsCount, pieces),
        auto(waterManifold, WaterManifoldType, 1, pieces),
        auto(rackShelves, rackShelf, RackShelves, pieces),
        auto(mountingBrackets, mountingBracket, MountingBrackets, pieces),
        % Fixed components (always included)
        fixed(waterBooster, waterBooster, WaterBooster, pieces),
        fixed(airCompressor, airCompressor, AirCompressor, pieces),
        fixed(bibConnectors, bibConnector, BibConnectors, pieces),
        fixed(pythonConnectors, pythonConnector, PythonConnectors, pieces)
    ]).

% ===== BOM VALIDATION WITH BOM OUTPUT =====

% Enhanced validation that also returns the complete BOM - ORIGINAL
validConfigurationWithBOM(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength, BOM) :-
    generateBOM(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength, BOM).

% NEW: Enhanced validation with complete inputs
validConfigurationWithBOMComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting, BOM) :-
    generateBOMComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting, BOM).

% ===== TEST CASE FACTS =====

% Original test cases (6 inputs) - for backwards compatibility
testCase(config1, 2000, 9, eu, ez2, medium, 40).
testCase(config2, 7000, 6, eu, ez5, small, 60).   % Expected INVALID
testCase(config3, 4000, 9, me, ez4, medium, 10).
testCase(config4, 2000, 6, us, ez5, large, 25).   % Expected INVALID
testCase(config5, 3500, 12, eu, ez2, large, 20).  % Expected INVALID
testCase(config6, 5000, 9, eu, ez5, large, 23).   % Expected INVALID

% NEW: Complete test cases with ALL 7 inputs
testCaseComplete(config1_complete, 2000, ez2, 9, eu, 40, medium, wall).
testCaseComplete(config2_complete, 7000, ez6, 6, eu, 60, large, rack).   % Now VALID
testCaseComplete(config3_complete, 4000, ez4, 9, me, 10, medium, wall).
testCaseComplete(config4_complete, 2000, ez2, 6, us, 25, large, rack).  % Now VALID
testCaseComplete(config5_complete, 3500, ez4, 12, eu, 20, large, rack).  % Now VALID  
testCaseComplete(config6_complete, 5000, ez5, 9, eu, 25, large, wall).   % Now VALID

% ===== SIMPLE TEST WRAPPER =====

% Test a specific configuration by name - ORIGINAL
testConfig(ConfigName) :-
    testCase(ConfigName, DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength),
    (validConfiguration(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength) ->
        (write(ConfigName), write(': VALID ✓'), nl)
    ;   (write(ConfigName), write(': INVALID ✗'), nl)
    ).

% NEW: Test complete configuration  
testConfigComplete(ConfigName) :-
    testCaseComplete(ConfigName, DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting),
    (validConfigurationComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting) ->
        (write(ConfigName), write(': VALID ✓'), nl)
    ;   (write(ConfigName), write(': INVALID ✗'), nl)
    ).

% Test all configurations - ORIGINAL
testAllConfigs :-
    testCase(ConfigName, _, _, _, _, _, _),
    testConfig(ConfigName),
    fail.
testAllConfigs.

% NEW: Test all complete configurations
testAllConfigsComplete :-
    testCaseComplete(ConfigName, _, _, _, _, _, _, _),
    testConfigComplete(ConfigName),
    fail.
testAllConfigsComplete.

% ===== PRETTY PRINT BOM =====

% Display BOM in a readable format
printBOM(BOM) :-
    BOM = bom(ItemList),
    nl, write('===== BILL OF MATERIALS ====='), nl,
    printBOMSection(ItemList, input, 'INPUT SPECIFICATIONS'),
    printBOMSection(ItemList, main, 'MAIN COMPONENTS'),
    printBOMSection(ItemList, auto, 'AUTO-DETERMINED COMPONENTS'),
    printBOMSection(ItemList, fixed, 'FIXED COMPONENTS'),
    write('============================'), nl.

% Print a specific section of the BOM
printBOMSection(ItemList, SectionType, SectionName) :-
    write(SectionName), write(':'), nl,
    member(Item, ItemList),
    Item =.. [SectionType, Category, Type, Quantity, Unit],
    write('  '), write(Category), write(': '),
    write(Type), write(' ('), write(Quantity), write(' '), write(Unit), write(')'), nl,
    fail.
printBOMSection(_, _, _) :- nl.

% ===== ENHANCED TEST FUNCTIONS =====

% Test configuration and show complete BOM - ORIGINAL
testConfigWithBOM(ConfigName) :-
    testCase(ConfigName, DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength),
    write('Testing '), write(ConfigName), write(':'), nl,
    (validConfigurationWithBOM(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength, BOM) ->
        (write('RESULT: VALID ✓'), nl,
         printBOM(BOM))
    ;   (write('RESULT: INVALID ✗'), nl)
    ).

% NEW: Test complete configuration with BOM
testConfigWithBOMComplete(ConfigName) :-
    testCaseComplete(ConfigName, DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting),
    write('Testing '), write(ConfigName), write(':'), nl,
    (validConfigurationWithBOMComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting, BOM) ->
        (write('RESULT: VALID ✓'), nl,
         printBOM(BOM))
    ;   (write('RESULT: INVALID ✗'), nl)
    ).

% Test all configurations with BOM output - ORIGINAL
testAllConfigsWithBOM :-
    testCase(ConfigName, _, _, _, _, _, _),
    nl, write('======= '), write(ConfigName), write(' ======='), nl,
    testConfigWithBOM(ConfigName),
    fail.
testAllConfigsWithBOM.

% NEW: Test all complete configurations with BOM
testAllConfigsWithBOMComplete :-
    testCaseComplete(ConfigName, _, _, _, _, _, _, _),
    nl, write('======= '), write(ConfigName), write(' ======='), nl,
    testConfigWithBOMComplete(ConfigName),
    fail.
testAllConfigsWithBOMComplete.

% Get BOM for custom configuration - ORIGINAL
customBOM(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength) :-
    (validConfigurationWithBOM(DailyVolume, NumberOfFlavours, Region, Cooler, RackType, PythonLength, BOM) ->
        (write('Configuration is VALID ✓'), nl,
         printBOM(BOM))
    ;   (write('Configuration is INVALID ✗'), nl)
    ).

% NEW: Get BOM for complete custom configuration
customBOMComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting) :-
    (validConfigurationWithBOMComplete(DailyVolume, CoolingCapacity, NumberOfFlavours, Region, PythonLength, RackType, Co2Mounting, BOM) ->
        (write('Configuration is VALID ✓'), nl,
         printBOM(BOM))
    ;   (write('Configuration is INVALID ✗'), nl)
    ).

% ===== USAGE EXAMPLES =====

% ORIGINAL TESTS (6 inputs - for backwards compatibility):
% ?- testConfig(config1).                    % Should be VALID
% ?- testConfig(config2).                    % Should be INVALID
% ?- testAllConfigs.
% ?- testConfigWithBOM(config1).
% ?- testAllConfigsWithBOM.
% ?- customBOM(2000, 9, eu, ez2, medium, 40).

% NEW COMPLETE TESTS (7 inputs - corrected version):
% ?- testConfigComplete(config1_complete).
% ?- testAllConfigsComplete. 
% ?- testConfigWithBOMComplete(config1_complete).
% ?- testAllConfigsWithBOMComplete.
% ?- customBOMComplete(2000, ez2, 9, eu, 40, medium, wall).

% Test parts of a configuration:
% ?- choosenCoolerFits(7000, ez5).          % false (ez5 max 6000)
% ?- choosenRackTypeFits(ez5, small).       % false (ez5 needs large)
% ?- validPythonLength(23).                 % false (not divisible by 5)
% ?- co2MountingFits(rack, small).          % false (rack needs medium/large)

