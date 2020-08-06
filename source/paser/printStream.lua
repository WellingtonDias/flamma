paser.printStream = function(NODE,TABULATION)
	io.write(string.rep("\t",TABULATION) .. "TYPE: " .. NODE.type);
	if NODE.type == "SCRIPT" then
		io.write(" | VALUE: \n");
		for i = 1, #NODE.value do paser.printStream(NODE.value[i],TABULATION + 1); end;
	else print(" | VALUE: \"" .. NODE.value .. "\"");
	end;
end;



-- {type = "DECLARATION",scope = scope,mutability = mutability,type = type,identifier = identifier},index;
