lexer.readWord = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,lexeme;
	lexeme = "";
	index = INDEX;
	column = COLUMN;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if not helper.filterString(character,lexer.TABLE.WORD_EXTENDED) then break end;
		lexeme = lexeme .. character;
		index = index + 1;
		column = column + 1;
	end;
		if helper.filterArray({lexeme},lexer.TABLE.KEYWORD_GENERAL) then return {type = string.upper(lexeme),lexeme = lexeme,line = LINE,column = COLUMN},index,column;
		elseif helper.filterArray({lexeme},lexer.TABLE.KEYWORD_TYPE) then return {type = "TYPE",value = lexeme,lexeme = lexeme,line = LINE,column = COLUMN},index,column;
		elseif (lexeme == "false") then return {type = "BOOLEAN",value = false,lexeme = lexeme,line = LINE,column = COLUMN},index,column;
		elseif (lexeme == "true") then return {type = "BOOLEAN",value = true,lexeme = lexeme,line = LINE,column = COLUMN},index,column;
		else return {type = "WORD",value = lexeme,lexeme = lexeme,line = LINE,column = COLUMN},index,column;
	end;
end;
