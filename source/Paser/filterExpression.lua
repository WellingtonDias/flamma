paser.filterExpression = function(EXPRESSION,TYPE)
	local currentNode,previousNode;
	previousNode = {class = "START"};
	for i = 1, #EXPRESSION do
		currentNode = EXPRESSION[i];
		if helper.filterArray({previousNode.class},paser.FILTER_TABLE[TYPE][currentNode.class]) == false then paser.throwError("invalid expression",currentNode); end;
		previousNode = currentNode;
	end;
end;
