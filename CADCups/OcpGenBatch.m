% Same functionality as OcpGen, but without
% intermediate pics and text files

function  OcpGenBatch(RadiationUnitType, OuterCupType)

    OcpParamFilePath = sprintf('OuterCups\\In\\R%dO%d.ocpparam',RadiationUnitType,OuterCupType);
    OcpParam = CwLoadOcpParam(OcpParamFilePath);
    assert(OcpParam.rutype == RadiationUnitType);
    assert(OcpParam.octype == OuterCupType);

    % Save to .ocp format

    OcpFilePath = sprintf('OuterCups\\Out\\R%dO%d.ocp', RadiationUnitType, OuterCupType);
    CwSaveAsDotOcp(OcpFilePath, OcpParam);

end
