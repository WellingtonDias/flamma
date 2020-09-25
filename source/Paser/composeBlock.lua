paser.composeBlock = function(STREAM,INDEX,STATE)
	local block,index,statement,token;
	block = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if (helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["ROUTINE"]) == true) or (STATE.type == "CLASS" and helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["CLASS"]) == true) then
			statement,index = paser.readDeclaration(STREAM,index,STATE,token.line,token.column);
		else
			break;
		end;
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "SEMICOLON" then
			paser.throwError("invalid statement, expected a \";\"",token);
		end;
		table.insert(block,statement);
		index = index + 1;
	end;
	if #block == 0 then
		paser.throwError("empty block",token);
	end;
	return block,index;
end;
