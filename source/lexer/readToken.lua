lexer.readToken = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,line,token;
	line = LINE;
	character = string.sub(STREAM,INDEX,INDEX);
	if helper.filterString(character,lexer.TABLE.WORD) then token,index,column = lexer.readWord(STREAM,INDEX,LINE,COLUMN);
	elseif helper.filterString(character,lexer.TABLE.NUMBER) then token,index,column = lexer.readNumber(STREAM,INDEX,LINE,COLUMN);
	elseif helper.filterString(character,lexer.TABLE.PUNCTUATION) then token,index,column = lexer.readPunctuation(STREAM,INDEX,LINE,COLUMN);
	elseif character == "#" then token,index,column = lexer.readComment(STREAM,INDEX,LINE,COLUMN);
	elseif character == "\"" then token,index,column = lexer.readString(STREAM,INDEX,LINE,COLUMN);
	else
		column = COLUMN;
		if character == "\t" then token = {type = "HORIZONTAL_TAB",lexeme = "\\t",line = LINE,column = COLUMN};
		elseif character == "\r" then token = {type = "CARRIAGE_RETURN",lexeme = "\\r",line = LINE,column = COLUMN};
		elseif character == "\n" then
			token = {type = "LINE_FEED",lexeme = "\\n",line = LINE,column = COLUMN};
			line = LINE + 1;
			column = 0;
		else token = {type = "INVALID_TOKEN",lexeme = character,line = LINE,column = COLUMN};
		end;
		index = INDEX + 1;
		column = column + 1;
	end;
	return token,index,line,column;
end;
