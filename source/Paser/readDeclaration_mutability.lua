paser.readDeclaration_mutability = function(STREAM,INDEX)
	local index,token;
	token,index = paser.readToken(STREAM,INDEX);
	if helper.filterArray({token.class},paser.STREAM_TABLE.MUTABILITY) == false then
		paser.throwError("invalid declaration, expected a modifier name",token);
	end;
	return token.class,index + 1;
end;
