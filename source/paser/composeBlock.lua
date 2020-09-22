paser.composeBlock = function(STREAM,INDEX,STATE)
	local block,index,statement,token;
	block = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["ROUTINE"]) or (STATE.type == "CLASS" and helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["CLASS"])) then statement,index = paser.readDeclaration(STREAM,index,STATE,token.line,token.column);
		else break;
		end;
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "SEMICOLON" then paser.throwError("Bad formatted statement, expected a \";\"",token); end;
		table.insert(block,statement);
		index = index + 1;
	end;
	if #block == 0 then paser.throwError("Bad formatted block, empty construction",token); end;
	return block,index;
end;
