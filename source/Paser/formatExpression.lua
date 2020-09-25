paser.formatExpression = function(EXPRESSION)
	local expression,node,stack;
	expression = {};
	stack = {};
	for i = 1, #EXPRESSION do
		node = EXPRESSION[i];
		if helper.filterArray({node.class},paser.RPN_TABLE.GROUP) == true then
			if node.class == "PARENTHESIS_OPEN" then table.insert(stack,1,node);
			elseif node.class == "PARENTHESIS_CLOSE" then
				while true do
					if #stack == 0 then paser.throwError("invalid expression",node); end;
					if stack[1].class == "PARENTHESIS_OPEN" then
						table.remove(stack,1);
						break;
					end;
					table.insert(expression,table.remove(stack,1));
				end;
			end;
		elseif helper.filterArray({node.class},paser.RPN_TABLE.OPERAND) == true then table.insert(expression,node);
		elseif helper.filterArray({node.class},paser.RPN_TABLE.OPERATOR) == true then
			if (#stack == 0) or (stack[1].class == "PARENTHESIS_OPEN") then table.insert(stack,1,node);
			elseif (paser.OPERATOR_TABLE[node.class][1] > paser.OPERATOR_TABLE[stack[1].class][1]) or ((paser.OPERATOR_TABLE[node.class][1] == paser.OPERATOR_TABLE[stack[1].class][1]) and (paser.OPERATOR_TABLE[node.class][2] == "RIGHT")) then table.insert(stack,1,node);
			else
				while (#stack > 0) and (stack[1].class ~= "PARENTHESIS_OPEN") and ((paser.OPERATOR_TABLE[node.class][1] < paser.OPERATOR_TABLE[stack[1].class][1]) or ((paser.OPERATOR_TABLE[node.class][1] == paser.OPERATOR_TABLE[stack[1].class][1]) and (paser.OPERATOR_TABLE[node.class][2] == "LEFT"))) do table.insert(expression,table.remove(stack,1)); end;
				table.insert(stack,1,node);
			end;
		end;
	end;
	while #stack > 0 do
		node = table.remove(stack,1);
		if helper.filterArray({node.class},paser.RPN_TABLE.GROUP) == true then paser.throwError("Invalid expression",node); end;
		table.insert(expression,node);
	end;
	return expression;
end;
