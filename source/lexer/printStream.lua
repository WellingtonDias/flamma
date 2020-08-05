lexer.printStream = function(STREAM)
	for i = 1, #STREAM do
		print("TYPE: " .. STREAM[i].type .. " | LEXEME: \"" .. STREAM[i].lexeme .. "\" | LINE: " .. STREAM[i].line .. " | COLUMN: " .. STREAM[i].column);
	end;
end;
