%structure S contain the following fields
% (1) xbnd, ybnd, zbnd (of size (nx+1,1), (ny+1,1), and (nz+1,1)), Kdd-Coord., unit: mm
% (2) D is of size (nx,ny,nz)
function S = cwLoadDot3ddose(Dot3ddoseFilePath)
    fid = fopen(Dot3ddoseFilePath,'rt', 'native', 'US-ASCII');
    if fid == -1
        error('fail to open file for read: %s', Dot3ddoseFilePath);
    end
    
    [nx, count] = fscanf(fid, '%d', 1);
    assert(count == 1);
    assert(nx > 0);
    
    [ny, count] = fscanf(fid, '%d', 1);
    assert(count == 1);
    assert(ny > 0);
    
    [nz, count] = fscanf(fid, '%d', 1);
    assert(count == 1);
    assert(nz > 0);

    [S.xbnd, count] = fscanf(fid, '%g', nx+1); %column vector
    assert(count == nx+1);
    S.xbnd = S.xbnd * 10.0; %convert unit from cm to mm
    
    [S.ybnd, count] = fscanf(fid, '%g', ny+1);
    assert(count == ny+1);
    S.ybnd = S.ybnd * 10.0; %convert unit from cm to mm
    
    [S.zbnd, count] = fscanf(fid, '%g', nz+1);
    assert(count == nz+1);
    S.zbnd = S.zbnd * 10.0; %convert unit from cm to mm
    
    [dose, count] = fscanf(fid, '%g', nx*ny*nz);
    assert(count == nx*ny*nz);
    S.D = reshape(dose, nx, ny, nz);
    fclose(fid);
end
