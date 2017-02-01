%Load .rdu file
function [RduParam, PhantomParam, KddScalar] = CwLoadDotRdu(RduFilePath)
    assert(nargin == 4);
    
    fid = fopen(RduFilePath, 'rt', 'native', 'US-ASCII');
    if fid == -1
        error('fail to open file for read: %s', RduFilePath);
    end

    RduParam.RuType = fscanf(fid, '%d', 1);
    RduParam.NumOfOuterCups = fscanf(fid, '%d', 1);

    for iOC = 1 : RduParam.NumOfOuterCups
        RduParam.OuterCups{iOC}.OuterCupType = fscanf(fid, '%d', 1);
        RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups = fscanf(fid, '%d', 1);
        for iIC = 1 : RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups
            RduParam.OuterCups{iOC}.InnerCupTypes{iIC} = fscanf(fid, '%s', 1);
        end
    end

    RduParam.NumOfCollimators = fscanf(fid, '%d', 1);
    for iCmt = 1:RduParam.NumOfCollimators
        RduParam.CollimatorSizes{iCmt} = fscanf(fid, '%d', 1);
    end

    KddScalar = fscanf(fid, '%g', 1);  
    RduParam.FocusUpperRegionRadius = fscanf(fid, '%g', 1);
    RduParam.FocusUpperRegionHeight = fscanf(fid, '%g', 1);
    RduParam.FocusInnerCupSeparation = fscanf(fid, '%g', 1);
    RduParam.MinVel(1) = fscanf(fid, '%g', 1);
    RduParam.MinVel(2) = fscanf(fid, '%g', 1);
    RduParam.MinVel(3) = fscanf(fid, '%g', 1);
    RduParam.MaxVel(1) = fscanf(fid, '%g', 1);
    RduParam.MaxVel(2) = fscanf(fid, '%g', 1);
    RduParam.MaxVel(3) = fscanf(fid, '%g', 1);
    RduParam.MinAccl(1) = fscanf(fid, '%g', 1);
    RduParam.MinAccl(2) = fscanf(fid, '%g', 1);
    RduParam.MinAccl(3) = fscanf(fid, '%g', 1);
    RduParam.MaxAccl(1) = fscanf(fid, '%g', 1);
    RduParam.MaxAccl(2) = fscanf(fid, '%g', 1);
    RduParam.MaxAccl(3) = fscanf(fid, '%g', 1);
    RduParam.MinCollimatorSwitchTime = fscanf(fid, '%g', 1);
    PhantomParam.InnerCupType = fscanf(fid, '%s', 1);
    PhantomParam.HoleCenter(1) = fscanf(fid, '%g', 1);
    PhantomParam.HoleCenter(2) = fscanf(fid, '%g', 1);
    PhantomParam.HoleCenter(3) = fscanf(fid, '%g', 1);
    PhantomParam.HoleSize(1) = fscanf(fid, '%g', 1);
    PhantomParam.HoleSize(2) = fscanf(fid, '%g', 1);
    PhantomParam.HoleSize(3) = fscanf(fid, '%g', 1);

    fclose(fid);
end
