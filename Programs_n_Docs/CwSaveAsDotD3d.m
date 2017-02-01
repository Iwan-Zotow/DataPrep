% structure T
%(1) xsym, ysym, zsym
%(2) xbnd, ybnd, zbnd (Outer Cup Coord., Unit: mm)
%(3) D(X,Y,Z)

function CwSaveAsDotD3d(DotD3dFilePath, T)
    assert(nargin == 2)
    
    fid = fopen(DotD3dFilePath, 'w','ieee-le'); % (binary mode, little-endian)
    if fid == -1
        error('fail to open file for write: %s', DotD3dFilePath);    
    end
    
    assert( T.xsym == 0 || T.xsym == 1);
    assert( T.ysym == 0 || T.ysym == 1);
    assert( T.zsym == 0 || T.zsym == 1);
    
    fwrite(fid, T.xsym, 'int32');
    fwrite(fid, T.ysym, 'int32');
    fwrite(fid, T.zsym, 'int32');
    fwrite(fid, length(T.xbnd)-1, 'int32');
    fwrite(fid, length(T.ybnd)-1, 'int32');
    fwrite(fid, length(T.zbnd)-1, 'int32');
    fwrite(fid, T.xbnd, 'float32');
    fwrite(fid, T.ybnd, 'float32');
    fwrite(fid, T.zbnd, 'float32');
    V = permute(T.D, [3, 2, 1]);    %D(X,Y,Z) --> V(Z,Y,X)
    fwrite(fid, V, 'float32');
    
    fclose(fid);
end
