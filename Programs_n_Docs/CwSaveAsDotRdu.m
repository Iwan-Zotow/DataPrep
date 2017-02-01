%Save it as .rdu file
function CwSaveAsDotRdu(RduFilePath, RduParam, PhantomParam, KddScalar)
    assert(nargin == 4);
    
    fid = fopen(RduFilePath, 'wt', 'native', 'US-ASCII');
    if fid == -1
        error('fail to open file for write: %s', RduFilePath);
    end

    fprintf(fid, '%d\n', RduParam.RuType);
    fprintf(fid, '%d\n', RduParam.NumOfOuterCups);

    for iOC = 1 : RduParam.NumOfOuterCups
        fprintf(fid, '%d ', RduParam.OuterCups{iOC}.OuterCupType);
        fprintf(fid, '%d ', RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups);
        for iIC = 1 : RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups
            fprintf(fid, '%s ', RduParam.OuterCups{iOC}.InnerCupTypes{iIC});
        end
        fprintf(fid, '\n');
    end

    fprintf(fid, '%d ', RduParam.NumOfCollimators);
    for iCmt = 1:RduParam.NumOfCollimators
        fprintf(fid, '%d ', RduParam.CollimatorSizes{iCmt});
    end
    fprintf(fid, '\n');

    fprintf(fid, '%g\n', KddScalar);  
    fprintf(fid, '%g\n', RduParam.FocusRegionRadius);
    fprintf(fid, '%g\n', RduParam.FocusRegionZMax);
    fprintf(fid, '%g\n', RduParam.FocusRegionZMin);
    fprintf(fid, '%g %g %g\n', RduParam.MinVel(1), RduParam.MinVel(2), RduParam.MinVel(3));
    fprintf(fid, '%g %g %g\n', RduParam.MaxVel(1), RduParam.MaxVel(2), RduParam.MaxVel(3));
    fprintf(fid, '%g %g %g\n', RduParam.MinAccl(1), RduParam.MinAccl(2), RduParam.MinAccl(3));
    fprintf(fid, '%g %g %g\n', RduParam.MaxAccl(1), RduParam.MaxAccl(2), RduParam.MaxAccl(3));
    fprintf(fid, '%g\n', RduParam.MinCollimatorSwitchTime);
    
    fprintf(fid, '%s\n', PhantomParam.InnerCupType);
    fprintf(fid, '%g %g %g\n', PhantomParam.HoleCenter(1), ...
        PhantomParam.HoleCenter(2), PhantomParam.HoleCenter(3));
    fprintf(fid, '%g %g %g\n', PhantomParam.HoleSize(1), ...
        PhantomParam.HoleSize(2), PhantomParam.HoleSize(3));
    
    fclose(fid);
end
