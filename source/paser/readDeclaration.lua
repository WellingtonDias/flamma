paser.readDeclaration = function(STREAM,INDEX)
	local identifier,index,mutability,scope,token,type;
	token,index = paser.readToken(STREAM,INDEX);
	scope = token.type;
	token,index = paser.readToken(STREAM,index + 1);
	if not helper.filterArray({token.type},paser.STREAM_TABLE.MUTABILITY) then paser.throwError("Bad formatted declaration, expected a mutability modifier",token); end;
	mutability = token.type;
	token,index = paser.readToken(STREAM,index + 1);
	if token.type ~= "WORD" then paser.throwError("Bad formatted declaration, expected a identifier name",token); end;
	identifier = token.value;
	token,index = paser.readToken(STREAM,index + 1);
	if token.type == "COLON" then
		token,index = paser.readToken(STREAM,index + 1);
		if token.type ~= "WORD" then paser.throwError("Bad formatted declaration, expected a type name",token); end;
		type = token.value;
	end;
	return {type = "DECLARATION",scope = scope,mutability = mutability,type = type,identifier = identifier},index + 1;
end;
