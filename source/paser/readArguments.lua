paser.readArguments = function(STREAM,INDEX,STATE,LINE,COLUMN)
	local expression,index,arguments,token;
	arguments = {};
	index = INDEX + 1;
	while true do
		token,index = paser.readToken(STREAM,index);
		expression,index = paser.composeExpression(STREAM,index,STATE,"INLINE");
		table.insert(arguments,paser.createNode("EXPRESSION",token.lexeme,token.line,token.column,{value = expression}));
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "COMMA" then break; end;
		index = index + 1;
	end;
	if token.class ~= "PARENTHESIS_CLOSE" then paser.throwError("Bad formatted arguments, expected a \")\"",token); end;
	return paser.createNode("ARGUMENTS","(",LINE,COLUMN,{value = arguments}),index;
end;
