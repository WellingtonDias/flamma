helper.printTable = function(TABLE,RECURSIVE)
	io.write("{");
	for key,value in pairs(TABLE) do
		helper.printPair(key,value,RECURSIVE);
	end;
	io.write("}");
end;
