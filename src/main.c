#include <stdio.h>
#include <stdlib.h>

#include "msg.h"

void bye();

int main(int argc, char** argv) {
	atexit(bye);

	printf("%s\n", msg_hello());

	return (EXIT_SUCCESS);
}

void bye(void) {
	printf("%s\n", msg_bye());
}
