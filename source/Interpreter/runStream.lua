interpreter.runStream = function(STREAM)
	local scopes;
	scopes = {globalScope = {},threadScope = {}};
	interpreter.runBlock(STREAM.value,scopes);
	helper.printTable(scopes,true);
end;
