%The BatchBeforeMC code performs all required work before the Monte Carlo 
%simulation:
%(1) Generate the .rdu file from the .rduparam file.
%(2) Check for existence of all .ocpparam and .icpparam files referenced in 
%    the .rdu file
%(3) For each outer cup referenced in the .rdu file, do
%       (2.1) Generate the .ocp file and related
%       (2.2) For each associated inner cup referenced in the .rdu file.
%               (2.2.1) Generate the .icp file
%               (2.2.1) Generate files describing the cup geometry (to be
%               used by the Monte Carlo simulation.
%(4) Create the plan resource directory structure under 'R%d\', and copy
%   all .rdu, .icp, .ocp files there.
%(5) Create phantom related data

function BatchBeforeMC(RadiationUnitType)

assert( nargin == 1 );

[RduParam, PtmParam] = RduGen(RadiationUnitType, 0.0);

%Verify existence of dependent files
for iOC = 1 : RduParam.NumOfOuterCups
    %Outer cup
    OcpParamFilePath = sprintf('OuterCups\\In\\R%dO%d.ocpparam', ...
                        RduParam.RuType, ...
                        RduParam.OuterCups{iOC}.OuterCupType );
    if ~exist(OcpParamFilePath)
        error('%s not exsits', OcpParamFilePath);
    end
    
    for iIC = 1 : RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups
        %Inner cup 
        IcpParamFilePath = sprintf('InnerCups\\In\\R%dO%dI%s.icpparam', ...
                            RduParam.RuType, ...
                            RduParam.OuterCups{iOC}.OuterCupType, ...
                            RduParam.OuterCups{iOC}.InnerCupTypes{iIC});
        if ~exist(IcpParamFilePath)
            error('%s not exsits', IcpParamFilePath);
        end
    end
end

%Create plan resource directory structure
RUdirname = sprintf('R%d', RduParam.RuType);
[s, mess, messid] = mkdir('../FinalResults/PlanEngineResource', RUdirname);
if s ~= 1
    error(['Unable to create directory ' RUdirname]);      
elseif length(messid) ~= 0
    error(['Directory already exists:' RUdirname]);      
end

RduFile = sprintf('RadiationUnit\\Out\\R%d.rdu', RduParam.RuType);
RUdirpath = ['../FinalResults/PlanEngineResource/' RUdirname];
copyfile(RduFile, RUdirpath);
mkdir(RUdirpath, 'Cup');
mkdir(RUdirpath, 'Kdd');

%Second pass
for iOC = 1 : RduParam.NumOfOuterCups
    
    %Outer cup
    disp(['Processing outer cup '  int2str(RduParam.OuterCups{iOC}.OuterCupType) '...']);
    OcpGen(RduParam.RuType, RduParam.OuterCups{iOC}.OuterCupType);
    
    OcpFilePath = sprintf('OuterCups\\Out\\R%dO%d.ocp', ...
        RduParam.RuType, RduParam.OuterCups{iOC}.OuterCupType);
    copyfile(OcpFilePath, [RUdirpath '/Cup']);
    
    for iIC = 1 : RduParam.OuterCups{iOC}.NumOfAssociatedInnerCups
        %Inner cup 
        disp(['Processing inner cup '  RduParam.OuterCups{iOC}.InnerCupTypes{iIC} '...']);
        IcpGen(RduParam.RuType, RduParam.OuterCups{iOC}.OuterCupType, ...
            RduParam.OuterCups{iOC}.InnerCupTypes{iIC});
        IcpFilePath = sprintf('InnerCups\\Out\\R%dO%dI%s.icp', ...
                        RduParam.RuType, ...
                        RduParam.OuterCups{iOC}.OuterCupType, ...
                        RduParam.OuterCups{iOC}.InnerCupTypes{iIC} );
        copyfile(IcpFilePath, [RUdirpath '/Cup']);
        
        %create geometry files
        KddCupsGeoGen(RduParam.RuType, ...
            RduParam.OuterCups{iOC}.OuterCupType, ...
            RduParam.OuterCups{iOC}.InnerCupTypes{iIC},...
            PtmParam.UpperMargin4Cups);
    end
end

%Phantom related
KddCupsGeoGen(RduParam.RuType, ...
    PtmParam.OuterCupType, ...
    PtmParam.InnerCupType,...
    PtmParam.UpperMargin4Phantom);

end

