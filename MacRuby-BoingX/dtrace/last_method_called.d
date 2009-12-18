#!/usr/sbin/dtrace -s

#pragma D option quiet

BEGIN
{
    printf("Target pid: %d\n\n", $target);
}

macruby$target:::method-entry
{

	last_method_called[0] = copyinstr(arg0);
	last_method_called[1] = copyinstr(arg1);

}

objc_runtime$target:::objc_exception_throw
{ 
	trace("Exception raised :\n");
	/*ustack();*/
}

END
{
    printf("\n");

	printf("Last method called : %s.%s", last_method_called[0], last_method_called[1]);

}
