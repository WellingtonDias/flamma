paser.readDeclaration_identifiers = function(STREAM,INDEX)
	local identifiers,index,name,token,type;
	identifiers = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "WORD" then
			break;
		end;
		name = token;
		token,index = paser.readToken(STREAM,index + 1);
		if token.class == "COLON" then
			token,index = paser.readToken(STREAM,index + 1);
			if token.class ~= "WORD" then
				paser.throwError("invalid declaration, expected a type name",token);
			end;
			type = token.value;
			token,index = paser.readToken(STREAM,index + 1);
		else type = "Undefined";
		end;
		table.insert(identifiers,paser.createNode("IDENTIFIER",name.lexeme,name.line,name.column,{name = name.value,type = type}));
		if token.class ~= "COMMA" then
			break;
		end;
		index = index + 1;
	end;
	if #identifiers == 0 then
		paser.throwError("invalid declaration, expected a identifier name",token);
	end;
	return identifiers,index;
end;
