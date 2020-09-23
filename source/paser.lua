----------------------------------------------------------------------------------------------------
	local paser = {};
----------------------------------------------------------------------------------------------------
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
			["INITIALIZATION"] = {"EQUAL","COLON-EQUAL"},
			["EXPRESSION"] = {"EQUAL","PLUS-EQUAL","MINUS-EQUAL","ASTERISK-EQUAL","SLASH-EQUAL","PERCENT-EQUAL"}
		},
		EXPRESSION =
		{
			["INLINE"] =
			{
				"PARENTHESIS_OPEN","PARENTHESIS_CLOSE","BRACKET_OPEN","BRACE_OPEN",
				"NULL","BOOLEAN","NUMBER","STRING","FUNCTION","CLOSURE","CLASS","WORD",
				"NOT","AND","OR","XOR",
				"POSITIVE","NEGATIVE",
				"PLUS","MINUS","ASTERISK","SLASH","PERCENT",
				"DOT",
				"LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
			},
			["STATEMENT"] = {"EQUAL","PLUS-EQUAL","MINUS-EQUAL","ASTERISK-EQUAL","SLASH-EQUAL","PERCENT-EQUAL"},
			["COMPOUND"] = {"INDEX","KEY","ARGUMENTS","ENTITY"},
			["OPERATOR"] = {"POSITIVE","NEGATIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT","DOT"}
		}
	};
----------------------------------------------------------------------------------------------------
	paser.STREAM_OPERATOR =
	{
		["POSITIVE"] = "POSITIVATION",
		["NEGATIVE"] = "NEGATIVATION",
		["PLUS"] = "ADDITION",
		["MINUS"] = "SUBTRACTION",
		["ASTERISK"] = "MULTIPLICATION",
		["SLASH"] = "DIVISION",
		["PERCENT"] = "MODULO",
		["DOT"] = "INDEXATION"
	};
