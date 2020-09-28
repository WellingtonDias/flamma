local paser = {};


paser.STREAM_TABLE =
{
	IGNORED = {"COMMENT","SPACE","HORIZONTAL_TAB","CARRIAGE_RETURN","LINE_FEED"},
	INVALID = {"INVALID_CHARACTER","INVALID_NUMBER","INVALID_STRING","INVALID_PUNCTUATION"},
	SCOPE =
	{
		ROUTINE = {"GLOBAL","THREAD","LOCAL"},
		CLASS = {"PUBLIC","PRETECTED","PRIVATE"}
	},
	MODIFIER = {"CONSTANT","VARIABLE"},
	DECLARATION = {"EQUAL","COLON-EQUAL"},
	ASSIGNMENT = {"EQUAL","PLUS-EQUAL","MINUS-EQUAL","ASTERISK-EQUAL","SLASH-EQUAL","PERCENT-EQUAL"},
	EXPRESSION =
	{
		["EXTENDED"] =
		{
			"PARENTHESIS_OPEN","PARENTHESIS_CLOSE",
			"NULL","BOOLEAN","NUMBER","STRING","WORD",
			"NOT","AND","OR","XOR",
			"POSITIVE","NEGATIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		},
		["REDUCED"] = {"WORD","DOT"}
	}
};
table.insert(paser.STREAM_TABLE.SCOPE.CLASS,paser.STREAM_TABLE.SCOPE.ROUTINE);


paser.FILTER_TABLE =
{
	["EXTENDED"] =
	{
		["PARENTHESIS_OPEN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["PARENTHESIS_CLOSE"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","FIELD"},
		["NULL"] = {"START","PARENTHESIS_OPEN","DOUBLE-EQUAL","NOT-EQUAL"},
		["BOOLEAN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
		["NUMBER"] = {"START","PARENTHESIS_OPEN","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["STRING"] = {"START","PARENTHESIS_OPEN","PLUS","DOUBLE-EQUAL","NOT-EQUAL"},
		["FIELD"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","DOT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["NOT"] = {"START","PARENTHESIS_OPEN","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
		["AND"] = {"PARENTHESIS_CLOSE","BOOLEAN","FIELD"},
		["OR"] = {"PARENTHESIS_CLOSE","BOOLEAN","FIELD"},
		["XOR"] = {"PARENTHESIS_CLOSE","BOOLEAN","FIELD",},
		["POSITIVE"] = {"START","PARENTHESIS_OPEN","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["NEGATIVE"] = {"START","PARENTHESIS_OPEN","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["PLUS"] = {"PARENTHESIS_CLOSE","NUMBER","STRING","FIELD"},
		["MINUS"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD",},
		["ASTERISK"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD"},
		["SLASH"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD"},
		["PERCENT"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD"},
		["DOT"] = {"FIELD"},
		["LESS"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD"},
		["LESS-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD"},
		["DOUBLE-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","FIELD"},
		["NOT-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","FIELD"},
		["GREATER-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD"},
		["GREATER"] = {"PARENTHESIS_CLOSE","NUMBER","FIELD"}
	},
	["REDUCED"] =
	{
		["FIELD"] = {"START","DOT"},
		["DOT"] = {"FIELD"}
	}
};


paser.RPN_TABLE =
{
	GROUP = {"PARENTHESIS_OPEN","PARENTHESIS_CLOSE"},
	OPERAND = {"NULL","BOOLEAN","NUMBER","STRING","FIELD"},
	OPERATOR =
	{
		"NOT","AND","OR","XOR",
		"POSITIVE","NEGATIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT",
		"DOT",
		"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
	},
	PRECEDENCE =
	{
		["DOT"] = {8,"LEFT"},
		["NOT"] = {7,"RIGHT"},
		["POSITIVE"] = {7,"RIGHT"},
		["NEGATIVE"] = {7,"RIGHT"},
		["ASTERISK"] = {6,"LEFT"},
		["SLASH"] = {6,"LEFT"},
		["PERCENT"] = {6,"LEFT"},
		["PLUS"] = {5,"LEFT"},
		["MINUS"] = {5,"LEFT"},
		["LESS"] = {4,"LEFT"},
		["LESS-EQUAL"] = {4,"LEFT"},
		["GREATER-EQUAL"] = {4,"LEFT"},
		["GREATER"] = {4,"LEFT"},
		["DOUBLE-EQUAL"] = {3,"LEFT"},
		["NOT-EQUAL"] = {3,"LEFT"},
		["AND"] = {2,"LEFT"},
		["XOR"] = {1,"LEFT"},
		["OR"] = {0,"LEFT"}
	};
};


paser.throwError = function(MESSAGE,TOKEN)
	helper.throwError(MESSAGE .. " at lexeme: \"" .. TOKEN.lexeme .. "\", line: " .. TOKEN.line .. ", column: " .. TOKEN.column);
end;


paser.readToken = function(STREAM,INDEX)
	local index,token;
	index = INDEX;
	while index <= #STREAM do
		token = STREAM[index];
		if helper.filterArray({token.class},paser.STREAM_TABLE.INVALID) == true then
			paser.throwError("invalid token in the script",token);
		end;
		if helper.filterArray({token.class},paser.STREAM_TABLE.IGNORED) == false then
			return token,index;
		end;
		index = index + 1;
	end;
	return lexer.createToken("END","EOF",STREAM[#STREAM].line,STREAM[#STREAM].column + 1),index;
end;


paser.createNode = function(CLASS,LEXEME,LINE,COLUMN,TABLE)
	local node;
	node = {class = CLASS,lexeme = LEXEME,line = LINE,column = COLUMN};
	if TABLE ~= nil then
		for key,value in pairs(TABLE) do
			node[key] = value;
		end;
	end;
	return node;
end;


paser.filterExpression = function(EXPRESSION,TYPE)
	local currentNode,previousNode;
	previousNode = {class = "START"};
	for i = 1, #EXPRESSION do
		currentNode = EXPRESSION[i];
		if helper.filterArray({previousNode.class},paser.FILTER_TABLE[TYPE][currentNode.class]) == false then
			paser.throwError("invalid token in the expression",currentNode);
		end;
		previousNode = currentNode;
	end;
end;


paser.formatExpression = function(EXPRESSION)
	local expression,node,stack;
	expression = {};
	stack = {};
	for i = 1, #EXPRESSION do
		node = EXPRESSION[i];
		if helper.filterArray({node.class},paser.RPN_TABLE.GROUP) == true then
			if node.class == "PARENTHESIS_OPEN" then
				table.insert(stack,1,node);
			elseif node.class == "PARENTHESIS_CLOSE" then
				while true do
					if #stack == 0 then
						paser.throwError("invalid token in the expression",node);
					end;
					if stack[1].class == "PARENTHESIS_OPEN" then
						table.remove(stack,1);
						break;
					end;
					table.insert(expression,table.remove(stack,1));
				end;
			end;
		elseif helper.filterArray({node.class},paser.RPN_TABLE.OPERAND) == true then
			table.insert(expression,node);
		elseif helper.filterArray({node.class},paser.RPN_TABLE.OPERATOR) == true then
			if (#stack == 0) or (stack[1].class == "PARENTHESIS_OPEN") then
				table.insert(stack,1,node);
			elseif (paser.OPERATOR_TABLE[node.class][1] > paser.OPERATOR_TABLE[stack[1].class][1]) or ((paser.OPERATOR_TABLE[node.class][1] == paser.OPERATOR_TABLE[stack[1].class][1]) and (paser.OPERATOR_TABLE[node.class][2] == "RIGHT")) then
				table.insert(stack,1,node);
			else
				while (#stack > 0) and (stack[1].class ~= "PARENTHESIS_OPEN") and ((paser.OPERATOR_TABLE[node.class][1] < paser.OPERATOR_TABLE[stack[1].class][1]) or ((paser.OPERATOR_TABLE[node.class][1] == paser.OPERATOR_TABLE[stack[1].class][1]) and (paser.OPERATOR_TABLE[node.class][2] == "LEFT"))) do
					table.insert(expression,table.remove(stack,1));
				end;
				table.insert(stack,1,node);
			end;
		end;
	end;
	while #stack > 0 do
		node = table.remove(stack,1);
		if helper.filterArray({node.class},paser.RPN_TABLE.GROUP) == true then
			paser.throwError("invalid token in the expression",node);
		end;
		table.insert(expression,node);
	end;
	return expression;
end;


paser.composeExpression = function(STREAM,INDEX,TYPE)
	local expression,index,node,token;
	expression = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if helper.filterArray({token.class},paser.STREAM_TABLE.EXPRESSION[TYPE]) == false then
			break;
		elseif token.class == "WORD" then
			node = paser.createNode("FIELD",token.lexeme,token.line,token.column,{value = token.value});
		elseif token.value ~= nil then
			node = paser.createNode(token.class,token.lexeme,token.line,token.column,{value = token.value});
		else
			node = paser.createNode(token.class,token.lexeme,token.line,token.column);
		end;
		table.insert(expression,node);
		index = index + 1;
	end;
	if #expression == 0 then
		paser.throwError("invalid token in the expression",token);
	end;
	paser.filterExpression(expression,TYPE);
	expression = paser.formatExpression(expression);
	return expression,index;
end;


paser.composeExpressions = function(STREAM,INDEX,TYPE)
	local expression,expressions,index,token;
	expressions = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		expression,index = paser.composeExpression(STREAM,index,TYPE);
		table.insert(expressions,paser.createNode("EXPRESSION",token.lexeme,token.line,token.column,{value = expression}));
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "COMMA" then
			break;
		end;
		index = index + 1;
	end;
	return expressions,index;
end;


paser.composeIdentifiers = function(STREAM,INDEX)
	local identifiers,index,name,token,type;
	identifiers = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "WORD" then
			paser.throwError("invalid token in the declaration, expected a identifier name",token);
		end;
		name = token;
		token,index = paser.readToken(STREAM,index + 1);
		if token.class == "COLON" then
			token,index = paser.readToken(STREAM,index + 1);
			if token.class ~= "WORD" then
				paser.throwError("invalid token in the declaration, expected a type name",token);
			end;
			type = token.value;
			token,index = paser.readToken(STREAM,index + 1);
		else
			type = "Undefined";
		end;
		table.insert(identifiers,paser.createNode("IDENTIFIER",name.lexeme,name.line,name.column,{name = name.value,type = type}));
		if token.class ~= "COMMA" then
			break;
		end;
		index = index + 1;
	end;
	return identifiers,index;
end;


paser.readDeclaration = function(STREAM,INDEX)
	local expressions,first,identifiers,index,modifier,operator,scope,token;
	first,index = paser.readToken(STREAM,INDEX);
	scope = first.class;
	token,index = paser.readToken(STREAM,index + 1);
	if helper.filterArray({token.class},paser.STREAM_TABLE.MODIFIER) == false then
		paser.throwError("invalid token in the declaration, expected a modifier name",token);
	end;
	modifier = token.class;
	identifiers,index = paser.composeIdentifiers(STREAM,index + 1);
	token,index = paser.readToken(STREAM,index);
	if helper.filterArray({token.class},paser.STREAM_TABLE.DECLARATION) == true then
		operator = token.class;
		expressions,index = paser.composeExpressions(STREAM,index + 1,"EXTENDED");
		return paser.createNode("INITIALIZATION",first.lexeme,first.line,first.column,{scope = scope,modifier = modifier,identifiers = identifiers,operator = operator,expressions = expressions}),index;
	else
		return paser.createNode("DECLARATION",first.lexeme,first.line,first.column,{scope = scope,modifier = modifier,identifiers = identifiers}),index;
	end;
end;


paser.readAssigment = function(STREAM,INDEX)
	local expressions,fields,first,index,operator,token;
	first,index = paser.readToken(STREAM,INDEX);
	fields,index = paser.composeExpressions(STREAM,index,"REDUCED");
	token,index = paser.readToken(STREAM,index);
	if #fields > 1 then
		if token.class ~= "EQUAL" then
			paser.throwError("invalid token in the assigment, expected a equal operator",token);
		end;
	else
		if helper.filterArray({token.class},paser.STREAM_TABLE.ASSIGNMENT) == false then
			paser.throwError("invalid token in the assigment, expected a operator",token);
		end;
	end;
	operator = token.class;
	expressions,index = paser.composeExpressions(STREAM,index + 1,"EXTENDED");
	return paser.createNode("ASSIGNMENT",first.lexeme,first.line,first.column,{fields = fields,operator = operator,expressions = expressions}),index;
end;


paser.composeBlock = function(STREAM,INDEX)
	local block,index,statement,token;
	block = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE.ROUTINE) == true then
			statement,index = paser.readDeclaration(STREAM,index);
		elseif helper.filterArray({token.class},paser.STREAM_TABLE.EXPRESSION["REDUCED"]) == true then
			statement,index = paser.readAssigment(STREAM,index);
		else
			break;
		end;
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "SEMICOLON" then
			paser.throwError("invalid token in the statement, expected a \";\"",token);
		end;
		table.insert(block,statement);
		index = index + 1;
	end;
	if #block == 0 then
		paser.throwError("invalid token in the block",token);
	end;
	return block,index;
end;


paser.createStream = function(STREAM)
	local block,first,index,token;
	first,index = paser.readToken(STREAM,1);
	block,index = paser.composeBlock(STREAM,index);
	token,index = paser.readToken(STREAM,index);
	if token.class ~= "END" then
		paser.throwError("invalid token in the script, expected a EOF",token);
	end;
	return paser.createNode("SCRIPT",first.lexeme,first.line,first.column,{value = block});
end;


paser.printStream = function(NODE,TABULATION)
	local value;
	io.write(string.rep("\t",TABULATION) .. "CLASS: " .. NODE.class);
	if (NODE.class == "SCRIPT") or (NODE.class == "EXPRESSION") then
		io.write("\n");
		for i = 1, #NODE.value do
			paser.printStream(NODE.value[i],TABULATION + 1);
			if i < #NODE.value then
				io.write("\n");
			end;
		end;
		if NODE.class == "SCRIPT" then
			io.write("\n");
		end;
	elseif (NODE.class == "DECLARATION") or (NODE.class == "INITIALIZATION") then
		io.write(" | SCOPE: " .. NODE.scope .. " | MODIFIER: " .. NODE.modifier);
		if NODE.class == "INITIALIZATION" then
			io.write(" | OPERATOR: " .. NODE.operator);
		end;
		io.write("\n" .. string.rep("\t",TABULATION + 1) .. "IDENTIFIERS: " .. "\n");
		for i = 1, #NODE.identifiers do
			paser.printStream(NODE.identifiers[i],TABULATION + 2);
			io.write("\n");
		end;
		if NODE.class == "INITIALIZATION" then
			io.write(string.rep("\t",TABULATION + 1) .. "EXPRESSIONS: " .. "\n");
			for i = 1, #NODE.expressions do
				paser.printStream(NODE.expressions[i],TABULATION + 2);
				if i < #NODE.expressions then
					io.write("\n");
				end;
			end;
		end;
	elseif NODE.class == "ASSIGNMENT" then
		io.write(" | OPERATOR: " .. NODE.operator);
		io.write("\n" .. string.rep("\t",TABULATION + 1) .. "FIELDS: " .. "\n");
		for i = 1, #NODE.fields do
			paser.printStream(NODE.fields[i],TABULATION + 2);
			io.write("\n");
		end;
		io.write(string.rep("\t",TABULATION + 1) .. "EXPRESSIONS: " .. "\n");
		for i = 1, #NODE.expressions do
			paser.printStream(NODE.expressions[i],TABULATION + 2);
			if i < #NODE.expressions then
				io.write("\n");
			end;
		end;
	elseif NODE.class == "IDENTIFIER" then
		io.write(" | NAME: " .. NODE.name .. " | TYPE: " .. NODE.type);
	else
		if NODE.class == "BOOLEAN" then
			if NODE.value == false then
				value = "false";
			else
				value = "true";
			end;
		elseif NODE.class == "STRING" then
			value = "\"" .. NODE.value .. "\""
		else
			value = NODE.value;
		end;
		if value ~= nil then
			io.write(" | VALUE: " .. value);
		end;
	end;
end;
