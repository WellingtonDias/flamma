lexer.readPunctuation = function(STREAM,INDEX,LINE,COLUMN)
	local class,column,index,lexeme;
	index = INDEX + 3;
	column = COLUMN + 3;
	lexeme = string.sub(STREAM,INDEX,index);
	if lexeme == " += " then
		class = "PLUS-EQUAL";
	elseif lexeme == " -= " then
		class = "MINUS-EQUAL";
	elseif lexeme == " *= " then
		class = "ASTERISK-EQUAL";
	elseif lexeme == " /= " then
		class = "SLASH-EQUAL";
	elseif lexeme == " %= " then
		class = "PERCENT-EQUAL";
	elseif lexeme == " := " then
		class = "COLON-EQUAL";
	elseif lexeme == " << " then
		class = "LESS";
	elseif lexeme == " <= " then
		class = "LESS-EQUAL";
	elseif lexeme == " == " then
		class = "DOUBLE-EQUAL";
	elseif lexeme == " != " then
		class = "NOT-EQUAL";
	elseif lexeme == " >= " then
		class = "GREATER-EQUAL";
	elseif lexeme == " >> " then
		class = "GREATER";
	else
		index = index - 1;
		column = column - 1;
		lexeme = string.sub(STREAM,INDEX,index);
		if lexeme == " = " then
			class = "EQUAL";
		elseif lexeme == " + " then
			class = "PLUS";
		elseif lexeme == " - " then
			class = "MINUS";
		elseif lexeme == " * " then
			class = "ASTERISK";
		elseif lexeme == " / " then
			class = "SLASH";
		elseif lexeme == " % " then
			class = "PERCENT";
		else
			index = index - 2;
			column = column - 2;
			lexeme = string.sub(STREAM,INDEX,index);
			if lexeme == " " then
				class = "SPACE";
			elseif lexeme == "(" then
				class = "PARENTHESIS_OPEN";
			elseif lexeme == ")" then
				class = "PARENTHESIS_CLOSE";
			elseif lexeme == "[" then
				class = "BRACKET_OPEN";
			elseif lexeme == "]" then
				class = "BRACKET_CLOSE";
			elseif lexeme == "{" then
				class = "BRACE_OPEN";
			elseif lexeme == "}" then
				class = "BRACE_CLOSE";
			elseif lexeme == "." then
				class = "DOT";
			elseif lexeme == "," then
				class = "COMMA";
			elseif lexeme == ":" then
				class = "COLON";
			elseif lexeme == ";" then
				class = "SEMICOLON";
			elseif lexeme == "+" then
				class = "POSITIVE";
			elseif lexeme == "-" then
				class = "NEGATIVE";
			else
				class = "INVALID_PUNCTUATION";
			end;
		end;
	end;
	return lexer.createToken(class,lexeme,LINE,COLUMN),index + 1,column + 1;
end;
