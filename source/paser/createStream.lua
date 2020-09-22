paser.createStream = function(STREAM)
	local block,index,token;
	block,index = paser.composeBlock(STREAM,1,{type = "SCRIPT",control = false,stack = {}});
	token,index = paser.readToken(STREAM,index);
	if token.class ~= "END" then paser.throwError("Bad formatted script, expected a EOF",token); end;
	return paser.createNode("SCRIPT",block[1].lexeme,block[1].line,block[1].column,{value = paser.createNode("BLOCK",block[1].lexeme,block[1].line,block[1].column,{value = block})});
end;
