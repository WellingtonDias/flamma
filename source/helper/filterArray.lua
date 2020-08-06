helper.filterArray = function(ARRAY,FILTER)
	return helper.filter(ARRAY,FILTER,function(i1,i2,ARRAY,FILTER) return ARRAY[i1] == FILTER[i2]; end);
end;
