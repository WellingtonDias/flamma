local interpreter = {};

interpreter.TABLE =
{
	SCOPE =
	{
		["GLOBAL"] = "globalScope";
		["THREAD"] = "threadScope";
		["LOCAL"] = "localScope";
	};
	EXPRESSION =
	{
		OPERAND = {"NULL","BOOLEAN","NUMBER","STRING","ENTITY","ARGUMENTS"},
		OPERATOR =
		{
			"AND","OR","XOR",
			"POSITIVE","NEGATIVE",
			"PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		},
		UNARY =
		{
			"NOT",
			"POSITIVE","NEGATIVE",
		},
		BINARY =
		{
			"AND","OR","XOR",
			"PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		}
	};
};

interpreter.runStream = function(STREAM)
	local scopes;
	scopes = {globalScope = {},threadScope = {}};
	interpreter.runBlock(STREAM.value,scopes);
	helper.printTable(scopes,0);
end;

interpreter.runBlock = function(BLOCK,SCOPES)
	local node,scope;
	scope = {};
	for i = 1, #BLOCK.value do
		node = BLOCK.value[i];
		if (node.class == "DECLARATION") or (node.class == "INITIALIZATION") then interpreter.runDeclaration(node,{globalScope = SCOPES.globalScope,threadScope = SCOPES.threadScope,localScope = scope}); end;
	end;
	helper.printTable(scope,0);
end;

interpreter.runDeclaration = function(DECLARATION,SCOPES)
	local identifier,scope,type,value;
	identifier = DECLARATION.identifiers[1];
	scope = interpreter.TABLE.SCOPE[DECLARATION.scope];
	if DECLARATION.class == "DECLARATION" then
		value = {type = "UNDEFINED"};
		type = identifier.type;
	elseif DECLARATION.class == "INITIALIZATION" then
		value = interpreter.runExpression(DECLARATION.expressions[1]);
		print(value.type);
		if (DECLARATION.assigment == "COLON-EQUAL") and (identifier.type == "Undefined") then type = value.class;
		else type = identifier.type;
		end;
	end;
	SCOPES[scope][identifier.name] =
	{
		mutability = DECLARATION.mutability,
		type = type,
		value = value
	};
end;

interpreter.runExpression = function(EXPRESSION,SCOPES)
	local node,operand,scope,stack;
	stack = {};
	for i = 1, #EXPRESSION.value do
		node = EXPRESSION.value[i];
		if helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.OPERAND) == true then
			if node.class == "ENTITY" then
				if SCOPES.localScope[node.value] ~= nil then scope = "LOCAL";
				elseif SCOPES.threadScope[node.value] ~= nil then scope = "THREAD";
				elseif SCOPES.globalScope[node.value] ~= nil then scope = "GLOBAL";
				else scope = "UNDEFINED";
				end;
			end;
			node.scope = scope;
			table.insert(stack,1,node);
		elseif helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.OPERATOR) == true then
			if helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.UNARY) == true then
				if #stack < 1 then helper.throwError("invalid expression"); end;
				operand = stack[1];
				if node.class == "NOT" then
					if operand.class ~= "BOOLEAN" then helper.throwError("invalid expression"); end;
					operand.value = not operand.value;
				elseif node.class == "POSITIVE" then
					if operand.class ~= "NUMBER" then helper.throwError("invalid expression"); end;
				elseif node.class == "NEGATIVE" then
					if operand.class ~= "NUMBER" then helper.throwError("invalid expression"); end;
					operand.value = -operand.value;
				end;
			end;
		end;
	end;
	if #stack ~= 1 then helper.throwError("invalid expression"); end;
	return stack[1];
end;
