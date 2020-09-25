interpreter.resolveOperands = function(LEFT_OPERAND,RIGHT_OPERAND)
	return interpreter.resolveOperand(LEFT_OPERAND),interpreter.resolveOperand(RIGHT_OPERAND);
end;
