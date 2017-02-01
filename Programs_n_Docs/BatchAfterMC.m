%The BatchAfterMC code performs all required work after the Monte Carlo 
%simulation:
%(1) Convert the .3ddose files to .d3d files. User will select the outer
%cup and inner cup combinations whose kernel dose files will to be
%converted.
%(2) Move the converted .d3d files to the plan resource directory created
%earlier in BatchBeforeMC

function BatchAfterMC(RadiationUnitType)
    assert( nargin == 1 );
    choice = questdlg('Please select the type of tasks to be performed.', ...
                'Batch Tasks After MC', ...
                'Conversion','Verification','Do Nothing','Do Nothing');
    switch choice
        case 'Conversion' 
            tasktype = 1;
        case 'Verification'
            tasktype = 2;
        case 'Nothing'
            tasktype = 0;
    end
    
    if tasktype > 0
        [OcIcStrings, OcArray, IcArray, PtmParam] = CwLoadOcIcList(RadiationUnitType);
        %GUI selection
        [selection, ok] = listdlg('PromptString','Select the (Outercup, InnerCup) pairs',...
                        'Name', sprintf('RU %d', RadiationUnitType),...
                        'SelectionMode','multiple',...
                        'InitialValue', [],...
                        'ListString',OcIcStrings);
        if ok 
            if tasktype == 1
                if matlabpool('size') == 0
                    matlabpool('open', 4);
                end
            end
            
            for k = 1: length(selection)
                choice = selection(k);
                switch tasktype 
                    case 1
                        Process_R_O_I_Convert(RadiationUnitType, OcArray{choice}, IcArray{choice}, PtmParam);
                    case 2
                        Process_R_O_I_Verify(RadiationUnitType, OcArray{choice}, IcArray{choice});
                end
            end
            
            if tasktype == 1
                matlabpool('close');
            end
            
            disp('Batch processing completed');
        end
    end
end

function Process_R_O_I_Convert(RadiationUnitType, OuterCupType, InnerCupType, PtmParam)
    %%debug use
    disp( sprintf('Process_R_O_I %d %d %s ...', RadiationUnitType, OuterCupType, InnerCupType ) );
      
    destinationpath = sprintf('..\\FinalResults\\PlanEngineResource\\R%d\\Kdd',RadiationUnitType);
    if ~exist(destinationpath)
        error(['Path not exist: ' destinationpath]);
    end
    
    Result = KddConvert(RadiationUnitType, OuterCupType, InnerCupType, 1, PtmParam);
        % 1: x-symmetric

    sourcefilename = sprintf('Kdd_Convert\\Out\\R%dO%dI%s*.*', ...
        RadiationUnitType, OuterCupType, InnerCupType)

    [s,mess,messid] = movefile(sourcefilename, destinationpath);
    if s == 0
        error(['movefile error:' mess]);
    end
   
    if OuterCupType == 0
        if strcmp(InnerCupType, PtmParam.InnerCupType) == true
            %convert from Couch Coord. to Kdd-Coord
            xkdd = PtmParam.RefShotPosition(1);
            ykdd = - PtmParam.RefShotPosition(2);
            zkdd = PtmParam.UpperMargin4Phantom - PtmParam.RefShotPosition(3);
            
            d = zeros([length(Result), 1]);
            for i = 1: length(Result)
                Diff = [ Result{i}.ShotSpotX - xkdd; 
                         Result{i}.ShotSpotY - ykdd;  
                         Result{i}.ShotSpotZ - zkdd;
                         Result{i}.CollimatorType - PtmParam.RefShotCollimatorSize;
                         ];
                d(i) = norm(Diff, 2);
            end
           
            [dmin, imin] = min(d);
            assert(dmin < 1e-3 );
            
            KddScalar = 1.0 / Result{imin}.Signature.RefDose;
            
            %Update .rdu files
            RduGen(RadiationUnitType, KddScalar);
            RUdirname = sprintf('R%d', RadiationUnitType);
            RduFile = sprintf('RadiationUnit\\Out\\R%d.rdu', RadiationUnitType);
            RUdirpath = ['../FinalResults/PlanEngineResource/' RUdirname];
            copyfile(RduFile, RUdirpath);

        end
    end
end

