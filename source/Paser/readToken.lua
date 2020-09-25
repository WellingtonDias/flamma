paser.readToken = function(STREAM,INDEX)
	local index,token;
	index = INDEX;
	while index <= #STREAM do
		token = STREAM[index];
		if helper.filterArray({token.class},paser.STREAM_TABLE.INVALID) == true then paser.throwError("invalid token",token); end;
		if helper.filterArray({token.class},paser.STREAM_TABLE.IGNORED) == false then return token,index; end;
		index = index + 1;
	end;
	return lexer.createToken("END","",STREAM[#STREAM].line,STREAM[#STREAM].column + 1),index;
end;
