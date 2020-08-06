paser.readBlock = function(STREAM,INDEX,STATE)
	local block,index,statement,token;
	block = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if helper.filterArray({token.type},paser.STREAM_TABLE.SCOPE) then statement,index = paser.readDeclaration(STREAM,index);
		else break;
		end;
		token,index = paser.readToken(STREAM,index);
		if token.type ~= "SEMICOLON" then paser.throwError("Bad formatted statement, expected \";\"",token); end;
		table.insert(block,statement);
		index = index + 1;
	end;
	if #block == 0 then paser.throwError("Bad formatted script, empty block construction",token); end;
	return block,index;
end;
