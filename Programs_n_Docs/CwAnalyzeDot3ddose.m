function Signature = CwAnalyzeDot3ddose(S, ShotSpot_kdd, RefShotSample_kdd)
    
    Signature.RefDose = ...
        CalcAverageDose(S, RefShotSample_kdd);
    
    Signature.ShotSpotDose = ...
        CalcAverageDose(S, ShotSpot_kdd);
    
    Signature.MinDose = min(min(min(S.D)));

    [Signature.OuterCupSig, Signature.InnerCupSig] = ...
        CalcOuterAndInnerCupSignatures(S);
    
    Signature.CollimatorSize = ...
        EstimateCollimatorSize(S, ShotSpot_kdd);

    [Signature.MaxDoseIn, Signature.MaxDoseOut, Signature.MaxGradientIn, Signature.MaxGradientOut] = ...
        CalcMaxDoseAndInteriorGradient(S, ShotSpot_kdd, Signature.CollimatorSize) ;  
end

%average dose of the specified sample positions
function Dose = CalcAverageDose(S, ShotSample_kdd)
    nx = length(S.xbnd) - 1;
    ny = length(S.ybnd) - 1;
    nz = length(S.zbnd) - 1;
    
    m = size(ShotSample_kdd, 1);
    assert( m > 0);
    d = zeros(m, 1);
    for i = 1:m
        %Calculate the dose at shot spot
        %ix,iy,iz (from 1)
        ix = int32( floor( interp1(S.xbnd, 0:nx, ShotSample_kdd(i,1), 'linear', NaN) ) ) + 1 ;
        iy = int32( floor( interp1(S.ybnd, 0:ny, ShotSample_kdd(i,2), 'linear', NaN) ) ) + 1 ;
        iz = int32( floor( interp1(S.zbnd, 0:nz, ShotSample_kdd(i,3), 'linear', NaN) ) ) + 1 ;
        d(i) = S.D(ix,iy,iz);
    end
   
    Dose = mean(d);
end


function [OuterCupSig, InnerCupSig] = CalcOuterAndInnerCupSignatures(S)
    
    Threshold = 0.00001;
    
    MaxDose = max(max(max(S.D)));
    if MaxDose == 0 
        error('MaxDose == 0');
    end
        
    A =  (S.D >= (Threshold * MaxDose));
    
    B =   A;
    for k = 1:size(B,3)
        B(:,:,k) = imfill(B(:,:,k), 'holes');
    end
    
    ind = find( B == 1 );
    [I, J, K] = ind2sub( size(B), ind );
    DX = S.xbnd(I+1) - S.xbnd(I);
    DY = S.ybnd(J+1) - S.ybnd(J);
    DZ = S.zbnd(K+1) - S.zbnd(K);
    OuterCupSig = sum(DX .* DY .* DZ);
    
    ind = find( A & B );
    [I, J, K] = ind2sub( size(B), ind );
    DX = S.xbnd(I+1) - S.xbnd(I);
    DY = S.ybnd(J+1) - S.ybnd(J);
    DZ = S.zbnd(K+1) - S.zbnd(K);
    InnerCupSig = sum(DX .* DY .* DZ);
end

function CollimatorSize = EstimateCollimatorSize(S, ShotSpot_kdd)
 
    Threshold1 = 0.50;
    Threshold2 = 0.60;
    
    MaxDose = max(max(max(S.D)));
    if MaxDose == 0 
        error('MaxDose == 0');
    end    
    
    ind = find( (S.D >= (Threshold1 * MaxDose)) & (S.D <= (Threshold2 * MaxDose)) );
    [I, J, K] = ind2sub( size(S.D), ind );
    
    X = 0.5 * (S.xbnd(I) + S.xbnd(I+1)) - ShotSpot_kdd(1) ;
    Y = 0.5 * (S.ybnd(J) + S.ybnd(J+1)) - ShotSpot_kdd(2) ;
    Z = 0.5 * (S.zbnd(K) + S.zbnd(K+1)) - ShotSpot_kdd(3);
    
    CollimatorSize = 2.0 * median(sqrt(X.*X + Y.*Y + Z.*Z));
  
end

function [MaxDoseIn, MaxDoseOut, MaxGradientIn, MaxGradientOut] = CalcMaxDoseAndInteriorGradient(S, ShotSpot_kdd, CollimatorSize)
    
    Threshold1 = 0.01;
    Threshold2 = 2.0;
    Radius = 5.0; %mm
    
    D = S.D / max(max(max(S.D)));
    
    CX = 0.5 * (S.xbnd(1:(end-1)) + S.xbnd(2:end)) ;
    CY = 0.5 * (S.ybnd(1:(end-1)) + S.ybnd(2:end)) ;
    CZ = 0.5 * (S.zbnd(1:(end-1)) + S.zbnd(2:end)) ;
    
    [GY, GX, GZ] = gradient(D, CY, CX, CZ);
    G = sqrt(GX.*GX + GY.*GY + GZ.*GZ);
    
    
    Sphere = BuildSphere(S, Radius);
    InteriorRegion = convn( D <= Threshold1, Sphere, 'same') == 0 ;
    
    [X, Y, Z] = ndgrid( CX - ShotSpot_kdd(1), CY - ShotSpot_kdd(2), CZ - ShotSpot_kdd(3));
    T = sqrt(X.*X + Y.*Y + Z.*Z) <= 0.5 * Threshold2 * CollimatorSize;
   
    MaxDoseIn = max(max(max(S.D( T ))));
    MaxDoseOut = max(max(max(S.D( ~T ))));
    MaxGradientIn  = max(max(max(G( InteriorRegion & T ))));
    MaxGradientOut = max(max(max(G( InteriorRegion & (~T) ))));
end


function Sphere = BuildSphere(S, Radius)
    dx = mean( S.xbnd(2:end) - S.xbnd(1:(end-1)) );
    dy = mean( S.ybnd(2:end) - S.ybnd(1:(end-1)) );
    dz = mean( S.zbnd(2:end) - S.zbnd(1:(end-1)) );
    
    nx = ceil(2*Radius/dx);
    x = ((-nx+1):2:(nx-1)) * 0.5 * dx;
    ny = ceil(2*Radius/dy);
    y = ((-ny+1):2:(ny-1)) * 0.5 * dy;
    nz = ceil(2*Radius/dz);
    z = ((-nz+1):2:(nz-1)) * 0.5 * dz;
    
    [X, Y, Z] = ndgrid(x, y, z);
    
    Sphere = (sqrt(X.*X + Y.*Y + Z.*Z) <= Radius);
  
end


