local interpreter = {};

interpreter.TABLE =
{
	SCOPE =
	{
		["GLOBAL"] = "globalScope";
		["THREAD"] = "threadScope";
		["LOCAL"] = "localScope";
	};
};

interpreter.runStream = function(STREAM)
	local scopes;
	scopes = {globalScope = {},threadScope = {}};
	interpreter.runBlock(STREAM.value,scopes);
	helper.printTable(scopes);
end;

interpreter.runBlock = function(BLOCK,SCOPES)
	local node,scope;
	scope = {};
	for i = 1, #STREAM.value do
		node = STREAM.value[i];
		if (node.class == "DECLARATION") or (node.class == "INITIALIZATION") interpreter.runInitialization(node.class,node.value,{globalScope = SCOPES.globalScope,threadScope = SCOPES.threadScope,localScope = scope});
	end;
	helper.printTable(scope);
end;

interpreter.runInitialization = function(CLASS,INITIALIZATION,SCOPES)
	local identifier,scope,value;
	identifier = INITIALIZATION.identifiers[0];
	scope = interpreter.TABLE.SCOPE[INITIALIZATION.scope];
	if node.class == "DECLARATION" then value = {type = "UNDEFINED"};
	elseif node.class == "INITIALIZATION" then value = interpreter.runExpression(INITIALIZATION.expression[0]);
	end;
	SCOPES[scope][identifier.name] =
	{
		mutability = INITIALIZATION.mutability,
		type = identifier.type,
		value = value
	};
end;

interpreter.runExpression = function(EXPRESSION,SCOPES)
	value = {type = "AQUI"};
end;
