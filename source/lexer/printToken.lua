lexer.printToken = function(TOKEN)
	print("CLASS: " .. TOKEN.class .. " | LEXEME: \"" .. TOKEN.lexeme .. "\" | LINE: " .. TOKEN.line .. " | COLUMN: " .. TOKEN.column);
end;
