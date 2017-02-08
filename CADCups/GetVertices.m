%return V, a (nVx3)-matrix
function V = GetVertices(FC)
    V = [];
    for segment = 1 : length(FC)
       V = [V; FC(segment).C];
    end
end
