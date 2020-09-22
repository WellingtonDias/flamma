paser.filterExpression = function(STREAM,TYPE)
	local currentToken,previousToken;
	previousToken = {class = "START"};
	for i = 1, #STREAM do
		currentToken = STREAM[i];
		if not helper.filterArray({previousToken.class},paser.FILTER_TABLE[TYPE][currentToken.class]) then paser.throwError("Bad formatted expression",currentToken); end;
		previousToken = currentToken;
	end;
end;
