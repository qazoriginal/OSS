#include <stdio.h>


extern char** environ;

int main(int argc, char *argv[])
{
	int cnt = 0;
	char** ptr = environ;
	while (*ptr++)
    cnt++;

	printf("Number of environment variables: %d\n", cnt);

	return 0;
}


// printenv | wc -l
