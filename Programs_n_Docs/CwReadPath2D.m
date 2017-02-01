%X, Y: samples points
%XC, YC: control points
function [X, Y, XC, YC] = CwReadPath2D(fid, Tol)

assert( nargin == 2 );

X = []; Y = [];     %discretized points
XC = []; YC = [];   %control points
while 1
    [command, count] = fscanf(fid, '%s', 1);
    assert(count == 1 );
   
    switch lower(command)
        case 'newpath'
            [P, count] = fscanf(fid, '%g', 2);
            assert(count == 2);
            x = P(1); y = P(2);
            X = x;          Y = y;
            XC = x;         YC = y;
            xcurrent = x;   ycurrent = y;
        
        case 'lineto'
            [P, count] = fscanf(fid, '%g', 2);
            assert (count == 2 );
            x = P(1); y = P(2);
            
            [Xline, Yline] = DiscretizeLineSegment2(xcurrent, ycurrent, x, y, Tol);            
            X = [X; Xline];     Y = [Y; Yline];
            XC = [XC; x];       YC = [YC; y];
            xcurrent = x;       ycurrent = y;
        
        case 'arcto'
            [P, count] = fscanf(fid, '%g', 4);
            assert (count == 4 );
            x1 = P(1); y1 = P(2); 
            x2 = P(3); y2 = P(4);

            [Xarc, Yarc] = DiscretizeArcSegment2(xcurrent, ycurrent, x1, y1, x2, y2, Tol);
            X = [X; Xarc];      Y = [Y; Yarc];
            XC = [XC; x1; x2];  YC = [YC; y1; y2];
            xcurrent = x2;      ycurrent = y2;
        
        case 'ellipseto'
            [P, count] = fscanf(fid, '%g', 6);
            assert (count == 6 );
            x1 = P(1); y1 = P(2); x2 = P(3); y2 = P(4); x3 = P(5); y3 = P(6);
            
            [Xellipse, Yellipse] = DiscretizeEllipticalSegment2(xcurrent, ycurrent, x1, y1, x2, y2, x3, y3, Tol);
            X = [X; Xellipse];      Y = [Y; Yellipse];
            XC = [XC; x1; x2; x3];   YC = [YC; y1; y2; y3];
            xcurrent = x3;          ycurrent = y3;
        
        case 'closepath'
            break;
            
        otherwise 
            error('Unknown command');
    end
end

end %function

%return column vector X and Y
function [X, Y] = DiscretizeLineSegment2(x1, y1, x2, y2, tol)
    p1 = [x1, y1];
    p2 = [x2, y2];
    K = ceil( (norm(p1-p2) / tol) ) + 2 ;
    X = (linspace(x1, x2, K))';
    Y = (linspace(y1, y2, K))';
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


function [X, Y] = DiscretizeEllipticalSegment2(x1, y1, x2, y2, x3, y3, x4, y4, tol)
%determine the cartesian form
A = [
    x1*x1 y1*y1 x1 y1 1
    x2*x2 y2*y2 x2 y2 1
    x3*x3 y3*y3 x3 y3 1
    x4*x4 y4*y4 x4 y4 1
    ];
Z = null(A);

% Z(1)*x^2 + Z(2)*y^2 + Z(3)*x + Z(4)*y + Z(5) = 0
assert( size(Z,2) == 1 );
assert( Z(1) ~= 0 );
assert( Z(2) ~= 0 );
assert( sign(Z(1)) == sign(Z(2)));
    
%convert to (x-xo)^2/a^2 + (y-yo)^2/b^2 = 1
xo = -0.5 * Z(3) / Z(1);
yo = -0.5 * Z(4) / Z(2);
a = sqrt( (Z(1)*xo*xo + Z(2)*yo*yo - Z(5))/Z(1) );
b = sqrt( (Z(1)*xo*xo + Z(2)*yo*yo - Z(5))/Z(2) );

%determine clockwiseness
clockwise = ispolycw([x1 x2 x3], [y1 y2 y3]);

assert( clockwise == ispolycw([x2 x3 x4], [y2 y3 y4]) );
    
thetas = angle( (x1-xo)/a + i*(y1-yo)/b );
thetae = angle( (x4-xo)/a + i*(y4-yo)/b );
if clockwise 
    if thetae > thetas
        thetas = thetas + 2*pi;
    end
else
    if thetae < thetas
        thetae = thetae + 2*pi;
    end
end

K = ceil( sqrt(a*a+b*b) * abs(thetas - thetae) / tol ) + 2;
q = linspace(thetas, thetae, K);
X = (xo + a * cos(q))';
Y = (yo + b * sin(q))';

end

