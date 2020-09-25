helper.filterArray = function(ARRAY,FILTER)
	return helper.filter(ARRAY,FILTER,function(ARRAY,FILTER,i1,i2)
		if type(FILTER[i2]) ~= "table" then
			return ARRAY[i1] == FILTER[i2];
		else
			return helper.filterArray({ARRAY[i1]},FILTER[i2]);
		end;
	end);
end;
