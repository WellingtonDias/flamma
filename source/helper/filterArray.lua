helper.filterArray = function(ARRAY,FILTER)
	return helper.filter(ARRAY,FILTER,function(ARRAY,FILTER,i1,i2) return ARRAY[i1] == FILTER[i2]; end);
end;
