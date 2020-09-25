lexer.readString = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,lexeme,value;
	value = "";
	index = INDEX + 1;
	column = COLUMN + 1;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		index = index + 1;
		column = column + 1;
		if character == "\"" then break; end;
		value = value .. character;
	end;
	lexeme = string.sub(STREAM,INDEX,index - 1);
	if character == "\"" then return lexer.createToken("STRING",lexeme,LINE,COLUMN,value),index,column;
	else return lexer.createToken("INVALID_STRING",lexeme,LINE,COLUMN),index,column;
	end;
end;
