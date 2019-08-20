function b=check_adj(vec) % check whether two consecutive array elements are duplicate 
temp=unique(vec,'stable');
b=isequal(temp,vec);
 
end