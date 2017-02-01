%Created by Chao Wang, 3/17/2011
% Load .RduParam file to a structure 'RduParam'
%(1) RuType
%(2) NumOfOuterCups
%(3) OuterCups{iOC} 
%    (i) OuterCupType
%   (ii) NumOfAssociatedInnerCups
%   (iii) InnerCupTypes{iIC}
%(4) NumOfCollimators
%(5) CollimatorSizes{iCmt}
%(6) FocusRegionRadius
%(7) FocusRegionZMax
%(8) FocusRegionZmin
%(9) MinVel(X,Y,Z)  MaxVel(X,Y,Z)
%(10) MinAccl(X,Y,Z)  MaxAccl(X,Y,Z)
%(11) MinCollimatorSwitchTime

function RduParam = CwLoadRduParam( RduParamFilePath )
    
    assert( nargin == 1 );
    
    fid = fopen(RduParamFilePath, 'rt', 'native', 'US-ASCII');
    if fid == -1
        error('fail to open file for read: %s', RduParamFilePath);
    end

    [RduParam.RuType, count] = fscanf(fid, '%d', 1);
    assert(count == 1);

    [RduParam.NumOfOuterCups, count] = fscanf(fid, '%d', 1);
    assert(count == 1)
    assert(RduParam.NumOfOuterCups > 0);
    
    RduParam.OuterCups = cell(RduParam.NumOfOuterCups,1);
    for iOC = 1 : RduParam.NumOfOuterCups
        [RduParam.OuterCups{iOC}.OuterCupType, count] = fscanf(fid, '%d', 1);
        assert(count == 1)
        assert(RduParam.OuterCups{iOC}.OuterCupType > 0);  
        % OuterCupType = 0 is reserved for QA phantom only
    end

    for iOC = 1 : RduParam.NumOfOuterCups
        [RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups, count] = fscanf(fid, '%d', 1);
        assert(count == 1)
        assert(RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups >= 0);
        if( RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups == 0 )
            warning('RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups == 0');
        end
        for iIC = 1 : RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups
            [RduParam.OuterCups{iOC}.InnerCupTypes{iIC}, count] = fscanf(fid,'%s',1);
            assert(count == 1);
        end
    end

    [RduParam.NumOfCollimators, count] = fscanf(fid,'%d',1);
    assert(count == 1);
    assert(RduParam.NumOfCollimators > 0);

    RduParam.CollimatorSizes = cell(RduParam.NumOfCollimators,1);
    for iCmt = 1 : RduParam.NumOfCollimators 
        [RduParam.CollimatorSizes{iCmt}, count] = fscanf(fid, '%d', 1);
        assert(count == 1);
        assert(RduParam.CollimatorSizes{iCmt} > 0);
    end

    [RduParam.FocusRegionRadius, count] = fscanf(fid, '%g', 1);
    assert(count == 1);
    assert(RduParam.FocusRegionRadius > 0);

    [RduParam.FocusRegionZMax, count] = fscanf(fid, '%g', 1);
    assert(count == 1);

    [RduParam.FocusRegionZMin, count] = fscanf(fid, '%g', 1);
    assert(count == 1);
    assert(RduParam.FocusRegionZMax > RduParam.FocusRegionZMin);

    [RduParam.MinVel, count] = fscanf(fid, '%g', 3);
    assert(count == 3);
    assert(all(RduParam.MinVel < 0));
    [RduParam.MaxVel, count] = fscanf(fid, '%g', 3);
    assert(count == 3);
    assert(all(RduParam.MaxVel > 0));

    [RduParam.MinAccl, count] = fscanf(fid, '%g', 3);
    assert(count == 3);
    assert(all(RduParam.MinAccl < 0));
    [RduParam.MaxAccl, count] = fscanf(fid, '%g', 3);
    assert(count == 3);
    assert(all(RduParam.MaxAccl > 0));
    
    [RduParam.MinCollimatorSwitchTime, count] = fscanf(fid, '%g', 1);
    assert(count == 1);
    assert(RduParam.MinCollimatorSwitchTime >= 0);
       
    fclose(fid);
end
