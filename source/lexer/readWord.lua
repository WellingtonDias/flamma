lexer.readWord = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,lexeme;
	lexeme = "";
	index = INDEX;
	column = COLUMN;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if not helper.filterString(character,lexer.TABLE.WORD_EXTENDED) then break; end;
		lexeme = lexeme .. character;
		index = index + 1;
		column = column + 1;
	end;
	if helper.filterArray({lexeme},lexer.TABLE.KEYWORD_GENERAL) then return lexer.createToken(string.upper(lexeme),nil,lexeme,LINE,COLUMN),index,column;
	elseif (lexeme == "false") then return lexer.createToken("BOOLEAN",false,lexeme,LINE,COLUMN),index,column;
	elseif (lexeme == "true") then return lexer.createToken("BOOLEAN",true,lexeme,LINE,COLUMN),index,column;
	else return lexer.createToken("WORD",lexeme,lexeme,LINE,COLUMN),index,column;
	end;
end;
