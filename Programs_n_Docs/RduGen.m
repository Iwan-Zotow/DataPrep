%Rev. 3/17/2011, Chao Wang
%   (1) Now use structures
%   (2) Add phantom data
function [RduParam, PtmParam] = RduGen(RadiationUnitType, KddScalar)
    
    assert( nargin == 2 );
        
    %Load .RduParam file
    RduParamFile = sprintf('RadiationUnit\\In\\R%d.rduparam',RadiationUnitType);
    RduParam = CwLoadRduParam(RduParamFile);
    assert(RduParam.RuType == RadiationUnitType);
   
    %Load .ptmparam file
    PhantomParamFile = sprintf('RadiationUnit\\In\\R%d.ptmparam',RadiationUnitType);
    PtmParam = CwLoadPhantomParam(PhantomParamFile);
    assert(PtmParam.RuType == RadiationUnitType);
    
    %Save it as .rdu file
    RduFile = sprintf('RadiationUnit\\Out\\R%d.rdu',RadiationUnitType);
    CwSaveAsDotRdu(RduFile, RduParam, PtmParam, KddScalar);
end

