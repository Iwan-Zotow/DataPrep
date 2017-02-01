CurrentRUtype = 8;
AssignedRUType = 8;

% Labeling Your Output
% Named tokens can also be useful in labeling the output from the MATLAB regular expression functions. 
% This is especially true when you are processing numerous strings.
p1 = '(?<RadiationUnitType>[0-9]+)';
p2 = '(?<OuterCupType>[0-9]+)';
p3 = '(?<InnerCupType>[a-zA-Z0-9]+)';
p4 = '(?<CollimatorType>[0-9]+)';
p5 = '(?<Y>[0-9]+)';
p6 = '(?<Z>[0-9]+)';
expr = ['R' p1 'O' p2 'I' p3 'C' p4 '_' 'Y' p5 'Z' p6 '\.3ddose'];
%filename = 'R2O2IGC15_Y0Z100.3ddose';
%kdd = regexp(filename, expr, 'names');

files = dir('Kdd_Convert\In\*.3ddose');
K = length(files);
if K == 0
    warning('nothing to convert!');
else
    for k = 1: K

        filename = files(k).name;
        kdd = regexp(filename, expr, 'names');
        if isempty(kdd)
            warning('bad file name: %s', filename);
        else
            assert(length(kdd.RadiationUnitType) <= 8);
            RadiationUnitType = str2num(['uint32(' kdd.RadiationUnitType ')']);
            assert( RadiationUnitType <= 99999999 );

            assert(length(kdd.OuterCupType) <= 8);
            OuterCupType = str2num(['uint32(' kdd.OuterCupType ')']);
            assert( OuterCupType <= 99);

            InnerCupType = kdd.InnerCupType;

            assert(length(kdd.CollimatorType) <= 8);
            CollimatorType = str2num(['uint32(' kdd.CollimatorType ')']);
            assert(CollimatorType <= 999);

            assert(length(kdd.Y) <= 8);
            Y = str2num(['uint32(' kdd.Y ')']);
            assert( Y <= 999 );

            assert(length(kdd.Z) <= 8);
            Z = str2num(['uint32(' kdd.Z ')']);
            assert( Z <= 999 );

            if RadiationUnitType == CurrentRUtype
                RadiationUnitType = AssignedRUType;
            end

            newfilename = sprintf('R%dO%dI%s_Y%03dZ%03dC%03d.3ddose', RadiationUnitType, OuterCupType, ...
                InnerCupType, Y, Z, CollimatorType);
            disp(sprintf('Renaming %s to %s...', filename, newfilename));
            eval(['!rename ' 'Kdd_Convert\In\' filename ' ' newfilename]);
        end
    end
    disp('Renaming completed.');
end


