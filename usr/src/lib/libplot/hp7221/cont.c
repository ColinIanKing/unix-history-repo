/*-
 * Copyright (c) 1980, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * %sccs.include.proprietary.c%
 */

#ifndef lint
static char sccsid[] = "@(#)cont.c	8.1 (Berkeley) %G%";
#endif /* not lint */

#include "hp7221.h"

cont(xi,yi)
int xi,yi;
{
	currentx = scaleX(xi);
	currenty = scaleY(yi);
	putchar( 'q' );
	putMBP( currentx, currenty );
}
