/*
 * $Id: pam_pwdb.c,v 1.3 1997/01/04 20:38:33 morgan Exp morgan $
 *
 * This is the single file that will be compiled for pam_unix.
 * it includes each of the modules that have beed defined in the .-c
 * files in this directory.
 *
 * It is a little ugly to do it this way, but it is a simple way of
 * defining static functions only once, and yet keeping the separate
 * files modular. If you can think of something better, please email
 * Andrew Morgan <morgan@linux.kernel.org>
 *
 * See the end of this file for Copyright information.
 */

/*
 * $Log: pam_pwdb.c,v $
 * Revision 1.3  1997/01/04 20:38:33  morgan
 * this is not the unix module!
 *
 * Revision 1.2  1996/12/01 03:03:43  morgan
 * debugging code uses _pam_malloc
 *
 * Revision 1.1  1996/11/10 21:21:24  morgan
 * Initial revision
 *
 * Revision 1.3  1996/09/05 06:44:33  morgan
 * more debugging, fixed static structure name
 *
 * Revision 1.2  1996/09/01 01:05:12  morgan
 * Cristian Gafton's patches.
 *
 * Revision 1.1  1996/08/29 13:22:19  morgan
 * Initial revision
 *
 */

static const char rcsid[] =
"$Id: pam_pwdb.c,v 1.3 1997/01/04 20:38:33 morgan Exp morgan $\n"
" - PWDB Pluggable Authentication module. <morgan@linux.kernel.org>"
;

#ifdef linux
# define _GNU_SOURCE
# include <features.h>
#endif

#include <sys/types.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <syslog.h>
#include <time.h>	/* for time() */
#include <fcntl.h>
#include <ctype.h>

#define _SVID_SOURCE
#define __USE_BSD
#define _BSD_COMPAT
#include <sys/time.h>
#include <unistd.h>

#include <pwdb/pwdb_public.h>

/* indicate the following groups are defined */

#define PAM_SM_AUTH
#define PAM_SM_ACCOUNT
#define PAM_SM_SESSION
#define PAM_SM_PASSWORD

#include <security/_pam_macros.h>
#include <security/pam_modules.h>

#ifndef LINUX_PAM 
#include <security/pam_appl.h>
#endif  /* LINUX_PAM */

#include "./support.-c"

/*
 * PAM framework looks for these entry-points to pass control to the
 * authentication module.
 */

#include "./pam_unix_auth.-c"

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags
				   , int argc, const char **argv)
{
    unsigned int ctrl;
    int retval;

    D(("called."));

    pwdb_start();
    ctrl = set_ctrl(flags, argc, argv);
    retval = _unix_auth( pamh, ctrl );
    pwdb_end();

    return retval;
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags
			      , int argc, const char **argv)
{
    unsigned int ctrl;
    int retval;

    D(("called."));

    pwdb_start();
    ctrl = set_ctrl(flags, argc, argv);
    retval = _unix_set_credentials(pamh, ctrl) ;
    pwdb_end();

    return retval;
}

/*
 * PAM framework looks for these entry-points to pass control to the
 * account management module.
 */

#include "./pam_unix_acct.-c"

PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags,
				int argc, const char **argv)
{
    unsigned int ctrl;
    int retval;

    D(("called."));

    pwdb_start();
    ctrl = set_ctrl(flags, argc, argv);
    retval = _unix_acct_mgmt(pamh, ctrl);
    pwdb_end();

    D(("done."));

    return retval;
}

/*
 * PAM framework looks for these entry-points to pass control to the
 * session module.
 */
 
#include "./pam_unix_sess.-c"

PAM_EXTERN int pam_sm_open_session(pam_handle_t *pamh, int flags,
				   int argc, const char **argv)
{
    unsigned int ctrl;
    int retval;

    D(("called."));

    pwdb_start();
    ctrl = set_ctrl(flags, argc, argv);
    retval = _unix_open_session(pamh, ctrl);
    pwdb_end();

    return retval;
}

PAM_EXTERN int pam_sm_close_session(pam_handle_t *pamh, int flags,
				    int argc, const char **argv)
{
    unsigned int ctrl;
    int retval;

    D(("called."));

    pwdb_start();
    ctrl = set_ctrl(flags, argc, argv);
    retval = _unix_close_session(pamh, ctrl);
    pwdb_end();

    return retval;
}

/*
 * PAM framework looks for these entry-points to pass control to the
 * password changing module.
 */
 
#include "./pam_unix_passwd.-c"

PAM_EXTERN int pam_sm_chauthtok(pam_handle_t *pamh, int flags,
				int argc, const char **argv)
{
    unsigned int ctrl;
    int retval;

    D(("called."));

    pwdb_start();
    ctrl = set_ctrl(flags, argc, argv);
    retval = _unix_chauthtok(pamh, ctrl);
    pwdb_end();

    return retval;
}

/* static module data */

#ifdef PAM_STATIC
struct pam_module _pam_pwdb_modstruct = {
     "pam_pwdb",
     pam_sm_authenticate,
     pam_sm_setcred,
     pam_sm_acct_mgmt,
     pam_sm_open_session,
     pam_sm_close_session,
     pam_sm_chauthtok
};

#endif

/*
 * Copyright (c) Andrew G. Morgan, 1996. All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, and the entire permission notice in its entirety,
 *    including the disclaimer of warranties.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 * 
 * ALTERNATIVELY, this product may be distributed under the terms of
 * the GNU Public License, in which case the provisions of the GPL are
 * required INSTEAD OF the above restrictions.  (This clause is
 * necessary due to a potential bad interaction between the GPL and
 * the restrictions contained in a BSD-style copyright.)
 * 
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */
