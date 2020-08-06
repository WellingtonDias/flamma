paser.printStream = function(NODE,TABULATION)
	io.write(string.rep("\t",TABULATION) .. "TYPE: " .. NODE.type);
	if NODE.type == "SCRIPT" then
		io.write("\n");
		for i = 1, #NODE.value do paser.printStream(NODE.value[i],TABULATION + 1); end;
	elseif NODE.type == "DECLARATION" then
		io.write(" | SCOPE: " .. NODE.scope .. " | MUTABILITY: " .. NODE.mutability .. "\n");
		for i = 1, #NODE.identifiers do paser.printStream(NODE.identifiers[i],TABULATION + 1); end;
	elseif NODE.type == "IDENTIFIER" then
		io.write(" | NAME: " .. NODE.name .. " | TYPE: " .. NODE.type .. "\n");
	else print(" | VALUE: \"" .. NODE.value .. "\"");
	end;
end;
