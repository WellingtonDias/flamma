local helper = {};

helper.filter = function(INPUT,FILTER,EVALUATOR)
	local count = #INPUT;
	for i1 = 1, #INPUT do
		for i2 = 1, #FILTER do
			if EVALUATOR(INPUT,FILTER,i1,i2) == true then
				count = count - 1;
				break;
			end;
		end;
	end;
	return count == 0;
end;

helper.filterString = function(STRING,FILTER)
	return helper.filter(STRING,FILTER,function(STRING,FILTER,i1,i2) return string.sub(STRING,i1,i1) == string.sub(FILTER,i2,i2); end);
end;

helper.filterArray = function(ARRAY,FILTER)
	return helper.filter(ARRAY,FILTER,function(ARRAY,FILTER,i1,i2)
		if type(FILTER[i2]) ~= "table" then return ARRAY[i1] == FILTER[i2];
		else return helper.filterArray({ARRAY[i1]},FILTER[i2]);
		end;
	end);
end;

helper.throwError = function(MESSAGE)
	print(debug.traceback());
	print("ERROR: " .. MESSAGE .. ".");
	os.exit();
end;
