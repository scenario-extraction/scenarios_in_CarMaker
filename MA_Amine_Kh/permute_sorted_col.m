% permute the columns of a matrix according to the sorted timestamps
function newB = permute_sorted_col(B)
[~, a_order] = sort(B(1,:));
newB = B(:,a_order);
end
