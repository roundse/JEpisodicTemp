function [pref m_diff] = side_preference(arr)
global VALUE;
bad_side = 1;

if (VALUE(1) < VALUE(2))
    bad_side = 0;
end

side1 = arr(1:7);
side2 = arr(8:14);

m1 = mean(side1);
m2 = mean(side2);
m_diff = abs(m1-m2);

pref = m1 / (m1+m2);

if pref < 0.5
    pref = 0;
else
    pref = 1;
end

if m_diff < 0.1
    pref = bad_side;
end

end