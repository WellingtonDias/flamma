helper.filterString = function(STRING,FILTER)
	return helper.filter(STRING,FILTER,function(STRING,FILTER,i1,i2) return string.sub(STRING,i1,i1) == string.sub(FILTER,i2,i2); end);
end;
