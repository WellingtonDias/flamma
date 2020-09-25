interpreter.runExpression = function(EXPRESSION,SCOPES)
	local node,operand,stack;
	stack = {};
	for i = 1, #EXPRESSION.value do
		node = EXPRESSION.value[i];
		if helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.OPERAND) == true then
			if node.class == "ENTITY" then
				if SCOPES.localScope[node.value] ~= nil then node.scope = SCOPES.localScope;
				elseif SCOPES.threadScope[node.value] ~= nil then node.scope = SCOPES.threadScope;
				elseif SCOPES.globalScope[node.value] ~= nil then node.scope = SCOPES.globalScope;
				else scope = "UNDEFINED";
				end;
			end;
			table.insert(stack,1,node);
		elseif helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.OPERATOR) == true then
			if helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.UNARY) == true then
				if #stack < 1 then helper.throwError("invalid expression"); end;
				operand = stack[1];
				print("UNARY: ",operand.value);
				if node.class == "NOT" then
					operand = interpreter.resolveUnary(operand);
					if operand.class ~= "BOOLEAN" then helper.throwError("invalid expression"); end;
					operand.value = not operand.value;
				elseif node.class == "POSITIVE" then
					operand = interpreter.resolveUnary(operand);
					if operand.class ~= "NUMBER" then helper.throwError("invalid expression"); end;
				elseif node.class == "NEGATIVE" then
					operand = interpreter.resolveUnary(operand);
					if operand.class ~= "NUMBER" then helper.throwError("invalid expression"); end;
					operand.value = -operand.value;
				end;
				stack[1] = operand;
			elseif helper.filterArray({node.class},interpreter.TABLE.EXPRESSION.BINARY) == true then
				if #stack < 2 then helper.throwError("invalid expression"); end;
				leftOperand = table.remove(stack,2);
				rightOperand = stack[1];
				print("BINARY LEFT: ",leftOperand.value);
				print("BINARY RIGHT: ",rightOperand.value);
				if node.class == "DOT" then
					if (leftOperand.class ~= "ENTITY") or (rightOperand.class ~= "ENTITY") then helper.throwError("invalid expression"); end;
					if (leftOperand.scope[leftOperand.value][rightOperand.value] == nil) then helper.throwError("invalid expression"); end;
					rightOperand.scope = leftOperand.scope[leftOperand.value];
				else
					leftOperand,rightOperand = interpreter.resolveBinary(leftOperand,rightOperand);
					if node.class == "AND" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then helper.throwError("invalid expression"); end;
						rightOperand.value = leftOperand.value and rightOperand.value;
					elseif node.class == "OR" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then helper.throwError("invalid expression"); end;
						rightOperand.value = leftOperand.value or rightOperand.value;
					elseif node.class == "XOR" then
						if (leftOperand.class ~= "BOOLEAN") or (rightOperand.class ~= "BOOLEAN") then helper.throwError("invalid expression"); end;
						rightOperand.value = leftOperand.value ~= rightOperand.value;
					elseif node.class == "PLUS" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then helper.throwError("invalid expression"); end;
						rightOperand.value = leftOperand.value + rightOperand.value;
					elseif node.class == "MINUS" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then helper.throwError("invalid expression"); end;
						rightOperand.value = leftOperand.value - rightOperand.value;
					elseif node.class == "ASTERISK" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then helper.throwError("invalid expression"); end;
						rightOperand.value = leftOperand.value * rightOperand.value;
					elseif node.class == "SLASH" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then helper.throwError("invalid expression"); end;
						if (rightOperand.value == 0) then helper.throwError("invalid expression"); end;
						rightOperand.value = leftOperand.value / rightOperand.value;
					elseif node.class == "PERCENT" then
						if (leftOperand.class ~= "NUMBER") or (rightOperand.class ~= "NUMBER") then helper.throwError("invalid expression"); end;
						if (rightOperand.value == 0) then helper.throwError("invalid expression"); end;
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
	if #stack ~= 1 then helper.throwError("invalid expression"); end;
	return stack[1];
end;
