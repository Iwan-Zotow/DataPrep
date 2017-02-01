function info = CwLoadDotD3dVrf( DotD3dVrfFilePath)
   
    fid = fopen(DotD3dVrfFilePath, 'rt', 'native', 'US-ASCII');
    if fid == -1
        error('fail to open file for read: %s', DotD3dVrfFilePath);
    end
    
    info.RuType = fscanf(fid, '%d', 1);
    info.OcType = fscanf(fid, '%d', 1);
    info.IcType = fscanf(fid, '%s', 1);
    
    NumOfKernels = fscanf(fid, '%d', 1);

    for i = 1: NumOfKernels 
        info.Dot3ddoseFileName{i} = fscanf(fid, '%s', 1);
        info.CollimatorType(i) = fscanf(fid, '%d', 1);
        info.ShotSpotX(i) = fscanf(fid, '%g', 1);
        info.ShotSpotY(i) = fscanf(fid, '%g', 1);
        info.ShotSpotZ(i) = fscanf(fid, '%g', 1);    %kdd-Coord
        info.OuterCupSig(i) = fscanf(fid, '%g', 1);   
        info.InnerCupSig(i) = fscanf(fid, '%g', 1);   
        info.CollimatorSize(i) = fscanf(fid, '%g', 1);   
        info.RefDose(i) = fscanf(fid, '%g', 1);   
        info.ShotSpotDose(i) = fscanf(fid, '%g', 1);   
        info.MinDose(i) = fscanf(fid, '%g', 1);   
        info.MaxDoseIn(i) = fscanf(fid, '%g', 1);   
        info.MaxDoseOut(i) = fscanf(fid, '%g', 1);   
        info.MaxGradientIn(i) = fscanf(fid, '%g', 1);   
        info.MaxGradientOut(i) = fscanf(fid, '%g', 1);   
    end

    fclose(fid);
end

