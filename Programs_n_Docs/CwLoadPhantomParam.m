%Created by Chao Wang, 3/17/2011
%Load .PtmParam to a structure 'PtmParam'
%(1) RuType
%(2) OuterCupType
%(3) InnerCupType
%(4) HoleCenter (3-elem array)
%(5) HoleSize (3-elem array)
%(6) RefShotCollimatorSize
%(7) RefShotPosition
%(8) RefShotSample (2d array)
%(9) UpperMargin4Phantom
%(10) UpperMargin4Cups

function PtmParam = CwLoadPhantomParam(PtmParamFilePath)
   
    assert( nargin == 1 );
    
    fid = fopen(PtmParamFilePath, 'rt', 'native', 'US-ASCII');
    if fid == -1
        error('fail to open file for read: %s', PtmParamFilePath);
    end

    [PtmParam.RuType, count] = fscanf(fid, '%d', 1);
    assert(count == 1);

    [PtmParam.OuterCupType, count] = fscanf(fid, '%d', 1);
    assert(count == 1);
    assert(PtmParam.OuterCupType == 0);
    
    [PtmParam.InnerCupType, count] = fscanf(fid, '%s', 1);
    assert(count == 1);
    
    [PtmParam.HoleCenter, count] = fscanf(fid, '%g', 3);
    assert(count == 3);
    
    [PtmParam.HoleSize, count] = fscanf(fid, '%g', 3);
    assert(count == 3);
    assert(all(PtmParam.HoleSize > 0));
    
    [PtmParam.RefShotCollimatorSize, count] = fscanf(fid, '%d', 1);
    assert(count == 1);
    assert( PtmParam.RefShotCollimatorSize > 0 );
    
    [PtmParam.RefShotPosition, count] = fscanf(fid, '%g', 3);
    assert(count == 3);
    
    [nsamples, count] = fscanf(fid, '%d', 1);
    assert(count == 1);
    assert(nsamples > 0);
    
    PtmParam.RefShotSample = zeros(nsamples, 3);
    for isample = 1:nsamples
        [sample, count] = fscanf(fid, '%g', 3);
        assert(count == 3);
        PtmParam.RefShotSample(isample, 1) = sample(1);
        PtmParam.RefShotSample(isample, 2) = sample(2);
        PtmParam.RefShotSample(isample, 3) = sample(3);
    end
    
    [PtmParam.UpperMargin4Phantom, count] = fscanf(fid, '%g', 1);
    assert(count == 1);

    [PtmParam.UpperMargin4Cups, count] = fscanf(fid, '%g', 1);
    assert(count == 1);
    
    fclose(fid);
end

