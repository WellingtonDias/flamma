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
