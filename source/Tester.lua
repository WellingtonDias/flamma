local file,nodeStream,tokenStream;

file = io.open("./example/example.fls","r");
tokenStream = lexer.createStream(file:read("*a"));
nodeStream = paser.createStream(tokenStream);

lexer.printStream(tokenStream);
print("");
paser.printStream(nodeStream,0);

interpreter.runStream(nodeStream);
