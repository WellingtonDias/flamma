paser.readStream = function(STREAM)
	local block,index,token;
	block,index = paser.readBlock(STREAM,1,"SCRIPT",{});
	token,index = paser.readToken(STREAM,index);
	if token.type ~= "END" then paser.throwError("Bad formatted script, expected EOF",token); end;
	return {type = "SCRIPT",value = block};
end;
