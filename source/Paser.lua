local paser = {};


paser.STREAM_TABLE =
{
	IGNORED = {"COMMENT","SPACE","HORIZONTAL_TAB","CARRIAGE_RETURN","LINE_FEED"},
	INVALID = {"INVALID_CHARACTER","INVALID_NUMBER","INVALID_STRING","INVALID_PUNCTUATION"},
	SCOPE = {"GLOBAL","LOCAL"},
	MODIFIER = {"CONSTANT","VARIABLE"},
	TYPE =
	{
		["NULL"] = "Null",
		["BOOLEAN"] = "Boolean",
		["NUMBER"] = "Number",
		["STRING"] = "String"
	},
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
			"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		},
		["REDUCED"] = {"WORD"}
	}
};


paser.FILTER_TABLE =
{
	["EXTENDED"] =
	{
		["PARENTHESIS_OPEN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["PARENTHESIS_CLOSE"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","IDENTIFIER"},
		["NULL"] = {"START","PARENTHESIS_OPEN","DOUBLE-EQUAL","NOT-EQUAL"},
		["BOOLEAN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
		["NUMBER"] = {"START","PARENTHESIS_OPEN","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["STRING"] = {"START","PARENTHESIS_OPEN","PLUS","DOUBLE-EQUAL","NOT-EQUAL"},
		["IDENTIFIER"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVE","POSITIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["NOT"] = {"START","PARENTHESIS_OPEN","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
		["AND"] = {"PARENTHESIS_CLOSE","BOOLEAN","IDENTIFIER"},
		["OR"] = {"PARENTHESIS_CLOSE","BOOLEAN","IDENTIFIER"},
		["XOR"] = {"PARENTHESIS_CLOSE","BOOLEAN","IDENTIFIER",},
		["POSITIVE"] = {"START","PARENTHESIS_OPEN","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["NEGATIVE"] = {"START","PARENTHESIS_OPEN","PLUS","MINUS","ASTERISK","SLASH","PERCENT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
		["PLUS"] = {"PARENTHESIS_CLOSE","NUMBER","STRING","IDENTIFIER"},
		["MINUS"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER",},
		["ASTERISK"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER"},
		["SLASH"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER"},
		["PERCENT"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER"},
		["LESS"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER"},
		["LESS-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER"},
		["DOUBLE-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","IDENTIFIER"},
		["NOT-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","IDENTIFIER"},
		["GREATER-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER"},
		["GREATER"] = {"PARENTHESIS_CLOSE","NUMBER","IDENTIFIER"}
	},
	["REDUCED"] =
	{
		["IDENTIFIER"] = {"START"},
	}
};


paser.RPN_TABLE =
{
	GROUP = {"PARENTHESIS_OPEN","PARENTHESIS_CLOSE"},
	LITERAL = {"NULL","BOOLEAN","NUMBER","STRING"},
	OPERAND = {"NULL","BOOLEAN","NUMBER","STRING","IDENTIFIER"},
	OPERATOR =
	{
		"NOT","AND","OR","XOR",
		"POSITIVE","NEGATIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT",
		"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
	},
	PRECEDENCE =
	{
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


paser.createNode = function(TOKEN)
	if helper.filterArray({TOKEN.class},paser.RPN_TABLE.LITERAL) == true then
		return {class = "LITERAL",type = paser.STREAM_TABLE.TYPE[TOKEN.class],value = TOKEN.value};
	elseif TOKEN.class == "IDENTIFIER" then
		return {class = TOKEN.class,value = TOKEN.value};
	elseif helper.filterArray({TOKEN.class},paser.RPN_TABLE.OPERATOR) == true then
		return {class = "OPERATOR",value = TOKEN.class};
	end;
end;


paser.formatExpression = function(EXPRESSION)
	local expression,stack,token;
	expression = {};
	stack = {};
	for i = 1, #EXPRESSION do
		token = EXPRESSION[i];
		if helper.filterArray({token.class},paser.RPN_TABLE.GROUP) == true then
			if token.class == "PARENTHESIS_OPEN" then
				table.insert(stack,1,token);
			elseif token.class == "PARENTHESIS_CLOSE" then
				while true do
					if #stack == 0 then
						paser.throwError("invalid token in the expression",token);
					end;
					if stack[1].class == "PARENTHESIS_OPEN" then
						table.remove(stack,1);
						break;
					end;
					table.insert(expression,paser.createNode(table.remove(stack,1)));
				end;
			end;
		elseif helper.filterArray({token.class},paser.RPN_TABLE.OPERAND) == true then
			table.insert(expression,paser.createNode(token));
		elseif helper.filterArray({token.class},paser.RPN_TABLE.OPERATOR) == true then
			if
				(#stack == 0) or
				(stack[1].class == "PARENTHESIS_OPEN") or
				(paser.RPN_TABLE.PRECEDENCE[token.class][1] > paser.RPN_TABLE.PRECEDENCE[stack[1].class][1]) or
				(
					(paser.RPN_TABLE.PRECEDENCE[token.class][1] == paser.RPN_TABLE.PRECEDENCE[stack[1].class][1]) and
					(paser.RPN_TABLE.PRECEDENCE[token.class][2] == "RIGHT")
				)
			then
				table.insert(stack,1,token);
			else
				while
					(#stack > 0) and
					(stack[1].class ~= "PARENTHESIS_OPEN") and
					(
						(paser.RPN_TABLE.PRECEDENCE[token.class][1] < paser.RPN_TABLE.PRECEDENCE[stack[1].class][1]) or
						(
							(paser.RPN_TABLE.PRECEDENCE[token.class][1] == paser.RPN_TABLE.PRECEDENCE[stack[1].class][1]) and
							(paser.RPN_TABLE.PRECEDENCE[token.class][2] == "LEFT")
						)
					)
				do
					table.insert(expression,paser.createNode(table.remove(stack,1)));
				end;
				table.insert(stack,1,token);
			end;
		end;
	end;
	while #stack > 0 do
		token = table.remove(stack,1);
		if helper.filterArray({token.class},paser.RPN_TABLE.GROUP) == true then
			paser.throwError("invalid token in the expression",token);
		end;
		table.insert(expression,paser.createNode(token));
	end;
	return expression;
end;


paser.filterExpression = function(EXPRESSION,TYPE)
	local currentToken,previousToken;
	previousToken = {class = "START"};
	for i = 1, #EXPRESSION do
		currentToken = EXPRESSION[i];
		if helper.filterArray({previousToken.class},paser.FILTER_TABLE[TYPE][currentToken.class]) == false then
			paser.throwError("invalid token in the expression",currentToken);
		end;
		previousToken = currentToken;
	end;
end;


paser.composeExpression = function(STREAM,INDEX,TYPE)
	local expression,index,newToken,oldToken;
	expression = {};
	index = INDEX;
	while true do
		oldToken,index = paser.readToken(STREAM,index);
		if helper.filterArray({oldToken.class},paser.STREAM_TABLE.EXPRESSION[TYPE]) == false then
			break;
		elseif oldToken.class == "WORD" then
			newToken = {class = "IDENTIFIER",lexeme = oldToken.lexeme,line = oldToken.line,column = oldToken.column,value = oldToken.value};
		else
			newToken = oldToken;
		end;
		table.insert(expression,newToken);
		index = index + 1;
	end;
	if #expression == 0 then
		paser.throwError("invalid token in the expression",oldToken);
	end;
	paser.filterExpression(expression,TYPE);
	expression = paser.formatExpression(expression);
	return expression,index;
end;


paser.composeFields = function(STREAM,INDEX)
	local fields,identifier,index,token,type;
	fields = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "WORD" then
			paser.throwError("invalid token in the declaration, expected a identifier name",token);
		end;
		identifier = token;
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
		table.insert(fields,{class = "FIELD",identifier = identifier.value,type = type});
		if token.class ~= "COMMA" then
			break;
		end;
		index = index + 1;
	end;
	return fields,index;
end;


paser.composeExpressions = function(STREAM,INDEX,TYPE)
	local expression,expressions,index,token;
	expressions = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		expression,index = paser.composeExpression(STREAM,index,TYPE);
		table.insert(expressions,{class = "EXPRESSION",value = expression});
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "COMMA" then
			break;
		end;
		index = index + 1;
	end;
	return expressions,index;
end;


paser.readDeclaration = function(STREAM,INDEX)
	local fields,index,modifier,scope,token;
	token,index = paser.readToken(STREAM,INDEX);
	scope = token.class;
	token,index = paser.readToken(STREAM,index + 1);
	if helper.filterArray({token.class},paser.STREAM_TABLE.MODIFIER) == false then
		paser.throwError("invalid token in the declaration, expected a modifier name",token);
	end;
	modifier = token.class;
	fields,index = paser.composeFields(STREAM,index + 1);
	token,index = paser.readToken(STREAM,index);
	if helper.filterArray({token.class},paser.STREAM_TABLE.DECLARATION) == true then
		local operator,values;
		operator = token.class;
		values,index = paser.composeExpressions(STREAM,index + 1,"EXTENDED");
		return {class = "INITIALIZATION",scope = scope,modifier = modifier,fields = fields,operator = operator,values = values},index;
	else
		return {class = "DECLARATION",scope = scope,modifier = modifier,fields = fields},index;
	end;
end;


paser.readAssigment = function(STREAM,INDEX)
	local fields,index,operator,token,values;
	fields,index = paser.composeExpressions(STREAM,INDEX,"REDUCED");
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
	values,index = paser.composeExpressions(STREAM,index + 1,"EXTENDED");
	return {class = "ASSIGNMENT",fields = fields,operator = operator,values = values},index;
end;


paser.composeBlock = function(STREAM,INDEX)
	local block,index,statement,token;
	block = {};
	index = INDEX;
	while true do
		token,index = paser.readToken(STREAM,index);
		if helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE) == true then
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
	local block,index,token;
	block,index = paser.composeBlock(STREAM,1);
	token,index = paser.readToken(STREAM,index);
	if token.class ~= "END" then
		paser.throwError("invalid token in the script, expected a EOF",token);
	end;
	return {class = "SCRIPT",value = block};
end;


paser.printStream = function(NODE,TABULATION)
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
		io.write("\n" .. string.rep("\t",TABULATION + 1) .. "FIELDS: " .. "\n");
		for i = 1, #NODE.fields do
			paser.printStream(NODE.fields[i],TABULATION + 2);
			io.write("\n");
		end;
		if NODE.class == "INITIALIZATION" then
			io.write(string.rep("\t",TABULATION + 1) .. "EXPRESSIONS: " .. "\n");
			for i = 1, #NODE.values do
				paser.printStream(NODE.values[i],TABULATION + 2);
				if i < #NODE.values then
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
		for i = 1, #NODE.values do
			paser.printStream(NODE.values[i],TABULATION + 2);
			if i < #NODE.values then
				io.write("\n");
			end;
		end;
	elseif NODE.class == "FIELD" then
		io.write(" | IDENTIFIER: " .. NODE.identifier .. " | TYPE: " .. NODE.type);
	elseif NODE.class == "LITERAL" then
		local value;
		io.write(" | TYPE: " .. NODE.type);
		if NODE.type == "Boolean" then
			if NODE.value == false then
				value = "false";
			else
				value = "true";
			end;
		elseif NODE.type == "Number" then
			value = NODE.value;
		elseif NODE.type == "String" then
			value = "\"" .. NODE.value .. "\""
		end;
		if value ~= nil then
			io.write(" | VALUE: " .. value);
		end;
	elseif (NODE.class == "IDENTIFIER") or (NODE.class == "OPERATOR") then
		io.write(" | VALUE: " .. NODE.value);
	end;
end;
