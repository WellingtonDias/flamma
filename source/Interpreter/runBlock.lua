interpreter.runBlock = function(BLOCK,SCOPES)
	local node,scope;
	scope = {};
	for i = 1, #BLOCK.value do
		node = BLOCK.value[i];
		if (node.class == "DECLARATION") or (node.class == "INITIALIZATION") then interpreter.runDeclaration(node,{globalScope = SCOPES.globalScope,threadScope = SCOPES.threadScope,localScope = scope}); end;
	end;
	helper.printTable(scope,true);
end;
