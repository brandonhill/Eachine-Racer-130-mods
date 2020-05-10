
module test() {
	echo(str("$children = ", $children));
}

test() {
	echo("I'm not a thing that can be operated on!"); // counts as a child
	if (false) {} // counts as a child
	transform() {}
}

module test2() {
	test()
	children(); // counts as a child, even when no children
}

test2();
