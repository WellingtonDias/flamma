interpreter.resolveOperand = function(OPERAND)
	if OPERAND.class == "ENTITY" then
		return OPERAND.scope[OPERAND.value].value;
	else
		return OPERAND;
	end;
end;
