local interpreter = {};


interpreter.TABLE =
{
	SCOPE =
	{
		["GLOBAL"] = "globalScope",
		["LOCAL"] = "localScope"
	},
	EXPRESSION =
	{
		OPERAND = {"LITERAL","IDENTIFIER"},
		UNARY =
		{
			"NOT",
			"POSITIVE","NEGATIVE"
		},
		BINARY =
		{
			"AND","OR","XOR",
			"PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		}
	}
};


interpreter.runExpression = function(EXPRESSION,SCOPES)
	local node,stack;
	stack = {};
	for i = 1, #EXPRESSION do
		node = EXPRESSION[i];




	end;
	helper.printTable(stack,0,true);
	if #stack ~= 1 then
		helper.throwError("Runtime error");
	end;
	return stack[1];
end;


interpreter.runDeclaration = function(DECLARATION,SCOPES)
	local type,value;
	if DECLARATION.class == "DECLARATION" then
		type = DECLARATION.fields[1].type;
		value = {type = "Undefined"};
	elseif DECLARATION.class == "INITIALIZATION" then
		type = DECLARATION.fields[1].type;
		value = interpreter.runExpression(DECLARATION.values[1].value,SCOPES);
		if type == "Undefined" then
			if DECLARATION.operator == "COLON-EQUAL" then
				type = value.type;
			end;
		else
			if type ~= value.type then
				helper.throwError("Runtime error");
			end;
		end;
	end;
	SCOPES[interpreter.TABLE.SCOPE[DECLARATION.scope]][DECLARATION.fields[1].identifier] =
	{
		modifier = DECLARATION.modifier,
		type = type,
		value = value
	};
end;


interpreter.runBlock = function(BLOCK,SCOPES)
	local scope,statement;
	scope = {};
	for i = 1, #BLOCK do
		statement = BLOCK[i];
		if (statement.class == "DECLARATION") or (statement.class == "INITIALIZATION") then
			interpreter.runDeclaration(statement,{globalScope = SCOPES.globalScope,localScope = scope});
		elseif statement.class == "ASSIGNMENT" then
			-- interpreter.runAssignment(statement,{globalScope = SCOPES.globalScope,localScope = scope});
		end;
	end;
end;


interpreter.runStream = function(STREAM)
	local scopes;
	scopes = {globalScope = {}};
	interpreter.runBlock(STREAM.value,scopes);
	helper.printTable(scopes,0,true);
end;
