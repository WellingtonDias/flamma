file = io.open("./example/example.fls","r");
tokenStream = lexer.readStream(file:read("*a"));

lexer.printStream(tokenStream);