----------------------------------------------------------------------------------------------------
	paser.FILTER_TABLE =
	{
		["INLINE"] =
		{
			["PARENTHESIS_OPEN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVATION","POSITIVATION","ADDITION","SUBTRACTION","MULTIPLICATION","DIVISION","MODULO","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
			["PARENTHESIS_CLOSE"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","INDEX","KEY","ARGUMENTS","ENTITY"},
			["NULL"] = {"START","PARENTHESIS_OPEN","DOUBLE-EQUAL","NOT-EQUAL"},
			["BOOLEAN"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
			["NUMBER"] = {"START","PARENTHESIS_OPEN","NEGATIVATION","POSITIVATION","ADDITION","SUBTRACTION","MULTIPLICATION","DIVISION","MODULO","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
			["STRING"] = {"START","PARENTHESIS_OPEN","ADDITION","DOUBLE-EQUAL","NOT-EQUAL"},
			["LIST"] = {"START"},
			["MAP"] = {"START"},
			["FUNCTION"] = {"START"},
			["CLOUSURE"] = {"START"},
			["CLASS"] = {"START"},
			["INDEX"] = {"INDEX","KEY","ARGUMENTS","ENTITY"},
			["KEY"] = {"INDEX","KEY","ARGUMENTS","ENTITY"},
			["ARGUMENTS"] = {"INDEX","KEY","ARGUMENTS","ENTITY"},
			["ENTITY"] = {"START","PARENTHESIS_OPEN","NOT","AND","OR","XOR","NEGATIVATION","POSITIVATION","ADDITION","SUBTRACTION","MULTIPLICATION","DIVISION","MODULO","DOT","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
			["NOT"] = {"START","PARENTHESIS_OPEN","AND","OR","XOR","DOUBLE-EQUAL","NOT-EQUAL"},
			["AND"] = {"PARENTHESIS_CLOSE","BOOLEAN","INDEX","KEY","ARGUMENTS","ENTITY"},
			["OR"] = {"PARENTHESIS_CLOSE","BOOLEAN","INDEX","KEY","ARGUMENTS","ENTITY"},
			["XOR"] = {"PARENTHESIS_CLOSE","BOOLEAN","INDEX","KEY","ARGUMENTS","ENTITY"},
			["NEGATIVATION"] = {"START","PARENTHESIS_OPEN","ADDITION","SUBTRACTION","MULTIPLICATION","DIVISION","MODULO","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
			["POSITIVATION"] = {"START","PARENTHESIS_OPEN","ADDITION","SUBTRACTION","MULTIPLICATION","DIVISION","MODULO","LESS","LESS-EQUAL","DOUBLE-EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"},
			["ADDITION"] = {"PARENTHESIS_CLOSE","NUMBER","STRING","INDEX","KEY","ARGUMENTS","ENTITY"},
			["SUBTRACTION"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"},
			["MULTIPLICATION"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"},
			["DIVISION"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"},
			["MODULO"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"},
			["INDEXATION"] = {"INDEX","KEY","ARGUMENTS","ENTITY"},
			["LESS"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"},
			["LESS-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"},
			["DOUBLE-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","INDEX","KEY","ARGUMENTS","ENTITY"},
			["NOT-EQUAL"] = {"PARENTHESIS_CLOSE","NULL","BOOLEAN","NUMBER","STRING","INDEX","KEY","ARGUMENTS","ENTITY"},
			["GREATER-EQUAL"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"},
			["GREATER"] = {"PARENTHESIS_CLOSE","NUMBER","INDEX","KEY","ARGUMENTS","ENTITY"}
		}
	};
----------------------------------------------------------------------------------------------------
	table.insert(paser.STREAM_TABLE.SCOPE["CLASS"],paser.STREAM_TABLE.SCOPE["ROUTINE"]);
	table.insert(paser.STREAM_TABLE.EXPRESSION["STATEMENT"],paser.STREAM_TABLE.EXPRESSION["INLINE"]);
----------------------------------------------------------------------------------------------------
	paser.throwError = function(MESSAGE,TOKEN)
		helper.throwError(MESSAGE .. " at lexeme: \"" .. TOKEN.lexeme .. "\", line: " .. TOKEN.line .. ", column: " .. TOKEN.column);
	end;
----------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------
	paser.filterExpression = function(STREAM,TYPE)
		local currentToken,previousToken;
		previousToken = {class = "START"};
		for i = 1, #STREAM do
			print(previousToken.class);
			currentToken = STREAM[i];
			print(currentToken.class);
			if helper.filterArray({previousToken.class},paser.FILTER_TABLE[TYPE][currentToken.class]) == false then paser.throwError("invalid expression",currentToken); end;
			previousToken = currentToken;
		end;
	end;
----------------------------------------------------------------------------------------------------
	paser.composeExpression = function(STREAM,INDEX,STATE,TYPE)
		local expression,index,node,token;
		expression = {};
		index = INDEX;
		while true do
			token,index = paser.readToken(STREAM,index);
			if helper.filterArray({token.class},paser.STREAM_TABLE.EXPRESSION[TYPE]) == false then break;
			elseif token.class == "PARENTHESIS_OPEN" then
				if node ~= nil and helper.filterArray({node.class},paser.STREAM_TABLE.EXPRESSION["COMPOUND"]) == true then
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
			elseif helper.filterArray({token.class},paser.STREAM_TABLE.EXPRESSION["OPERATOR"]) == true then
				node = paser.createNode(paser.STREAM_OPERATOR[token.class],token.lexeme,token.line,token.column);
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
		return expression,index;
	end;
----------------------------------------------------------------------------------------------------
	paser.readDeclaration_expressions = function(STREAM,INDEX,STATE)
		local assigment,expression,expressions,index,token;
		token,index = paser.readToken(STREAM,INDEX);
		if helper.filterArray({token.class},paser.STREAM_TABLE.ASSIGNMENT["INITIALIZATION"]) == true then
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
----------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------
	paser.readDeclaration_mutability = function(STREAM,INDEX)
		local index,token;
		token,index = paser.readToken(STREAM,INDEX);
		if helper.filterArray({token.class},paser.STREAM_TABLE.MUTABILITY) == false then paser.throwError("invalid declaration, expected a modifier name",token); end;
		return token.class,index + 1;
	end;
----------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------
	paser.composeBlock = function(STREAM,INDEX,STATE)
		local block,index,statement,token;
		block = {};
		index = INDEX;
		while true do
			token,index = paser.readToken(STREAM,index);
			if helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["ROUTINE"]) == true or (STATE.type == "CLASS" and helper.filterArray({token.class},paser.STREAM_TABLE.SCOPE["CLASS"]) == true) then statement,index = paser.readDeclaration(STREAM,index,STATE,token.line,token.column);
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
----------------------------------------------------------------------------------------------------
	paser.createStream = function(STREAM)
		local block,index,token;
		block,index = paser.composeBlock(STREAM,1,{type = "SCRIPT",control = false,stack = {}});
		token,index = paser.readToken(STREAM,index);
		if token.class ~= "END" then paser.throwError("invalid script, expected a EOF",token); end;
		return paser.createNode("SCRIPT",block[1].lexeme,block[1].line,block[1].column,{value = paser.createNode("BLOCK",block[1].lexeme,block[1].line,block[1].column,{value = block})});
	end;
----------------------------------------------------------------------------------------------------
	paser.printStream = function(NODE,TABULATION)
		io.write(string.rep("\t",TABULATION) .. "CLASS: " .. NODE.class);
		if NODE.class == "SCRIPT" then
			io.write("\n");
			paser.printStream(NODE.value,TABULATION + 1);
		elseif NODE.class == "BLOCK" or NODE.class == "ARGUMENTS" or NODE.class == "EXPRESSION" then
			io.write("\n");
			for i = 1, #NODE.value do paser.printStream(NODE.value[i],TABULATION + 1); end;
		elseif NODE.class == "DECLARATION" or NODE.class == "INITIALIZATION" then
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
				if NODE.value == true then value = "true";
				else value = "false";
				end;
			elseif NODE.class == "STRING" then value = "\"" .. NODE.value .. "\""
			else value = NODE.value;
			end;
			if value ~= nil then io.write(" | VALUE: " .. value); end;
			io.write("\n");
		end;
	end;
----------------------------------------------------------------------------------------------------
