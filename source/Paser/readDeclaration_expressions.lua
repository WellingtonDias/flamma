paser.readDeclaration_expressions = function(STREAM,INDEX,STATE)
	local assigment,expression,expressions,index,token;
	token,index = paser.readToken(STREAM,INDEX);
	if helper.filterArray({token.class},paser.STREAM_TABLE.ASSIGNMENT.INITIALIZATION) == true then
		assigment = token.class;
		expressions = {};
		index = index + 1;
		while true do
			token,index = paser.readToken(STREAM,index);
			expression,index = paser.composeExpression(STREAM,index,STATE,"INLINE");
			table.insert(expressions,paser.createNode("EXPRESSION",token.lexeme,token.line,token.column,{value = expression}));
			token,index = paser.readToken(STREAM,index);
			if token.class ~= "COMMA" then break; end;
			index = index + 1;
		end;
	else
		assigment = nil;
		expressions = nil;
	end;
	return assigment,expressions,index;
end;
