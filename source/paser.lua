local paser = {};

paser.STREAM_TABLE =
{
	IGNORED = {"COMMENT","SPACE","HORIZONTAL_TAB","CARRIAGE_RETURN","LINE_FEED"},
	INVALID = {"INVALID_CHARACTER","INVALID_NUMBER","INVALID_STRING","INVALID_PUNCTUATION"},
	SCOPE =
	{
		["ROUTINE"] = {"GLOBAL","THREAD","LOCAL"},
		["CLASS"] = {"PUBLIC","PRETECTED","PRIVATE"}
	},
	MUTABILITY = {"CONSTANT","VARIABLE"},
	ASSIGNMENT =
	{
		INITIALIZATION = {"EQUAL","COLON-EQUAL"},
		EXPRESSION = {"EQUAL","PLUS-EQUAL","MINUS-EQUAL","ASTERISK-EQUAL","SLASH-EQUAL","PERCENT-EQUAL"}
	},
	EXPRESSION =
	{
		["INLINE"] =
		{
			"PARENTHESIS_OPEN","PARENTHESIS_CLOSE",
			"NULL","BOOLEAN","NUMBER","STRING","WORD",
			"NOT","AND","OR","XOR",
			"POSITIVE","NEGATIVE",
			"PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		},
		["STATEMENT"] = {"EQUAL","PLUS-EQUAL","MINUS-EQUAL","ASTERISK-EQUAL","SLASH-EQUAL","PERCENT-EQUAL"},
		COMPOUND = {"ENTITY","ARGUMENTS"}
	}
};

table.insert(paser.STREAM_TABLE.SCOPE["CLASS"],paser.STREAM_TABLE.SCOPE["ROUTINE"]);
table.insert(paser.STREAM_TABLE.EXPRESSION["STATEMENT"],paser.STREAM_TABLE.EXPRESSION["INLINE"]);

paser.FILTER_TABLE =
{
	["INLINE"] =
	{
		["PARENTHESIS_OPEN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["PARENTHESIS_CLOSE"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","ENTITY","ARGUMENTS"},
		["NULL"] = {"START","PARENTHESIS_OPEN","DOUBLE-EQUAL","NOT-EQUAL"},
		["BOOLEAN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
		["NUMBER"] = {"START","PARENTHESIS_OPEN","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["STRING"] = {"START","PARENTHESIS_OPEN","PLUS","DOUBLE-EQUAL","NOT-EQUAL"},
		["ENTITY"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","DOT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["ARGUMENTS"] = {"ENTITY","ARGUMENTS"},
		["NOT"] = {"START","PARENTHESIS_OPEN","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
		["AND"] = {"PARENTHESIS_CLOSE","BOOLEAN","ENTITY","ARGUMENTS"},
		["OR"] = {"PARENTHESIS_CLOSE","BOOLEAN","ENTITY","ARGUMENTS"},
		["XOR"] = {"PARENTHESIS_CLOSE","BOOLEAN","ENTITY","ARGUMENTS"},
		["POSITIVE"] = {"START","PARENTHESIS_OPEN","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["NEGATIVE"] = {"START","PARENTHESIS_OPEN","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["PLUS"] = {"PARENTHESIS_CLOSE","NUMBER","STRING","ENTITY","ARGUMENTS"},
		["MINUS"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"},
		["ASTERISK"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"},
		["SLASH"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"},
		["PERCENT"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"},
		["DOT"] = {"ENTITY","ARGUMENTS"},
		["LESS"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"},
		["LESS-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"},
		["DOUBLE-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","ENTITY","ARGUMENTS"},
		["NOT-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","ENTITY","ARGUMENTS"},
		["GREATER-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"},
		["GREATER"] = {"PARENTHESIS_CLOSE","NUMBER","ENTITY","ARGUMENTS"}
	}
};

paser.RPN_TABLE =
{
	GROUP = {"PARENTHESIS_OPEN","PARENTHESIS_CLOSE"},
	OPERAND = {"NULL","BOOLEAN","NUMBER","STRING","ENTITY","ARGUMENTS"},
	OPERATOR =
	{
		"EQUAL","EQUAL-PLUS","EQUAL-MINUS","EQUAL-ASTERISK","EQUAL-SLASH","EQUAL-PERCENT",
		"NOT","AND","OR","XOR",
		"POSITIVE","NEGATIVE",
		"PLUS","MINUS","ASTERISK","SLASH","PERCENT",
		"DOT",
		"LESS","LESS-EQUAL","EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
	}
};

paser.OPERATOR_TABLE =
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
	["EQUAL"] = {3,"LEFT"},
	["NOT-EQUAL"] = {3,"LEFT"},
	["AND"] = {2,"LEFT"},
	["OR"] = {1,"LEFT"}
};

paser.throwError = function(MESSAGE,TOKEN)
	helper.throwError(MESSAGE .. " at lexeme: \"" .. TOKEN.lexeme .. "\", line: " .. TOKEN.line .. ", column: " .. TOKEN.column);
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

paser.readToken = function(STREAM,INDEX)
	local index,token;
	index = INDEX;
	while index <= #STREAM do
		token = STREAM[index];
		if helper.filterArray({token.class},paser.STREAM_TABLE.INVALID) == true then paser.throwError("invalid token",token); end;
		if helper.filterArray({token.class},paser.STREAM_TABLE.IGNORED) == false then return token,index; end;
		index = index + 1;
	end;
	return lexer.createToken("END","",STREAM[#STREAM].line,STREAM[#STREAM].column + 1),index;
end;

paser.readArguments = function(STREAM,INDEX,STATE,LINE,COLUMN)
	local expression,index,arguments,token;
	arguments = {};
	index = INDEX + 1;
	while true do
		token,index = paser.readToken(STREAM,index);
		expression,index = paser.composeExpression(STREAM,index,STATE,"INLINE");
		table.insert(arguments,paser.createNode("EXPRESSION",token.lexeme,token.line,token.column,{value = expression}));
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "COMMA" then break; end;
		index = index + 1;
	end;
	if token.class ~= "PARENTHESIS_CLOSE" then paser.throwError("invalid arguments, expected a \")\"",token); end;
	return paser.createNode("ARGUMENTS","(",LINE,COLUMN,{value = arguments}),index;
end;

paser.formatExpression = function(EXPRESSION)
	local expression,node,stack;
	expression = {};
	stack = {};
	for i = 1, #EXPRESSION do
		node = EXPRESSION[i];
		if helper.filterArray({node.class},paser.RPN_TABLE.GROUP) == true then
			if node.class == "PARENTHESIS_OPEN" then table.insert(stack,1,node);
			elseif node.class == "PARENTHESIS_CLOSE" then
				while true do
					if #stack == 0 then paser.throwError("invalid expression",node); end;
					if stack[1].class == "PARENTHESIS_OPEN" then
						table.remove(stack,1);
						break;
					end;
					table.insert(expression,table.remove(stack,1));
				end;
			end;
		elseif helper.filterArray({node.class},paser.RPN_TABLE.OPERAND) == true then table.insert(expression,node);
		elseif helper.filterArray({node.class},paser.RPN_TABLE.OPERATOR) == true then
			if (#stack == 0) or (stack[1].class == "PARENTHESIS_OPEN") then table.insert(stack,1,node);
			elseif (paser.OPERATOR_TABLE[node.class][1] > paser.OPERATOR_TABLE[stack[1].class][1]) or ((paser.OPERATOR_TABLE[node.class][1] == paser.OPERATOR_TABLE[stack[1].class][1]) and (paser.OPERATOR_TABLE[node.class][2] == "RIGHT")) then table.insert(stack,1,node);
			else
				while (#stack > 0) and (stack[1].class ~= "PARENTHESIS_OPEN") and ((paser.OPERATOR_TABLE[node.class][1] < paser.OPERATOR_TABLE[stack[1].class][1]) or ((paser.OPERATOR_TABLE[node.class][1] == paser.OPERATOR_TABLE[stack[1].class][1]) and (paser.OPERATOR_TABLE[node.class][2] == "LEFT"))) do table.insert(expression,table.remove(stack,1)); end;
				table.insert(stack,1,node);
			end;
		end;
	end;
	helper.printTable(stack);
	while #stack > 0 do
		node = table.remove(stack,1);
		if helper.filterArray({node.class},paser.RPN_TABLE.GROUP) == true then paser.throwError("Invalid expression",node); end;
		table.insert(expression,node);
	end;
	return expression;
end;

paser.filterExpression = function(EXPRESSION,TYPE)
	local currentNode,previousNode;
	previousNode = {class = "START"};
	for i = 1, #EXPRESSION do
		currentNode = EXPRESSION[i];
		if helper.filterArray({previousNode.class},paser.FILTER_TABLE[TYPE][currentNode.class]) == false then paser.throwError("invalid expression",currentNode); end;
		previousNode = currentNode;
	end;
end;

paser.composeExpression = function(STREAM,INDEX,STATE,TYPE)
	local expression,index,node,token;
	expression = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if helper.filterArray({token.class},paser.STREAM_TABLE.EXPRESSION[TYPE]) == false then break;
		elseif token.class == "PARENTHESIS_OPEN" then
			if node ~= nil and helper.filterArray({node.class},paser.STREAM_TABLE.EXPRESSION.COMPOUND) == true then
				table.insert(STATE.stack,1,"ARGUMENTS");
				node,index = paser.readArguments(STREAM,index,STATE,token.line,token.column);
			else
				table.insert(STATE.stack,1,"GROUP");
				node = paser.createNode(token.class,token.lexeme,token.line,token.column);
			end;
		elseif token.class == "PARENTHESIS_CLOSE" then
			if table.remove(STATE.stack,1) == "ARGUMENTS" then break;
			else node = paser.createNode(token.class,token.lexeme,token.line,token.column);
			end;
		elseif token.class == "WORD" then node = paser.createNode("ENTITY",token.lexeme,token.line,token.column,{value = token.value});
		else
			if token.value ~= nil then node = paser.createNode(token.class,token.lexeme,token.line,token.column,{value = token.value});
			else node = paser.createNode(token.class,token.lexeme,token.line,token.column);
			end;
		end;
		table.insert(expression,node);
		index = index + 1;
	end;
	if #expression == 0 then paser.throwError("invalid token in expression",token); end;
	paser.filterExpression(expression,TYPE);
	expression = paser.formatExpression(expression);
	return expression,index;
end;

paser.readDeclaration_expressions = function(STREAM,INDEX,STATE)
	local assigment,expression,expressions,index,token;
	token,index = paser.readToken(STREAM,INDEX);
	if helper.filterArray({token.class},paser.STREAM_TABLE.ASSIGNMENT.INITIALIZATION) == true then
		assigment = token.class;
		expressions = {};
		index = index + 1;
		while true do
			token,index = paser.readToken(STREAM,index);
			expression,index = paser.composeExpression(STREAM,index,STATE,"INLINE");
			table.insert(expressions,paser.createNode("EXPRESSION",token.lexeme,token.line,token.column,{value = expression}));
			token,index = paser.readToken(STREAM,index);
			if token.class ~= "COMMA" then break; end;
			index = index + 1;
		end;
	else
		assigment = nil;
		expressions = nil;
	end;
	return assigment,expressions,index;
end;

paser.readDeclaration_identifiers = function(STREAM,INDEX)
	local identifiers,index,name,token,type;
	identifiers = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "WORD" then break; end;
		name = token;
		token,index = paser.readToken(STREAM,index + 1);
		if token.class == "COLON" then
			token,index = paser.readToken(STREAM,index + 1);
			if token.class ~= "WORD" then paser.throwError("invalid declaration, expected a type name",token); end;
			type = token.value;
			token,index = paser.readToken(STREAM,index + 1);
		else type = "Undefined";
		end;
		table.insert(identifiers,paser.createNode("IDENTIFIER",name.lexeme,name.line,name.column,{name = name.value,type = type}));
		if token.class ~= "COMMA" then break; end;
		index = index + 1;
	end;
	if #identifiers == 0 then paser.throwError("invalid declaration, expected a identifier name",token); end;
	return identifiers,index;
end;

paser.readDeclaration_mutability = function(STREAM,INDEX)
	local index,token;
	token,index = paser.readToken(STREAM,INDEX);
	if helper.filterArray({token.class},paser.STREAM_TABLE.MUTABILITY) == false then paser.throwError("invalid declaration, expected a modifier name",token); end;
	return token.class,index + 1;
end;

paser.readDeclaration = function(STREAM,INDEX,STATE,LINE,COLUMN)
	local assigment,expressions,identifiers,index,mutability,scope,token;
	token,index = paser.readToken(STREAM,INDEX);
	scope = token.class;
	mutability,index = paser.readDeclaration_mutability(STREAM,index + 1);
	identifiers,index = paser.readDeclaration_identifiers(STREAM,index);
	assigment,expressions,index = paser.readDeclaration_expressions(STREAM,index,STATE);
	if assigment ~= nil then return paser.createNode("INITIALIZATION",token.lexeme,LINE,COLUMN,{scope = scope,mutability = mutability,identifiers = identifiers,assigment = assigment,expressions = expressions}),index;
	else return paser.createNode("DECLARATION",token.lexeme,LINE,COLUMN,{scope = scope,mutability = mutability,identifiers = identifiers}),index;
	end;
end;

paser.composeBlock = function(STREAM,INDEX,STATE)
	local block,index,statement,token;
	block = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if (helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["ROUTINE"]) == true) or (STATE.type == "CLASS" and helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["CLASS"]) == true) then statement,index = paser.readDeclaration(STREAM,index,STATE,token.line,token.column);
		else break;
		end;
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "SEMICOLON" then paser.throwError("invalid statement, expected a \";\"",token); end;
		table.insert(block,statement);
		index = index + 1;
	end;
	if #block == 0 then paser.throwError("empty block",token); end;
	return block,index;
end;

paser.createStream = function(STREAM)
	local block,index,token;
	block,index = paser.composeBlock(STREAM,1,{type = "SCRIPT",control = false,stack = {}});
	token,index = paser.readToken(STREAM,index);
	if token.class ~= "END" then paser.throwError("invalid script, expected a EOF",token); end;
	return paser.createNode("SCRIPT",block[1].lexeme,block[1].line,block[1].column,{value = paser.createNode("BLOCK",block[1].lexeme,block[1].line,block[1].column,{value = block})});
end;

paser.printStream = function(NODE,TABULATION)
	io.write(string.rep("\t",TABULATION) .. "CLASS: " .. NODE.class);
	if NODE.class == "SCRIPT" then
		io.write("\n");
		paser.printStream(NODE.value,TABULATION + 1);
	elseif (NODE.class == "BLOCK") or (NODE.class == "ARGUMENTS") or (NODE.class == "EXPRESSION") then
		io.write("\n");
		for i = 1, #NODE.value do paser.printStream(NODE.value[i],TABULATION + 1); end;
	elseif (NODE.class == "DECLARATION") or (NODE.class == "INITIALIZATION") then
		io.write(" | SCOPE: " .. NODE.scope .. " | MUTABILITY: " .. NODE.mutability);
		if NODE.class == "INITIALIZATION" then io.write(" | ASSIGNMENT: " .. NODE.assigment); end;
		io.write("\n" .. string.rep("\t",TABULATION + 1) .. "IDENTIFIERS: " .. "\n");
		for i = 1, #NODE.identifiers do paser.printStream(NODE.identifiers[i],TABULATION + 2); end;
		if NODE.class == "INITIALIZATION" then
			io.write(string.rep("\t",TABULATION + 1) .. "EXPRESSIONS: " .. "\n");
			for i = 1, #NODE.expressions do paser.printStream(NODE.expressions[i],TABULATION + 2); end;
		end;
	elseif NODE.class == "IDENTIFIER" then
		io.write(" | NAME: " .. NODE.name .. " | TYPE: " .. NODE.type .. "\n");
	else
		local value;
		if NODE.class == "BOOLEAN" then
			if NODE.value == false then value = "false";
			else value = "true";
			end;
		elseif NODE.class == "STRING" then value = "\"" .. NODE.value .. "\""
		else value = NODE.value;
		end;
		if value ~= nil then io.write(" | VALUE: " .. value); end;
		io.write("\n");
	end;
end;
