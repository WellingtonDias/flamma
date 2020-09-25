paser.throwError = function(MESSAGE,TOKEN)
	helper.throwError(MESSAGE .. " at lexeme: \"" .. TOKEN.lexeme .. "\", line: " .. TOKEN.line .. ", column: " .. TOKEN.column);
end;
