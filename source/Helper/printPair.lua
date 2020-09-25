helper.printPair = function(KEY,VALUE,RECURSIVE)
	io.write(KEY .. " = ");
	if type(VALUE) ~= "table" then
		if type(VALUE) == nil then io.write("nil");
		elseif type(VALUE) == "boolean" then
			if VALUE == false then io.write("false");
			else io.write("true");
			end;
		elseif type(VALUE) == "function" then io.write("function");
		else io.write(VALUE);
		end;
	elseif RECURSIVE == true then io.write(helper.printTable(VALUE,RECURSIVE));
	else io.write("table");
	end;
	io.write(" ");
end;
