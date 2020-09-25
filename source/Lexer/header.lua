local lexer = {};

lexer.TABLE =
{
	KEYWORD =
	{
		"global","thread","local","public","protected","private",
		"constant","variable",
		"null",
		"not","and","or","xor"
	},
	WORD = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",
	WORD_EXTENDED = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-",
	NUMBER = "0123456789",
	NUMBER_EXTENDED = "0123456789.",
	PUNCTUATION = " ()[]{}.,:;=+-*/%<!>"
};
