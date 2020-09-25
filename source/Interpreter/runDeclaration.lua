interpreter.runDeclaration = function(DECLARATION,SCOPES)
	local identifier,scope,type,value;
	identifier = DECLARATION.identifiers[1];
	scope = interpreter.TABLE.SCOPE[DECLARATION.scope];
	if DECLARATION.class == "DECLARATION" then
		value = {type = "UNDEFINED"};
		type = identifier.type;
	elseif DECLARATION.class == "INITIALIZATION" then
		value = interpreter.runExpression(DECLARATION.expressions[1],SCOPES);
		if (DECLARATION.assigment == "COLON-EQUAL") and (identifier.type == "Undefined") then
			type = value.class;
		else
			type = identifier.type;
		end;
	end;
	SCOPES[scope][identifier.name] =
	{
		mutability = DECLARATION.mutability,
		type = type,
		value = value
	};
end;
