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
			"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		}
	}
};


interpreter.resolveScope = function(IDENTIFIER,SCOPES)
	if IDENTIFIER.scope == nil then
		if SCOPES.localScope[IDENTIFIER.value] ~= nil then
			IDENTIFIER.scope = SCOPES.localScope;
		elseif SCOPES.globalScope[IDENTIFIER.value] ~= nil then
			IDENTIFIER.scope = SCOPES.globalScope;
		else
			helper.throwError("Runtime error");
		end;
	end;
end;


interpreter.resolveOperand = function(OPERAND,SCOPES)
	if OPERAND.class == "IDENTIFIER" then
		local node;
		interpreter.resolveScope(OPERAND,SCOPES);
		node = OPERAND.scope[OPERAND.value];
		return {class = "LITERAL",type = node.type,value = node.value};
	else
		return OPERAND;
	end;
end;


interpreter.resolveOperands = function(LEFT_OPERAND,RIGHT_OPERAND,SCOPES)
	return interpreter.resolveOperand(LEFT_OPERAND,SCOPES),interpreter.resolveOperand(RIGHT_OPERAND,SCOPES);
end;


interpreter.runExpression = function(EXPRESSION,SCOPES)
	local node,leftOperand,operand,rightOperand,stack;
	stack = {};
	for i = 1, #EXPRESSION do
		node = EXPRESSION[i];
		if helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.OPERAND) == true then
			if node.class == "IDENTIFIER" then
				table.insert(stack,1,{class = "IDENTIFIER",scope = nil,value = node.value});
			elseif node.class == "LITERAL" then
				table.insert(stack,1,{class = "LITERAL",type = node.type,value = node.value});
			end;
		elseif node.class == "OPERATOR" == true then
			if helper.filterArray({node.value},interpreter.TABLE.EXPRESSION.UNARY) == true then
				if #stack < 1 then
					helper.throwError("Runtime error");
				end;
				operand = interpreter.resolveOperand(stack[1],SCOPES);
				if node.value == "NOT" then
					if operand.type ~= "Boolean" then
						helper.throwError("Runtime error");
					end;
					operand.value = not operand.value;
				elseif node.value == "POSITIVE" then
					if operand.type ~= "Number" then
						helper.throwError("Runtime error");
					end;
				elseif node.value == "NEGATIVE" then
					if operand.type ~= "Number" then
						helper.throwError("Runtime error");
					end;
					operand.value = -operand.value;
				end;
				stack[1] = operand;
			elseif helper.filterArray({node.value},interpreter.TABLE.EXPRESSION.BINARY) == true then
				if #stack < 2 then
					helper.throwError("Runtime error");
				end;
				leftOperand = table.remove(stack,2);
				rightOperand = stack[1];
				leftOperand,rightOperand = interpreter.resolveOperands(leftOperand,rightOperand,SCOPES);
				if node.value == "AND" then
					if (leftOperand.type ~= "Boolean") or (rightOperand.type ~= "Boolean") then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value and rightOperand.value;
				elseif node.value == "OR" then
					if (leftOperand.type ~= "Boolean") or (rightOperand.type ~= "Boolean") then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value or rightOperand.value;
				elseif node.value == "XOR" then
					if (leftOperand.type ~= "Boolean") or (rightOperand.type ~= "Boolean") then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value ~= rightOperand.value;
				elseif node.value == "PLUS" then
					if (leftOperand.type ~= "Number") or (rightOperand.type ~= "Number") then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value + rightOperand.value;
				elseif node.value == "MINUS" then
					if (leftOperand.type ~= "Number") or (rightOperand.type ~= "Number") then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value - rightOperand.value;
				elseif node.value == "ASTERISK" then
					if (leftOperand.type ~= "Number") or (rightOperand.type ~= "Number") then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value * rightOperand.value;
				elseif node.value == "SLASH" then
					if (leftOperand.type ~= "Number") or (rightOperand.type ~= "Number") then
						helper.throwError("Runtime error");
					end;
					if rightOperand.value == 0 then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value / rightOperand.value;
				elseif node.value == "PERCENT" then
					if (leftOperand.type ~= "Number") or (rightOperand.type ~= "Number") then
						helper.throwError("Runtime error");
					end;
					if rightOperand.value == 0 then
						helper.throwError("Runtime error");
					end;
					leftOperand.value = leftOperand.value % rightOperand.value;
				elseif node.value == "LESS" then
				elseif node.value == "LESS-EQUAL" then
				elseif node.value == "DOUBLE-EQUAL" then
					if leftOperand.type ~= rightOperand.type then
						helper.throwError("Runtime error");
					end;
					leftOperand.type = "Boolean";
					leftOperand.value = leftOperand.value == rightOperand.value;
				elseif node.value == "NOT-EQUAL" then
					if leftOperand.type ~= rightOperand.type then
						helper.throwError("Runtime error");
					end;
					leftOperand.type = "Boolean";
					leftOperand.value = leftOperand.value ~= rightOperand.value;
				elseif node.value == "GREATER-EQUAL" then
				elseif node.value == "GREATER" then
				end;
				stack[1] = rightOperand;
			end;
		end;
	end;
	helper.printTable(stack,0,true);
	if #stack ~= 1 then
		helper.throwError("Runtime error");
	end;
	return interpreter.resolveOperand(stack[1],SCOPES);
end;


interpreter.runDeclaration = function(DECLARATION,SCOPES)
	local type,value;
	if DECLARATION.class == "DECLARATION" then
		type = DECLARATION.fields[1].type;
		value = {type = "Undefined"};
	elseif DECLARATION.class == "INITIALIZATION" then
		local node;
		node = interpreter.runExpression(DECLARATION.values[1].value,SCOPES);
		type = DECLARATION.fields[1].type;
		value = {type = node.type,value = node.value};
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
