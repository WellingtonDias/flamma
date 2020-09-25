interpreter.resolveBinary = function(LEFT_OPERAND,RIGHT_OPERAND)
	return interpreter.resolveUnary(LEFT_OPERAND),interpreter.resolveUnary(RIGHT_OPERAND);
end;
