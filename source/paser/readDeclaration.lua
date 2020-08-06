paser.readDeclaration = function(STREAM,INDEX)
	local identifier,index,mutability,scope,type,token;
	token,index = paser.readToken(STREAM,INDEX);
	scope = token.type;
	token,index = paser.readToken(STREAM,index + 1);
	if not helper.filterArray({token.type},paser.STREAM_TABLE.MUTABILITY) then paser.throwError("Bad formatted declaration, expected a mutability modifier",token); end;
	mutability = token.type;
	token,index = paser.readToken(STREAM,index + 1);
	if token.type ~= "WORD" then paser.throwError("Bad formatted declaration, expected a valid identifier name",token); end;
	identifier = token.value;
	token,index = paser.readToken(STREAM,index + 1);
	if token.type == "COLON" then
		token,index = paser.readToken(STREAM,index + 1);
		if token.type ~= "WORD" then paser.throwError("Bad formatted declaration, expected a valid type name",token); end;
		type = token.value;
	end;
	return {type = "DECLARATION",scope = scope,mutability = mutability,type = type,identifier = identifier},index;
end;
