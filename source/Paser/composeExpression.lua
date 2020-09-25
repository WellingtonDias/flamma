paser.composeExpression = function(STREAM,INDEX,STATE,TYPE)
	local expression,index,node,token;
	expression = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if helper.filterArray({token.class},paser.STREAM_TABLE.EXPRESSION[TYPE]) == false then break;
		elseif token.class == "WORD" then node = paser.createNode("ENTITY",token.lexeme,token.line,token.column,{value = token.value});
		elseif token.value ~= nil then node = paser.createNode(token.class,token.lexeme,token.line,token.column,{value = token.value});
		else node = paser.createNode(token.class,token.lexeme,token.line,token.column);
		end;
		table.insert(expression,node);
		index = index + 1;
	end;
	if #expression == 0 then paser.throwError("invalid token in expression",token); end;
	paser.filterExpression(expression,TYPE);
	expression = paser.formatExpression(expression);
	return expression,index;
end;
