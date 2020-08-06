lexer.createToken = function(TYPE,VALUE,LEXEME,LINE,COLUMN)
	return {type = TYPE,value = VALUE,lexeme = LEXEME,line = LINE,column = COLUMN};
end;
