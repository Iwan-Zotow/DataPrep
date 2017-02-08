function E = GetEdges(FC)
    E = [];
    nV = 0;
    for segment = 1 : length(FC)
        for v = 2 : size(FC(segment).C, 1)
            e = [nV+v-2   nV+v-1];
            E = [E; e];
        end
        nV = nV + size(FC(segment).C, 1);
    end
end
