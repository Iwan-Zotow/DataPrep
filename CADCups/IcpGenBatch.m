% just processing, no fancy graphs
function  IcpGenBatch(RadiationUnitType, OuterCupType, InnerCupType)

    assert( nargin == 3 );

    %Load .icpparam file
    IcpParamFilePath = sprintf('InnerCups\\In\\R%dO%dI%s.icpparam', RadiationUnitType, OuterCupType, InnerCupType);
    IcpParam = CwLoadIcpParam(IcpParamFilePath);
    assert(IcpParam.rutype == RadiationUnitType);
    assert(IcpParam.octype == OuterCupType);
    assert(strcmp(IcpParam.ictype, InnerCupType) == true);

    %Save to .icp format
    IcpFilePath = sprintf('InnerCups\\Out\\R%dO%dI%s.icp', RadiationUnitType, OuterCupType, InnerCupType);
    CwSaveAsDotIcp(IcpFilePath, IcpParam)

end
