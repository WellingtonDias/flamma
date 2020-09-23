local lexer = {};

lexer.TABLE =
{
	KEYWORD =
	{
		"global","thread","local","public","protected","private",
		"constant","variable",
		"null",
		"not","and","or","xor"
	},
	WORD = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",
	WORD_EXTENDED = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-",
	NUMBER = "0123456789",
	NUMBER_EXTENDED = "0123456789.",
	PUNCTUATION = " ()[]{}.,:;=+-*/%<!>"
};

lexer.createToken = function(CLASS,LEXEME,LINE,COLUMN,VALUE)
	local token;
	token = {class = CLASS,lexeme = LEXEME,line = LINE,column = COLUMN};
	if VALUE ~= nil then token.value = VALUE; end;
	return token;
end;

lexer.readComment = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,value;
	value = "";
	index = INDEX + 1;
	column = COLUMN + 1;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if character == "\n" then break; end;
		index = index + 1;
		column = column + 1;
		if character == "#" then break; end;
		value = value .. character;
	end;
	return lexer.createToken("COMMENT",string.sub(STREAM,INDEX,index - 1),LINE,COLUMN,value),index,column;
end;

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

lexer.readNumber = function(STREAM,INDEX,LINE,COLUMN)
	local character,column,index,lexeme,value;
	lexeme = "";
	index = INDEX;
	column = COLUMN;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if helper.filterString(character,lexer.TABLE.NUMBER_EXTENDED) == false then break; end;
		lexeme = lexeme .. character;
		index = index + 1;
		column = column + 1;
	end;
	value = tonumber(lexeme);
	if value ~= nil then return lexer.createToken("NUMBER",lexeme,LINE,COLUMN,value),index,column;
	else return lexer.createToken("INVALID_NUMBER",lexeme,LINE,COLUMN),index,column;
	end;
end;

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

lexer.readPunctuation = function(STREAM,INDEX,LINE,COLUMN)
	local class,column,index,lexeme;
	index = INDEX + 3;
	column = COLUMN + 3;
	lexeme = string.sub(STREAM,INDEX,index);
	if lexeme == " += " then class = "PLUS-EQUAL";
	elseif lexeme == " -= " then class = "MINUS-EQUAL";
	elseif lexeme == " *= " then class = "ASTERISK-EQUAL";
	elseif lexeme == " /= " then class = "SLASH-EQUAL";
	elseif lexeme == " %= " then class = "PERCENT-EQUAL";
	elseif lexeme == " := " then class = "COLON-EQUAL";
	elseif lexeme == " << " then class = "LESS";
	elseif lexeme == " <= " then class = "LESS-EQUAL";
	elseif lexeme == " == " then class = "DOUBLE-EQUAL";
	elseif lexeme == " != " then class = "NOT-EQUAL";
	elseif lexeme == " >= " then class = "GREATER-EQUAL";
	elseif lexeme == " >> " then class = "GREATER";
	else
		index = index - 1;
		column = column - 1;
		lexeme = string.sub(STREAM,INDEX,index);
		if lexeme == " = " then class = "EQUAL";
		elseif lexeme == " + " then class = "PLUS";
		elseif lexeme == " - " then class = "MINUS";
		elseif lexeme == " * " then class = "ASTERISK";
		elseif lexeme == " / " then class = "SLASH";
		elseif lexeme == " % " then class = "PERCENT";
		else
			index = index - 2;
			column = column - 2;
			lexeme = string.sub(STREAM,INDEX,index);
			if lexeme == " " then class = "SPACE";
			elseif lexeme == "(" then class = "PARENTHESIS_OPEN";
			elseif lexeme == ")" then class = "PARENTHESIS_CLOSE";
			elseif lexeme == "[" then class = "BRACKET_OPEN";
			elseif lexeme == "]" then class = "BRACKET_CLOSE";
			elseif lexeme == "{" then class = "BRACE_OPEN";
			elseif lexeme == "}" then class = "BRACE_CLOSE";
			elseif lexeme == "." then class = "DOT";
			elseif lexeme == "," then class = "COMMA";
			elseif lexeme == ":" then class = "COLON";
			elseif lexeme == ";" then class = "SEMICOLON";
			elseif lexeme == "+" then class = "POSITIVE";
			elseif lexeme == "-" then class = "NEGATIVE";
			else class = "INVALID_PUNCTUATION";
			end;
		end;
	end;
	return lexer.createToken(class,lexeme,LINE,COLUMN),index + 1,column + 1;
end;

lexer.composeStream = function(STREAM)
	local character,column,index,line,stream,token;
	stream = {};
	index = 1;
	line = 1;
	column = 1;
	while index <= #STREAM do
		character = string.sub(STREAM,index,index);
		if helper.filterString(character,lexer.TABLE.WORD) == true then token,index,column = lexer.readWord(STREAM,index,line,column);
		elseif helper.filterString(character,lexer.TABLE.NUMBER) == true then token,index,column = lexer.readNumber(STREAM,index,line,column);
		elseif helper.filterString(character,lexer.TABLE.PUNCTUATION) == true then token,index,column = lexer.readPunctuation(STREAM,index,line,column);
		elseif character == "#" then token,index,column = lexer.readComment(STREAM,index,line,column);
		elseif character == "\"" then token,index,column = lexer.readString(STREAM,index,line,column);
		else
			if character == "\t" then token = lexer.createToken("HORIZONTAL_TAB","\\t",line,column);
			elseif character == "\r" then token = lexer.createToken("CARRIAGE_RETURN","\\r",line,column);
			elseif character == "\n" then
				token = lexer.createToken("LINE_FEED","\\n",line,column);
				line = line + 1;
				column = 0;
			else token = lexer.createToken("INVALID_CHARACTER",character,line,column);
			end;
			index = index + 1;
			column = column + 1;
		end;
		table.insert(stream,token);
	end;
	if #stream == 0 then helper.throwError("empty script"); end;
	return stream;
end;

lexer.createStream = function(STREAM)
	return lexer.composeStream(STREAM);
end;

lexer.printToken = function(TOKEN)
	print("CLASS: " .. TOKEN.class .. " | LEXEME: \"" .. TOKEN.lexeme .. "\" | LINE: " .. TOKEN.line .. " | COLUMN: " .. TOKEN.column);
end;

lexer.printStream = function(STREAM)
	for i = 1, #STREAM do
		lexer.printToken(STREAM[i]);
	end;
end;
