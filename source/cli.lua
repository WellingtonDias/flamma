file = io.open("./example/example.fls","r");
tokenStream = lexer.readStream(file:read("*a"));
nodeStream = paser.readStream(tokenStream);

lexer.printStream(tokenStream);
