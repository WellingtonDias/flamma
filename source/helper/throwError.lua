helper.throwError = function(MESSAGE)
	print(debug.traceback());
	print(MESSAGE);
	os.exit();
end;
