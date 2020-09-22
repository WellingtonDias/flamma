paser.createNode = function(CLASS,LEXEME,LINE,COLUMN,TABLE)
	local node;
	node = {class = CLASS,lexeme = LEXEME,line = LINE,column = COLUMN};
	for key,value in pairs(TABLE) do
		node[key] = value;
	end;
	return node;
end;
