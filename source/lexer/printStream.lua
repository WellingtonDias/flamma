lexer.printStream = function(STREAM)
	for i = 1, #STREAM do
		lexer.printToken(STREAM[i]);
	end;
end;
