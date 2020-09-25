lexer.readWord = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,lexeme;
	lexeme = "";
	index = INDEX;
	column = COLUMN;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if helper.filterString(character,lexer.TABLE.WORD_EXTENDED) == false then break; end;
		lexeme = lexeme .. character;
		index = index + 1;
		column = column + 1;
	end;
	if helper.filterArray({lexeme},lexer.TABLE.KEYWORD) == true then return lexer.createToken(string.upper(lexeme),lexeme,LINE,COLUMN),index,column;
	elseif lexeme == "false" then return lexer.createToken("BOOLEAN",lexeme,LINE,COLUMN,false),index,column;
	elseif lexeme == "true" then return lexer.createToken("BOOLEAN",lexeme,LINE,COLUMN,true),index,column;
	else return lexer.createToken("WORD",lexeme,LINE,COLUMN,lexeme),index,column;
	end;
end;
