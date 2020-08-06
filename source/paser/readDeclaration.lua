paser.readDeclaration = function(STREAM,INDEX)
	local identifiers,index,mutability,name,scope,token,type;
	token,index = paser.readToken(STREAM,INDEX);
	scope = token.type;
	token,index = paser.readToken(STREAM,index + 1);
	if not helper.filterArray({token.type},paser.STREAM_TABLE.MUTABILITY) then paser.throwError("Bad formatted declaration, expected a mutability modifier",token); end;
	mutability = token.type;
	identifiers = {};
	while true do
		token,index = paser.readToken(STREAM,index + 1);
		if token.type ~= "WORD" then break; end;
		name = token.value;
		token,index = paser.readToken(STREAM,index + 1);
		if token.type == "COLON" then
			token,index = paser.readToken(STREAM,index + 1);
			if token.type ~= "WORD" then paser.throwError("Bad formatted declaration, expected a type name",token); end;
			type = token.value;
		else type = "Undefined"
		end;
		table.insert(identifiers,{type = "IDENTIFIER",name = name,type = type});
	end;
	if #identifiers == 0 then paser.throwError("Bad formatted declaration, expected a identifier name",token); end;
	return {type = "DECLARATION",scope = scope,mutability = mutability,identifiers = identifiers},index;
end;
