lexer.readNumber = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,lexeme,value;
	lexeme = "";
	index = INDEX;
	column = COLUMN;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if not helper.filterString(character,lexer.TABLE.NUMBER_EXTENDED) then break end;
		lexeme = lexeme .. character;
		index = index + 1;
		column = column + 1;
	end;
	value = tonumber(lexeme);
	if value then return {type = "NUMBER",value = value,lexeme = lexeme,line = LINE,column = COLUMN},index,column;
	else return {type = "INVALID_NUMBER",lexeme = lexeme,line = LINE,column = COLUMN},index,column;
	end;
end;
