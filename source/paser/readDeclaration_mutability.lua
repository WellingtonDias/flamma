paser.readDeclaration_mutability = function(STREAM,INDEX)
	local index,token;
	token,index = paser.readToken(STREAM,INDEX);
	if not helper.filterArray({token.class},paser.STREAM_TABLE.MUTABILITY) then paser.throwError("Bad formatted declaration, expected a modifier name",token); end;
	return token.class,index + 1;
end;
