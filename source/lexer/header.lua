local lexer = {};

lexer.TABLE =
{
	KEYWORD_GENERAL =
	{
		"import",
		"global","thread","local","public","protected","private","constant","variable",
		"if","elseif","else","while","break","continue",
		"function","clousure","class","async","await","return","create","compose","extends",
		"try","catch","finally","throw",
		"begin","end",
		"not","and","or","xor"
	},
	KEYWORD_TYPE =
	{
		"Void","Null","Boolean","U8","S8","U16","S16","U32","S32","U64","S64","USIZE","SSIZE","F32","F64","Number","String",
		"List","Map","Object",
		"Function","Closure","Class",
		"Promise","Thread"
	},
	WORD = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",
	WORD_EXTENDED = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_",
	NUMBER = "0123456789",
	NUMBER_EXTENDED = "0123456789.",
	PUNCTUATION = " ()[]{}.,:;=+-*/%<!>&"
};
