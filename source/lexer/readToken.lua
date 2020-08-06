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
		if character == "\t" then token = lexer.createToken("HORIZONTAL_TAB",nil,"\\t",LINE,COLUMN);
		elseif character == "\r" then token = lexer.createToken("CARRIAGE_RETURN",nil,"\\r",LINE,COLUMN);
		elseif character == "\n" then
			token = lexer.createToken("LINE_FEED",nil,"\\n",LINE,COLUMN);
			line = LINE + 1;
			column = 0;
		else token = lexer.createToken("INVALID_CHARACTER",nil,character,LINE,COLUMN);
		end;
		index = INDEX + 1;
		column = column + 1;
	end;
	return token,index,line,column;
end;
