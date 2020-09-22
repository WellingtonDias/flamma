-- function telltable(TABLE)
-- 	io.write("{ ");
-- 	for key in pairs(TABLE) do
-- 		io.write(key,", ");
-- 	end;
-- 	io.write(" }");
-- end;

-- telltable(_G);
-- print("");

local file,nodeStream,tokenStream;

file = io.open("./example/example.fls","r");
tokenStream = lexer.createStream(file:read("*a"));
nodeStream = paser.createStream(tokenStream);

lexer.printStream(tokenStream);
print("");
paser.printStream(nodeStream,0);

-- telltable(_G);
-- print("");
