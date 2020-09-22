helper.throwError = function(MESSAGE)
	print(debug.traceback());
	print("ERROR " .. MESSAGE .. ".");
	os.exit();
end;
