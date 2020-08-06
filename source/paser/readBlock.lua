paser.readBlock = function(STREAM,INDEX,TYPE,STACK)
	local block,index,statement,token;
	block = {};
	token,index = paser.readToken(STREAM,INDEX);
	while index <= #STREAM do
		statement,index = paser.readStatement(STREAM,index,TYPE,STACK);
		table.insert(block,statement);
	end;
	if #block == 0 then paser.throwError("Bad formatted script, empty block construction",token); end;
	return block,index;
end;
