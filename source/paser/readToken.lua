paser.readToken = function(STREAM,INDEX)
	local index,token;
	index = INDEX;
	while index <= #STREAM do
		token = STREAM[index];
		if helper.filterArray({token.type},paser.STREAM_TABLE.INVALID) then paser.throwError("Bad formatted script, invalid token",token); end;
		if not helper.filterArray({token.type},paser.STREAM_TABLE.IGNORABLE) then return token,index; end;
		index = index + 1;
	end;
	return {type = "END"},index;
end;