function Process_R_O_I_Verify(RadiationUnitType, OuterCupType, InnerCupType)

    DotD3dVrfFilePath = sprintf('..\\FinalResults\\PlanEngineResource\\R%d\\Kdd\\R%dO%dI%s.d3dvrf',...
                        RadiationUnitType,RadiationUnitType,OuterCupType,InnerCupType);
    info = CwLoadDotD3dVrf( DotD3dVrfFilePath);
    
    assert(info.RuType == RadiationUnitType);
    assert(info.OcType == OuterCupType);
    assert( strcmp(info.IcType, InnerCupType) );
    
    LegendStr = [];
    if OuterCupType~=0
        openfig( sprintf('Kdd_CupGeometry\\Out\\R%dO%dI%s_Kdd.fig',RadiationUnitType,OuterCupType, InnerCupType) );
        LegendStr{1} = 'inner cup';
        LegendStr{2} = 'outer cup inside wall';
        LegendStr{3} = 'outer cup outside wall';
    else
        X = info.ShotSpotZ;
        Y = info.ShotSpotY;
        figure;
        axis([ min(X), max(X) + 0.5*(max(X)-min(X)), min(Y), max(Y) + 0.5*(max(Y)-min(Y)) ] );
        hold;
    end
    
    %Number of Collimators
    Coll = unique(info.CollimatorType);
    if length(Coll) > 2 
        error('More than two types of collimators');
    end
    
    
    %Plot Shots
    for k = 1: length(Coll)
        I = (info.CollimatorType == Coll(k));
        X = info.ShotSpotZ(I);
        Y = info.ShotSpotY(I);
        if size(unique([X' Y'], 'rows'), 1) ~= length(X) 
            error('duplicated shots found');
        end
        plot(X, Y, 'ko', 'MarkerSize', Coll(k)/2);
        LegendStr{ length(LegendStr) + 1} = ['Coll-' int2str(Coll(k)) 'mm Shots'];
    end
    
    %Outer Cup Signature
    [ind, maxreloffset] = DetectOutlier(info.OuterCupSig);
    plot(info.ShotSpotZ(ind), info.ShotSpotY(ind), 'r+', 'LineWidth', 2, 'MarkerSize', 10);
    LegendStr{ length(LegendStr) + 1} = sprintf('OuterCupSig max offset: %.3g\\%%', maxreloffset*100.0);
    
    %Inner Cup Signature
    [ind, maxreloffset] = DetectOutlier(info.InnerCupSig);
    plot(info.ShotSpotZ(ind), info.ShotSpotY(ind), 'rx', 'LineWidth', 2, 'MarkerSize', 10);
    LegendStr{ length(LegendStr) + 1} = sprintf('InnerCupSig max offset: %.3g\\%%', maxreloffset*100.0);
    
    ColorSpecifier = ['g', 'b'];
    %50%-dose line
    for k = 1: length(Coll)
        I = (info.CollimatorType == Coll(k));
        [ind, maxreloffset] = DetectOutlier(info.CollimatorSize(I));
        plot(info.ShotSpotZ(ind), info.ShotSpotY(ind), [ColorSpecifier(k) 'v'], 'LineWidth', 2, 'MarkerSize', 10);
        LegendStr{ length(LegendStr) + 1} = [sprintf('Coll-%d 50\\%%-dose D=%.3gmm', Coll(k), mean(info.CollimatorSize(I))), ...
                                             sprintf('$\\pm$%.3g\\%%', maxreloffset*100.0)];
    end
    
    %min dose
    if max(abs(info.MinDose)) ~= 0 
        error('min dose ~= 0') 
    end;

    
    %max gradient outside of shot
    for k = 1: length(Coll)
        I = (info.CollimatorType == Coll(k));
        [maxgrad, ind] = max(info.MaxGradientOut(I));
        plot(info.ShotSpotZ(ind), info.ShotSpotY(ind), [ColorSpecifier(k) '<'], 'LineWidth', 2, 'MarkerSize', 10);
        LegendStr{ length(LegendStr) + 1} = sprintf('Coll-%d MaxGradientOut=%.3g', Coll(k), maxgrad);
    end

    h = legend(LegendStr);
    set(h, 'Interpreter', 'latex');
    title(sprintf('RadiationUnit %d / OuterCup %d / InnerCup %s : General Information', RadiationUnitType,OuterCupType,InnerCupType));
    set(gcf, 'Position', get(0,'Screensize'));
    pause(1.0);    
    saveas(gcf, sprintf('VerificationReports\\R%dO%dI%s_General.emf',RadiationUnitType,OuterCupType,InnerCupType));
    close(gcf);
    
    
    %shot spot dose
    for k = 1: length(Coll)
        LegendStr = [];
        if OuterCupType~=0
            openfig( sprintf('Kdd_CupGeometry\\Out\\R%dO%dI%s_Kdd.fig',RadiationUnitType,OuterCupType, InnerCupType) );
            LegendStr{1} = 'inner cup';
            LegendStr{2} = 'outer cup inside wall';
            LegendStr{3} = 'outer cup outside wall';
        end
        I = (info.CollimatorType == Coll(k));
        X = info.ShotSpotZ(I);
        Y = info.ShotSpotY(I);
        trisurf( delaunay(X,Y), X, Y, info.ShotSpotDose(I) ./ max(info.MaxDoseIn(I), info.MaxDoseOut(I)) );
        h = legend(LegendStr);
        colormap('jet');
        colorbar;
        title(sprintf('RadiationUnit %d / OuterCup %d / InnerCup %s / Collimator %d : Shot Spot Dose normalized to MaxDose', RadiationUnitType,OuterCupType,InnerCupType,Coll(k)));
        view(2);
        set(gcf, 'Position', get(0,'Screensize'));
        pause(1.0);            
        saveas(gcf, sprintf('VerificationReports\\R%dO%dI%s_ShotSpotDoseC%d.emf',RadiationUnitType,OuterCupType,InnerCupType,Coll(k)));
        close(gcf);
    end
    
    
    %max dose
    if ~all(info.MaxDoseIn > info.MaxDoseOut) 
        error('~all(info.MaxDoseIn > info.MaxDoseOut) ');
    end
    for k = 1: length(Coll)
        LegendStr = [];
        if OuterCupType~=0
            openfig( sprintf('Kdd_CupGeometry\\Out\\R%dO%dI%s_Kdd.fig',RadiationUnitType,OuterCupType, InnerCupType) );
            LegendStr{1} = 'inner cup';
            LegendStr{2} = 'outer cup inside wall';
            LegendStr{3} = 'outer cup outside wall';
        end
        I = (info.CollimatorType == Coll(k));
        X = info.ShotSpotZ(I);
        Y = info.ShotSpotY(I);
        trisurf( delaunay(X,Y), X, Y, info.MaxDoseIn(I) );
        h = legend(LegendStr);
        colormap('jet');
        colorbar;
        title(sprintf('RadiationUnit %d / OuterCup %d / InnerCup %s / Collimator %d : MaxDose', RadiationUnitType,OuterCupType,InnerCupType,Coll(k)));
        view(2);
        set(gcf, 'Position', get(0,'Screensize'));
        pause(1.0);            
        saveas(gcf, sprintf('VerificationReports\\R%dO%dI%s_MaxDoseC%d.emf',RadiationUnitType,OuterCupType,InnerCupType,Coll(k)));
        close(gcf);
    end

    %max gradient
    if ~all(info.MaxGradientIn > info.MaxGradientOut) 
        error('~all(info.MaxGradientIn > info.MaxGradientOut) ');
    end
    for k = 1: length(Coll)
        LegendStr = [];
        if OuterCupType~=0
            openfig( sprintf('Kdd_CupGeometry\\Out\\R%dO%dI%s_Kdd.fig',RadiationUnitType,OuterCupType, InnerCupType) );
            LegendStr{1} = 'inner cup';
            LegendStr{2} = 'outer cup inside wall';
            LegendStr{3} = 'outer cup outside wall';
        end
        I = (info.CollimatorType == Coll(k));
        X = info.ShotSpotZ(I);
        Y = info.ShotSpotY(I);
        trisurf( delaunay(X,Y), X, Y, info.MaxGradientIn(I) );
        h = legend(LegendStr);
        colormap('jet');
        colorbar;
        title(sprintf('RadiationUnit %d / OuterCup %d / InnerCup %s / Collimator %d : MaxGradient normalized to MaxDose (mm^{-1})', RadiationUnitType,OuterCupType,InnerCupType,Coll(k)));
        view(2);
        set(gcf, 'Position', get(0,'Screensize'));
        pause(1.0);            
        saveas(gcf, sprintf('VerificationReports\\R%dO%dI%s_MaxGradientC%d.emf',RadiationUnitType,OuterCupType,InnerCupType,Coll(k)));
        close(gcf);
    end

end

function [index, maxreloffset] = DetectOutlier(x)
   [maxreloffset, index] =  max(abs( x/mean(x) - 1))
end
