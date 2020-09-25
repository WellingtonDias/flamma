lexer.createToken = function(CLASS,LEXEME,LINE,COLUMN,VALUE)
	local token;
	token = {class = CLASS,lexeme = LEXEME,line = LINE,column = COLUMN};
	if VALUE ~= nil then
		token.value = VALUE;
	end;
	return token;
end;
