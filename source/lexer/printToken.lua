lexer.printToken = function(TOKEN)
	print("TYPE: " .. TOKEN.type .. " | LEXEME: \"" .. TOKEN.lexeme .. "\" | LINE: " .. TOKEN.line .. " | COLUMN: " .. TOKEN.column);
end;
