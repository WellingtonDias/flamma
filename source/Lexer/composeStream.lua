lexer.composeStream = function(STREAM)
	local character,column,index,line,stream,token;
	stream = {};
	index = 1;
	line = 1;
	column = 1;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if helper.filterString(character,lexer.TABLE.WORD) == true then
			token,index,column = lexer.readWord(STREAM,index,line,column);
		elseif helper.filterString(character,lexer.TABLE.NUMBER) == true then
			token,index,column = lexer.readNumber(STREAM,index,line,column);
		elseif helper.filterString(character,lexer.TABLE.PUNCTUATION) == true then
			token,index,column = lexer.readPunctuation(STREAM,index,line,column);
		elseif character == "#" then
			token,index,column = lexer.readComment(STREAM,index,line,column);
		elseif character == "\"" then
			token,index,column = lexer.readString(STREAM,index,line,column);
		else
			if character == "\t" then
				token = lexer.createToken("HORIZONTAL_TAB","\\t",line,column);
			elseif character == "\r" then
				token = lexer.createToken("CARRIAGE_RETURN","\\r",line,column);
			elseif character == "\n" then
				token = lexer.createToken("LINE_FEED","\\n",line,column);
				line = line + 1;
				column = 0;
			else
				token = lexer.createToken("INVALID_CHARACTER",character,line,column);
			end;
			index = index + 1;
			column = column + 1;
		end;
		table.insert(stream,token);
	end;
	if #stream == 0 then
		helper.throwError("empty script");
	end;
	return stream;
end;
