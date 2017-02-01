% Fields of structure KddParam
% (1) rutype 
% (2) octype
% (3) ictype
% (4) ziboc_kdd (inside bottom of the outer cup in Kdd Coord, in mm)
function KddParam = CwLoadKddParam(KddParamFilePath)
    assert(nargin == 1);
    
    %Load *.kddparam file
    fid = fopen(KddParamFilePath, 'rt', 'native', 'US-ASCII');
    if fid == -1
        error('fail to open file for read: %s', KddParamFilePath);
    end

    [KddParam.rutype, count] = fscanf(fid, '%d', 1);
    assert(count == 1);

    [KddParam.octype, count] = fscanf(fid, '%d', 1);
    assert(count == 1);

    [KddParam.ictype, count] = fscanf(fid, '%s', 1);
    assert(count == 1);

    [KddParam.ziboc_kdd, count] = fscanf(fid,'%g',1);
    assert(count == 1);
    
    fclose(fid);

end
