local interpreter = {};

interpreter.TABLE =
{
	SCOPE =
	{
		["GLOBAL"] = "globalScope";
		["THREAD"] = "threadScope";
		["LOCAL"] = "localScope";
	};
	EXPRESSION =
	{
		OPERAND = {"NULL","BOOLEAN","NUMBER","STRING","ENTITY"},
		OPERATOR =
		{
			"NOT",
			"AND","OR","XOR",
			"POSITIVE","NEGATIVE","PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		},
		UNARY =
		{
			"NOT",
			"POSITIVE","NEGATIVE",
		},
		BINARY =
		{
			"AND","OR","XOR",
			"PLUS","MINUS","ASTERISK","SLASH","PERCENT",
			"DOT",
			"LESS","LESS-EQUAL","EQUAL","NOT-EQUAL","GREATER-EQUAL","GREATER"
		}
	};
};
