local interpreter = {};


interpreter.TABLE =
{
	SCOPE =
	{
		["GLOBAL"] = "globalScope",
		["THREAD"] = "threadScope",
		["LOCAL"] = "localScope"
	},
	TYPE =
	{
		["NULL"] = "Null",
		["BOOLEAN"] = "Boolean",
		["NUMBER"] = "Number",
		["STRING"] = "String"
	},
	EXPRESSION =
	{
		OPERAND = {"NULL","BOOLEAN","NUMBER","STRING","FIELD"},
		OPERATOR =
		{
			"NOT","AND","OR","XOR",
			"POSITIVE","NEGATIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		},
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


interpreter.resolveOperand = function(OPERAND)
	if OPERAND.class == "FIELD" then
		return OPERAND.scope[OPERAND.value].value;
	else
		return OPERAND;
	end;
end;


interpreter.resolveOperands = function(LEFT_OPERAND,RIGHT_OPERAND)
	return interpreter.resolveOperand(LEFT_OPERAND),interpreter.resolveOperand(RIGHT_OPERAND);
end;


interpreter.runExpression = function(EXPRESSION,SCOPES)
	local node,operand,stack;
	stack = {};
	for i = 1, #EXPRESSION do
		node = EXPRESSION[i];
		if helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.OPERAND) == true then
			if node.class == "FIELD" then
				if SCOPES.localScope[node.value] ~= nil then
					node.scope = SCOPES.localScope;
				elseif SCOPES.threadScope[node.value] ~= nil then
					node.scope = SCOPES.threadScope;
				elseif SCOPES.globalScope[node.value] ~= nil then
					node.scope = SCOPES.globalScope;
				else
					scope = "UNDEFINED";
				end;
			end;
			table.insert(stack,1,node);
		elseif helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.OPERATOR) == true then
			if helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.UNARY) == true then
				if #stack < 1 then
					helper.throwError("Runtime error 3");
				end;
				operand = stack[1];
				operand = interpreter.resolveOperand(operand);
				if node.class == "NOT" then
					if operand.class ~= "BOOLEAN" then
						helper.throwError("Runtime error 4");
					end;
					operand.value = not operand.value;
				elseif node.class == "POSITIVE" then
					if operand.class ~= "NUMBER" then
						helper.throwError("Runtime error 5");
					end;
				elseif node.class == "NEGATIVE" then
					if operand.class ~= "NUMBER" then
						helper.throwError("Runtime error 6");
					end;
					operand.value = -operand.value;
				end;
				stack[1] = operand;
			elseif helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.BINARY) == true then
				if #stack < 2 then
					helper.throwError("Runtime error 7");
				end;
				leftOperand = table.remove(stack,2);
				rightOperand = stack[1];
				if node.class == "DOT" then
					if (leftOperand.class ~= "FIELD") or (rightOperand.class ~= "FIELD") then
						helper.throwError("Runtime error 8");
					end;
					if leftOperand.scope[leftOperand.value][rightOperand.value] == nil then
						helper.throwError("Runtime error 9");
					end;
					rightOperand.scope = leftOperand.scope[leftOperand.value];
				else
					leftOperand,rightOperand = interpreter.resolveOperands(leftOperand,rightOperand);
					if node.class == "AND" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then
							helper.throwError("Runtime error 10");
						end;
						rightOperand.value = leftOperand.value and rightOperand.value;
					elseif node.class == "OR" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then
							helper.throwError("Runtime error 11");
						end;
						rightOperand.value = leftOperand.value or rightOperand.value;
					elseif node.class == "XOR" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then
							helper.throwError("Runtime error 12");
						end;
						rightOperand.value = leftOperand.value ~= rightOperand.value;
					elseif node.class == "PLUS" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("Runtime error 13");
						end;
						rightOperand.value = leftOperand.value + rightOperand.value;
					elseif node.class == "MINUS" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("Runtime error 14");
						end;
						rightOperand.value = leftOperand.value - rightOperand.value;
					elseif node.class == "ASTERISK" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("Runtime error 15");
						end;
						rightOperand.value = leftOperand.value * rightOperand.value;
					elseif node.class == "SLASH" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("Runtime error 16");
						end;
						if rightOperand.value == 0 then
							helper.throwError("Runtime error 17");
						end;
						rightOperand.value = leftOperand.value / rightOperand.value;
					elseif node.class == "PERCENT" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("Runtime error 18");
						end;
						if rightOperand.value == 0 then
							helper.throwError("Runtime error 19");
						end;
						rightOperand.value = leftOperand.value % rightOperand.value;
					elseif node.class == "LESS" then
					elseif node.class == "LESS-EQUAL" then
					elseif node.class == "DOUBLE-EQUAL" then
						rightOperand = paser.createNode("BOOLEAN",nil,nil,nil,{value = (leftOperand.class == rightOperand.class) and (leftOperand.value == rightOperand.value)});
					elseif node.class == "NOT-EQUAL" then
						rightOperand = paser.createNode("BOOLEAN",nil,nil,nil,{value = (leftOperand.class ~= rightOperand.class) or (leftOperand.value ~= rightOperand.value)});
					elseif node.class == "GREATER-EQUAL" then
					elseif node.class == "GREATER" then
					end;
				end;
				stack[1] = rightOperand;
			end;
		end;
	end;
	helper.printTable(stack,0,true);
	if #stack ~= 1 then
		helper.throwError("Runtime error 2");
	end;
	return stack[1];
end;


interpreter.runDeclaration = function(DECLARATION,SCOPES)
	local type,value;
	if DECLARATION.class == "DECLARATION" then
		value = {type = "UNDEFINED"};
		type = DECLARATION.identifiers[1].type;
	elseif DECLARATION.class == "INITIALIZATION" then
		value = interpreter.runExpression(DECLARATION.expressions[1].value,SCOPES);
		if (DECLARATION.operator == "COLON-EQUAL") and (DECLARATION.identifiers[1].type == "Undefined") then
			type = interpreter.TABLE.TYPE[value.class];
		else
			if (DECLARATION.identifiers[1].type ~= "Undefined") and (DECLARATION.identifiers[1].type ~= interpreter.TABLE.TYPE[value.class]) then
				helper.throwError("Runtime error 1");
			end;
			type = DECLARATION.identifiers[1].type;
		end;
	end;
	SCOPES[interpreter.TABLE.SCOPE[DECLARATION.scope]][DECLARATION.identifiers[1].name] =
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
			interpreter.runDeclaration(statement,{globalScope = SCOPES.globalScope,threadScope = SCOPES.threadScope,localScope = scope});
		elseif statement.class == "ASSIGNMENT" then
			-- interpreter.runAssignment(statement,{globalScope = SCOPES.globalScope,localScope = scope});
		end;
	end;
end;


interpreter.runStream = function(STREAM)
	local scopes;
	scopes =
	{
		globalScope = {},
		threadScope = {}
	};
	interpreter.runBlock(STREAM.value,scopes);
	helper.printTable(scopes,0,true);
end;
