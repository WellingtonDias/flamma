paser.composeExpression = function(STREAM,INDEX,STATE,TYPE)
	local expression,index,node,token;
	expression = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if not helper.filterArray({token.class},paser.STREAM_TABLE.EXPRESSION[TYPE]) then break;
		elseif token.class == "PARENTHESIS_OPEN" then
			if (node ~= nil) and helper.filterArray({node.class},paser.STREAM_TABLE.EXPRESSION["COMPOUND"]) then
				table.insert(STATE.stack,1,"ARGUMENTS");
				node,index = paser.readArguments(STREAM,index,STATE,token.line,token.column);
			else
				table.insert(STATE.stack,1,"GROUP");
				node = paser.createNode(token.class,token.lexeme,token.line,token.column,{});
			end;
		elseif token.class == "PARENTHESIS_CLOSE" then
			if table.remove(STATE.stack,1) == "ARGUMENTS" then break;
			else node = paser.createNode(token.class,token.lexeme,token.line,token.column,{});
			end;
		elseif token.class == "WORD" then node = paser.createNode("ENTITY",token.lexeme,token.line,token.column,{value = token.value});
		else
			if token.value ~= nil then node = paser.createNode(token.class,token.lexeme,token.line,token.column,{value = token.value});
			else node = paser.createNode(token.class,token.lexeme,token.line,token.column,{});
			end;
		end;
		table.insert(expression,node);
		index = index + 1;
	end;
	if #expression == 0 then paser.throwError("Bad formatted expression, empty construction",token); end;
	-- paser.filterExpression(expression,TYPE);
	return expression,index;
end;

-- elseif token.class == "BRACKET_OPEN" then
-- 	if (node == nil) or not helper.filterArray({node.class},paser.STREAM_TABLE.EXPRESSION["COMPOUND"]) then
-- 		table.insert(STATE.stack,1,"LIST");
-- 		node,index = paser.readList(STREAM,index,STATE.stack,token.line,token.column);
-- 	else
-- 		table.insert(STATE.stack,1,"INDEX");
-- 		table.insert(expression,{class = "LIST_INDEXATION",line = token.line,column = token.column});
-- 		node,index = paser.readIndex(STREAM,index,STATE.stack,token.line,token.column);
-- 	end;
-- elseif token.class == "BRACE_OPEN" then
-- 	if (node == nil or not helper.filterArray({node.class},paser.STREAM_TABLE.EXPRESSION["COMPOUND"]) then
-- 		table.insert(STATE.stack,1,"MAP");
-- 		node,index = paser.readMap(STREAM,index,STATE.stack,token.line,token.column);
-- 	else
-- 		table.insert(STATE.stack,1,"KEY");
-- 		table.insert(expression,{class = "MAP_INDEXATION",line = token.line,column = token.column});
-- 		node,index = paser.readKey(STREAM,index,STATE.stack,token.line,token.column);
-- 	end;
-- elseif token.class == "IMPORT" then
-- elseif token.class == "FUNCTION" then node,index = paser.readFunction(STREAM,index,STATE,token.line,token.column);
-- elseif token.class == "CLOSURE" then
-- elseif token.class == "CLASS" then
-- elseif token.class == "ASYNC" then
-- elseif token.class == "AWAIT" then
-- elseif token.class == "CREATE" then
-- elseif token.class == "PLUS" then
-- elseif token.class == "MINUS" then
-- elseif token.class == "ASTERISK" then node = paser.createNode("MULTIPLICATION",token.lexeme,token.line,token.column,{value = token.value});
-- elseif token.class == "SLASH" then node = paser.createNode("DIVISION",token.lexeme,token.line,token.column,{value = token.value});
-- elseif token.class == "PERCENT" then node = paser.createNode("MODULO",token.lexeme,token.line,token.column,{value = token.value});
-- elseif token.class == "DOT" then node = paser.createNode("INDEXATION",token.lexeme,token.line,token.column,{value = token.value});
