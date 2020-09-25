lexer.readComment = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,value;
	value = "";
	index = INDEX + 1;
	column = COLUMN + 1;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if character == "\n" then
			break;
		end;
		index = index + 1;
		column = column + 1;
		if character == "#" then
			break;
		end;
		value = value .. character;
	end;
	return lexer.createToken("COMMENT",string.sub(STREAM,INDEX,index - 1),LINE,COLUMN,value),index,column;
end;
