%Convert .3ddose files to .d3d files
%XSymmetryFlag: 0 or 1
%Return Result structure with 
%(1) ShotSpot x,y,z in Kdd-Coord.
%(2) CollimatorType
%(3) D3dFileName
%(4) RefDose
%(5) ShotSpotDose
%(6) MaxDose
%(7) MinDose
%(8) Signature - OuterCupSig, InnerCupSig, CollimatorSize
function Result = KddConvert(RadiationUnitType, OuterCupType, InnerCupType, XSymmetryFlag, PtmParam)
    
    assert( nargin == 5 );
    
    %Load *.kddparam file
    KddParamFilePath = sprintf('Kdd_CupGeometry\\Out\\R%dO%dI%s.kddparam', ...
        RadiationUnitType, OuterCupType, InnerCupType);
    KddParam = CwLoadKddParam( KddParamFilePath );
    assert(KddParam.rutype == RadiationUnitType);
    assert(KddParam.octype == OuterCupType);
    assert(strcmp(KddParam.ictype, InnerCupType) == true);
    
    %Calc RefShotSample_kdd
    if OuterCupType == 0
        RefShotSample_kdd(:,1) = PtmParam.RefShotSample(:, 1);
        RefShotSample_kdd(:,2) = - PtmParam.RefShotSample(:, 2);
        RefShotSample_kdd(:,3) = PtmParam.UpperMargin4Phantom - PtmParam.RefShotSample(:, 3);
    else
        RefShotSample_kdd(:,1) = PtmParam.RefShotSample(:, 1);
        RefShotSample_kdd(:,2) = - PtmParam.RefShotSample(:, 2);
        RefShotSample_kdd(:,3) = PtmParam.UpperMargin4Cups - PtmParam.RefShotSample(:, 3);
    end
    
    %Convert each .3ddose to .d3d and store all conversion results
    FormatStr = sprintf('R%dO%dI%s_Y%%03dZ%%03dC%%03d', ...
                    RadiationUnitType, OuterCupType, InnerCupType);
    files = dir(sprintf('Kdd_Convert\\In\\R%dO%dI%s_*.3ddose', ...
                RadiationUnitType, OuterCupType, InnerCupType));
    Result = cell(length(files), 1);
    parfor (i = 1: length(files))
        P = sscanf(files(i).name, [FormatStr '.3ddose']);
        
        Result{i}.Dot3ddoseFileName = files(i).name;
        Result{i}.ShotSpotX = 0.0;      %in Kdd-Coord
        Result{i}.ShotSpotY = P(1);     %in Kdd-Coord
        Result{i}.ShotSpotZ = P(2);     %in Kdd-Coord
        Result{i}.CollimatorType = P(3);
        Result{i}.D3dFileName = sprintf([FormatStr '.d3d'], Result{i}.ShotSpotY, Result{i}.ShotSpotZ, Result{i}.CollimatorType );
        
        disp( sprintf('Shot Spot = (%g,%g) mm (kdd-Coord.)\n', Result{i}.ShotSpotY, Result{i}.ShotSpotZ) );
      
        [Result{i}.Signature, Result{i}.DoseRegionBox] = ...
            ConvertSingleFile3ddoseTod3d(...
                ['Kdd_Convert\In\'  Result{i}.Dot3ddoseFileName], ...
                ['Kdd_Convert\Out\' Result{i}.D3dFileName], ...
                XSymmetryFlag, ...
                KddParam, ...
                RefShotSample_kdd, ...
                [Result{i}.ShotSpotX Result{i}.ShotSpotY Result{i}.ShotSpotZ] ...
                );
    end
    
    %Generate .d3difo file (TPS use)
    DotD3difoFilePath = sprintf('Kdd_Convert\\Out\\R%dO%dI%s.d3difo', RadiationUnitType, OuterCupType, InnerCupType);
    CwSaveAsDotD3difo(DotD3difoFilePath, Result, KddParam);
    
    %Generate .d3dvrf file (data verification)
    DotD3dVrfFilePath = sprintf('Kdd_Convert\\Out\\R%dO%dI%s.d3dvrf', RadiationUnitType, OuterCupType, InnerCupType);
    CwSaveAsDotD3dVrf(DotD3dVrfFilePath, Result, KddParam);
    ...
end


function [Signature, DoseRegionBox] = ConvertSingleFile3ddoseTod3d(...
    Dot3ddoseFilePath, DotD3dFilePath, XSymmetryFlag, KddParam, RefShotSample_kdd, ShotSpot_kdd)

    cwDispTime(sprintf('Loading %s...\n', Dot3ddoseFilePath));
    S = CwLoadDot3ddose( Dot3ddoseFilePath);
    
    Signature = CwAnalyzeDot3ddose(S, ShotSpot_kdd, RefShotSample_kdd);
    
    %set up T
    T.xsym = XSymmetryFlag;
    T.ysym = 0;
    T.zsym = 0;
    
    T.xbnd = S.xbnd;
    T.ybnd = S.ybnd;
    T.zbnd = S.zbnd;
    %If x-symmetric, Apply 'fold' operation on x-directions
    if T.xsym ~= 0
        T.xbnd = cwfold(T.xbnd);
    end

    %build T.D
    if T.xsym == 0
        T.D = S.D;
    else
        T.D = cwsymavg(S.xbnd, S.D, T.xbnd);
    end

    %Convert to Outer Cup Coord.
    T.zbnd = T.zbnd - KddParam.ziboc_kdd;
    T.ybnd = T.ybnd - 0;
    T.xbnd = T.xbnd - 0;

	%Setup the dose region bounds
	if T.xsym == 0 
		DoseRegionBox.xmin = min( T.xbnd );
	else
		DoseRegionBox.xmin = - max( T.xbnd );
	end
	DoseRegionBox.xmax = max(T.xbnd);
	DoseRegionBox.ymin = min(T.ybnd);
	DoseRegionBox.ymax = max(T.ybnd);
	DoseRegionBox.zmin = min(T.zbnd);
	DoseRegionBox.zmax = max(T.zbnd);
		
    cwDispTime(sprintf('Saving results to %s...\n', DotD3dFilePath));
    CwSaveAsDotD3d(DotD3dFilePath, T); 
end


function H = cwsymavg(xbnd, F, xbnd1)
    G1 = cwavg(xbnd, F, xbnd1);
    G2 = cwavg(flipdim(-xbnd,1), flipdim(F,1), xbnd1);
    H = 0.5 * (G1 + G2);
end

%finding the avarage values over a voxel grid for a function
%xbnd : xboundaries that defines the voxels
% f: function value for the voxel
%xbnd1 : new xboundaries
% f1: average value for the new voxel
% f(x) = \sum_{i=1}^{N} ( f_i * ( u(x - xbnd(i) ) - u(x - xbnd(i+1)) )
function G = cwavg(xbnd, F, xbnd1)
    assert(length(xbnd) == size(F, 1) + 1);
    assert(issorted(xbnd) == 1);
    assert(issorted(xbnd1) == 1);
    
    G = zeros(length(xbnd1)-1, size(F,2), size(F,3));
    
    for i = 1 : (length(xbnd1) - 1)
        a = xbnd1(i);
        b = xbnd1(i+1);
        c = max(a, xbnd(1));
        d = min(b, xbnd(end));
        if c < d
            pc = min( length(xbnd)-1, int32( floor( interp1(xbnd, 1:length(xbnd), c, 'linear', NaN) ) ) );
            pd = min( length(xbnd)-1, int32( floor( interp1(xbnd, 1:length(xbnd), d, 'linear', NaN) ) ) );
            if pc == pd
                G(i,:,:) = (d-c) * F(pc,:,:);
            else
                G(i,:,:) = (xbnd(pc) + 1 - c) * F(pc,:,:) + (d - xbnd(pd)) * F(pd,:,:) ;
                for p = (pc+1) : (pd-1)
                    G(i,:,:) = G(i,:,:) + (xbnd(p+1) - xbnd(p)) * F(p,:,:);
                end
            end
            G(i,:,:) = G(i,:,:) / (b-a);
        end
    end
end


function sx = cwfold(x)
    assert(issorted(x)==1);
    assert(length(x) >= 2);
    
    mingap = min( x(2:end) - x(1:(end-1)) );
    threshold = mingap / 3;
    
    y = x;
    
    q = max(y(y<=0));
    y(y<q) = - y(y<q);
    y = sort(y);
    
    sx = y(1);
    for i=2:length(y)
        if y(i) - sx(end) <= threshold
            sx(end) = 0.5 * (sx(end) + y(i));
        else
            sx = [sx; y(i)];
        end
    end
end

function cwDispTime(str)
    c = fix(clock);
    disp(sprintf('%02d:%02d:%02d %s', c(4),c(5),c(6),str));
end


