function [OcIcStrings, OcArray, IcArray, PtmParam, RduParam] = CwLoadOcIcList(RadiationUnitType)
    
    assert( nargin == 1 );
        
    %Load .rduparam file
    RduParamFile = sprintf('RadiationUnit\\In\\R%d.rduparam',RadiationUnitType);
    RduParam = CwLoadRduParam(RduParamFile);
    assert(RduParam.RuType == RadiationUnitType);
   
    %Load .ptmparam file
    PtmParamFile = sprintf('RadiationUnit\\In\\R%d.ptmparam',RadiationUnitType);
    PtmParam = CwLoadPhantomParam(PtmParamFile);
    assert(PtmParam.RuType == RadiationUnitType);

    %Build the string list
    OcIcStrings = cell(0);
    OcArray = cell(0);
    IcArray = cell(0);
    
    %add ordinary outer cups and inner cups
    for iOC = 1 : RduParam.NumOfOuterCups
        for iIC = 1 : RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups
            strentry = sprintf('%d %s', RduParam.OuterCups{iOC}.OuterCupType, ...
                RduParam.OuterCups{iOC}.InnerCupTypes{iIC});
            OcIcStrings = [ OcIcStrings;  strentry ];

            OcArray = [OcArray; RduParam.OuterCups{iOC}.OuterCupType];
            IcArray = [IcArray; RduParam.OuterCups{iOC}.InnerCupTypes{iIC}];
        end
    end
    
    %add the QA phantom
    OcArray = [PtmParam.OuterCupType; OcArray];
    IcArray = [PtmParam.InnerCupType; IcArray];
    OcIcStrings = [sprintf('%d %s', PtmParam.OuterCupType, PtmParam.InnerCupType); OcIcStrings];

end
