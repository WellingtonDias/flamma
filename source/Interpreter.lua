local interpreter = {};


interpreter.TABLE =
{
	SCOPE =
	{
		["GLOBAL"] = "globalScope",
		["THREAD"] = "threadScope",
		["LOCAL"] = "localScope"
	},
	EXPRESSION =
	{
		OPERAND = {"NULL","BOOLEAN","NUMBER","STRING","FIELD"},
		OPERATOR =
		{
			"NOT","AND","OR","XOR",
			"POSITIVE","NEGATIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
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
			"LESS","LESS-EQUAL","EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
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
	for i = 1, #EXPRESSION.value do
		node = EXPRESSION.value[i];
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
					helper.throwError("invalid expression");
				end;
				operand = stack[1];
				operand = interpreter.resolveOperand(operand);
				if node.class == "NOT" then
					if operand.class ~= "BOOLEAN" then
						helper.throwError("invalid expression");
					end;
					operand.value = not operand.value;
				elseif node.class == "POSITIVE" then
					if operand.class ~= "NUMBER" then
						helper.throwError("invalid expression");
					end;
				elseif node.class == "NEGATIVE" then
					if operand.class ~= "NUMBER" then
						helper.throwError("invalid expression");
					end;
					operand.value = -operand.value;
				end;
				stack[1] = operand;
			elseif helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.BINARY) == true then
				if #stack < 2 then
					helper.throwError("invalid expression");
				end;
				leftOperand = table.remove(stack,2);
				rightOperand = stack[1];
				if node.class == "DOT" then
					if (leftOperand.class ~= "FIELD") or (rightOperand.class ~= "FIELD") then
						helper.throwError("invalid expression");
					end;
					if (leftOperand.scope[leftOperand.value][rightOperand.value] == nil) then
						helper.throwError("invalid expression");
					end;
					rightOperand.scope = leftOperand.scope[leftOperand.value];
				else
					leftOperand,rightOperand = interpreter.resolveOperands(leftOperand,rightOperand);
					if node.class == "AND" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value and rightOperand.value;
					elseif node.class == "OR" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value or rightOperand.value;
					elseif node.class == "XOR" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value ~= rightOperand.value;
					elseif node.class == "PLUS" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value + rightOperand.value;
					elseif node.class == "MINUS" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value - rightOperand.value;
					elseif node.class == "ASTERISK" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value * rightOperand.value;
					elseif node.class == "SLASH" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("invalid expression");
						end;
						if (rightOperand.value == 0) then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value / rightOperand.value;
					elseif node.class == "PERCENT" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then
							helper.throwError("invalid expression");
						end;
						if (rightOperand.value == 0) then
							helper.throwError("invalid expression");
						end;
						rightOperand.value = leftOperand.value % rightOperand.value;
					elseif node.class == "LESS" then
					elseif node.class == "LESS-EQUAL" then
					elseif node.class == "DOUBLE-EQUAL" then
					elseif node.class == "NOT-EQUAL" then
					elseif node.class == "GREATER-EQUAL" then
					elseif node.class == "GREATER" then
					end;
				end;
				stack[1] = rightOperand;
			end;
		end;
	end;
	if #stack ~= 1 then
		helper.throwError("invalid expression");
	end;
	return stack[1];
end;


interpreter.runDeclaration = function(DECLARATION,SCOPES)
	local identifier,scope,type,value;
	identifier = DECLARATION.identifiers[1];
	scope = interpreter.TABLE.SCOPE[DECLARATION.scope];
	if DECLARATION.class == "DECLARATION" then
		value = {type = "UNDEFINED"};
		type = identifier.type;
	elseif DECLARATION.class == "INITIALIZATION" then
		value = interpreter.runExpression(DECLARATION.expressions[1],SCOPES);
		if (DECLARATION.operator == "COLON-EQUAL") and (identifier.type == "Undefined") then
			type = value.class;
		else
			type = identifier.type;
		end;
	end;
	SCOPES[scope][identifier.name] =
	{
		modifier = DECLARATION.modifier,
		type = type,
		value = value
	};
end;


interpreter.runBlock = function(BLOCK,SCOPES)
	local node,scope;
	scope = {};
	for i = 1, #BLOCK do
		node = BLOCK[i];
		if (node.class == "DECLARATION") or (node.class == "INITIALIZATION") then
			interpreter.runDeclaration(node,{globalScope = SCOPES.globalScope,threadScope = SCOPES.threadScope,localScope = scope});
		end;
	end;
end;


interpreter.runStream = function(STREAM)
	local scopes;
	scopes = {globalScope = {},threadScope = {}};
	interpreter.runBlock(STREAM.value,scopes);
	helper.printTable(scopes,0,true);
end;
