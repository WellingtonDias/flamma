paser.readStatement = function(STREAM,INDEX,TYPE,STACK)
	local index,statement,token;
	token,index = paser.readToken(STREAM,INDEX);
	if helper.filterArray({token.type},paser.STREAM_TABLE.SCOPE) then statement,index = paser.readDeclaration(STREAM,index); end;
	else break;
	token,index = paser.readToken(STREAM,index + 1);
	print(token.type);
	if token.type ~= "SEMICOLON" then paser.throwError("Bad formatted statement, expected \";\"",token); end;
	return statement,index + 1;
end;
