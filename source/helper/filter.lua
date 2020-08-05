helper.filter = function(INPUT,FILTER,EVALUATOR)
	local count = #INPUT;
	for i1 = 1, #INPUT do
		for i2 = 1, #FILTER do
			if EVALUATOR(i1,i2,INPUT,FILTER) then
				count = count - 1;
				break;
			end;
		end;
	end;
	return count == 0;
end;