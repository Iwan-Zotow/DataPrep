%Be sure to map X, Y, Z correctly
%(1)X+, Y+, Z+ right-handed
%(2)Z : rotational axis
%GC = [Z R ] (cylindrical coord.)

%Returns a struct array S of {X, Y, Z, XC, YC, ZC}
function S = CwReadFiducialCurve(fid, GC, Tol)

assert( nargin == 3 );
assert( all( GC(:,2) >= 0 ) );

S = [];

while 1
    [command, count] = fscanf(fid, '%s', 1);
    assert(count == 1);
    switch(lower(command))
        case 'newfc'
            A = [];
            [A.X, A.Y, A.Z, A.XC, A.YC, A.ZC] = CwReadFiducialCurveSegment(fid, GC, Tol);
            S = [ S; A];
        case 'closefc'
            break;            
        otherwise
            error('Unknown command');    
    end      
end

end

function [X,Y,Z,XC,YC,ZC] = CwReadFiducialCurveSegment(fid, GC, Tol)

assert( nargin == 3 );
assert( all( GC(:,2) >= 0 ) );

X = []; Y = []; Z = [];
XC = []; YC = []; ZC = [];

while 1
    [command, count] = fscanf(fid, '%s', 1);
    assert(count == 1);

    switch(lower(command))
        case 'newfcsegment'
            [P, count] = fscanf(fid, '%g', 3);
            assert(count == 3);
            x = P(1); y = P(2); z = P(3);

            X = x;  Y = y;  Z = z;
            XC = x; YC = y; ZC = z;
            xcurrent = x;   ycurrent = y; zcurrent = z;

        case 'lineto'
            [P, count] = fscanf(fid, '%g', 3);
            assert(count == 3);
            x = P(1); y = P(2); z = P(3);

            [Xline, Yline, Zline] = DiscretizeLineSegment3(xcurrent, ycurrent, zcurrent, x,y,z, Tol);
            X = [X; Xline]; Y = [Y; Yline]; Z = [Z; Zline];
            XC = [XC; x];   YC = [YC; y];   ZC = [ZC; z];
            xcurrent = x;   ycurrent = y; zcurrent = z;

        case 'arcto'
            [P, count] = fscanf(fid, '%g', 6);
            assert(count == 6);
            x1 = P(1); y1 = P(2); z1 = P(3);
            x2 = P(4); y2 = P(5); z2 = P(6);

            [Xarc, Yarc, Zarc] = DiscretizeArcSegment3(xcurrent, ycurrent, zcurrent, x1, y1, z1, x2, y2, z2, Tol);
            %plot3(Xarc, Yarc, Zarc, 'b-*', [xcurrent x1 x2]', [ycurrent y1 y2]', [zcurrent z1 z2]', 'rx--');
            
            X = [X; Xarc];  Y = [Y; Yarc];  Z = [Z; Zarc];
            XC = [XC; x1; x2];  YC = [YC; y1; y2];  ZC = [ZC; z1; z2];
            xcurrent = x2;  ycurrent = y2;  zcurrent = z2;
            
        case 'spiralto'
            [n, count] = fscanf(fid, '%d', 1);
            assert(count == 1);
            [P, count] = fscanf(fid, '%g', n*3);
            assert(count == n*3);
            Q = reshape(P, 3, n)';
            x = Q(:,1); y = Q(:,2); z = Q(:,3);
            
            %Since Outer Cup Design Coord. uses Y-axis as the rotational
            %axis, and the DiscretizeSpiralSegment3 requires Z-axis to be
            %the rotational axis, we map X->Y', Y->Z', Z->X' so that the
            %Z-axis is now the rotational axis
            [Zspiral, Xspiral, Yspiral ] = DiscretizeSpiralSegment3(GC, zcurrent, xcurrent, ycurrent, z, x, y, Tol);
            %plot3(Xspiral, Yspiral, Zspiral, 'b-',[xcurrent; x], [ycurrent; y], [zcurrent; z], 'rx--');
            
            X = [X; Xspiral]; Y = [Y; Yspiral]; Z = [Z; Zspiral];
            XC = [XC; x];   YC = [YC; y]; ZC = [ZC; z];
            xcurrent = x(end); ycurrent = y(end); zcurrent = z(end);
        case 'closefcsegment'
            break;

        otherwise
            error('Unknown command');
    end

end

end


function [X, Y, Z] = DiscretizeLineSegment3(x1, y1, z1, x2, y2, z2, tol)
    p1 = [x1, y1, z1];
    p2 = [x2, y2, z2];
    K = ceil( (norm(p1-p2) / tol) ) + 2 ;
    X = (linspace(x1, x2, K))';
    Y = (linspace(y1, y2, K))';
    Z = (linspace(z1, z2, K))';
end

function [X, Y, Z] = DiscretizeArcSegment3(x1, y1, z1, x2, y2, z2, x3, y3, z3, tol)
%transform to 2D
%ax + by + cz + d = 0
A = [ 
    x1 y1 z1 1
    x2 y2 z2 1
    x3 y3 z3 1
    ];
ZA = null(A);
assert( size(ZA,2) == 1 );

Z= null(ZA(1:3)');
assert( size(Z,2) == 2);
Rx = Z(:, 1);
Ry = Z(:, 2);
Rz = cross(Rx', Ry')';
T = [Rx Ry Rz]';

P = T * [x1 x2 x3
         y1 y2 y3
         z1 z2 z3];

[Xt Yt] = DiscretizeArcSegment2( P(1,1), P(2,1), P(1,2), P(2,2), P(1,3), P(2,3), tol);
Zt = ones(length(Xt),1) * mean(P(3,:));

%transform back to 3D space
Q = ( T' * [Xt Yt Zt]' )';
X = Q(:, 1);
Y = Q(:, 2);
Z = Q(:, 3);
end

function [X, Y] = DiscretizeArcSegment2(x1, y1, x2, y2, x3, y3, tol)

%determine the cartesian form
A = [
    x1*x1+y1*y1 x1 y1 1
    x2*x2+y2*y2 x2 y2 1
    x3*x3+y3*y3 x3 y3 1
    ];
Z = null(A);

assert ( size(Z,2) == 1 );

% (x*x+y*y) + bx + cy + d = 0;
assert ( Z(1) ~= 0 );
if Z(1) == 0, error('DiscretizeArcSegment input error'), end;
b = Z(2) / Z(1);
c = Z(3) / Z(1);
d = Z(4) / Z(1);

%center of the supporting circle (x-xo)^2 + (y-yo)^2 = r^2
%determine the polar form  
% x = xo + r cos(theta)
% y = yo + r sin(theta)
xo = - 0.5* b;
yo = - 0.5* c;
r =  sqrt( xo*xo + yo*yo - d);

%determine clockwiseness
clockwise = ispolycw([x1 x2 x3], [y1 y2 y3]);

thetas = angle( (x1-xo) + i*(y1 - yo) );
thetae = angle( (x3-xo) + i*(y3 - yo) );

if clockwise 
    if thetae > thetas
        thetas = thetas + 2*pi;
    end
else
    if thetae < thetas
        thetae = thetae + 2*pi;
    end
end

%sample
K = ceil( r * abs(thetas - thetae) / tol ) + 2;
q = linspace(thetas, thetae, K);
X = (xo + r * cos(q))';
Y = (yo + r * sin(q))';

end

%REQUIREMENTS
%(1) Z-axis is the rotational axis
%(2) GC(:,1): Z-axis, GC(:,2): R-axis
function [X, Y, Z] = DiscretizeSpiralSegment3(GC, x0, y0, z0, x, y, z, tol)
    
    theta = CwSpiralAngles([x0; x], [y0; y], [z0; z]);
    
    maxr = max(abs(GC(:,2)));
    K = ceil( maxr * abs(theta(end) - theta(1)) / tol ) + 2;
    
    q = linspace(theta(1), theta(end), K);
    Z = ( linspace(z0, z(end), K) )';
    
    R = interp1(GC(:,1), GC(:,2), Z, 'linear', 'extrap');
    X = R .*  cos(q');
    Y = R .*  sin(q');
end

