paser.printStream = function(NODE,TABULATION)
	io.write(string.rep("\t",TABULATION) .. "CLASS: " .. NODE.class);
	if NODE.class == "SCRIPT" then
		io.write("\n");
		paser.printStream(NODE.value,TABULATION + 1);
	elseif (NODE.class == "BLOCK") or (NODE.class == "EXPRESSION") then
		io.write("\n");
		for i = 1, #NODE.value do
			paser.printStream(NODE.value[i],TABULATION + 1);
		end;
	elseif (NODE.class == "DECLARATION") or (NODE.class == "INITIALIZATION") then
		io.write(" | SCOPE: " .. NODE.scope .. " | MUTABILITY: " .. NODE.mutability);
		if NODE.class == "INITIALIZATION" then
			io.write(" | ASSIGNMENT: " .. NODE.assigment);
		end;
		io.write("\n" .. string.rep("\t",TABULATION + 1) .. "IDENTIFIERS: " .. "\n");
		for i = 1, #NODE.identifiers do
			paser.printStream(NODE.identifiers[i],TABULATION + 2);
		end;
		if NODE.class == "INITIALIZATION" then
			io.write(string.rep("\t",TABULATION + 1) .. "EXPRESSIONS: " .. "\n");
			for i = 1, #NODE.expressions do
				paser.printStream(NODE.expressions[i],TABULATION + 2);
			end;
		end;
	elseif NODE.class == "IDENTIFIER" then
		io.write(" | NAME: " .. NODE.name .. " | TYPE: " .. NODE.type .. "\n");
	else
		local value;
		if NODE.class == "BOOLEAN" then
			if NODE.value == false then
				value = "false";
			else
				value = "true";
			end;
		elseif NODE.class == "STRING" then
			value = "\"" .. NODE.value .. "\""
		else
			value = NODE.value;
		end;
		if value ~= nil then
			io.write(" | VALUE: " .. value);
		end;
		io.write("\n");
	end;
end;
