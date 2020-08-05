lexer.readStream = function(STREAM)
	local column,index,line,stream,token;
	stream = {};
	index = 1;
	line = 1;
	column = 1;
	while index <= #STREAM do
		token,index,line,column = lexer.readToken(STREAM,index,line,column);
		table.insert(stream,token);
	end;
	return stream;
end;
