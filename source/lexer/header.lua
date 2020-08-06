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
		"null",
		"not","and","or","xor"
	},
	WORD = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",
	WORD_EXTENDED = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_",
	NUMBER = "0123456789",
	NUMBER_EXTENDED = "0123456789.",
	PUNCTUATION = " ()[]{}.,:;=+-*/%<!>&"
};
