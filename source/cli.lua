local file,nodeStream,tokenStream;

file = io.open("./example/example.fls","r");
tokenStream = lexer.createStream(file:read("*a"));
nodeStream = paser.createStream(tokenStream);
interpreter.runStream(nodeStream);

-- lexer.printStream(tokenStream);
-- print("");
-- paser.printStream(nodeStream,0);
