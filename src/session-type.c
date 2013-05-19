/* session-type.c -- SSH session smob.
 *
 * Copyright (C) 2013 Artyom V. Poptsov <poptsov.artyom@gmail.com>
 *
 * This file is part of libguile-ssh
 *
 * libguile-ssh is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * libguile-ssh is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with libguile-ssh.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <libguile.h>
#include <libssh/libssh.h>
#include <string.h>

#include "session-type.h"
#include "error.h"

#define PRINT_DEBUG(data)\
  scm_display (data, scm_current_output_port ())

scm_t_bits session_tag;	/* Smob tag. */

SCM
mark_session (SCM session_smob)
{
  return SCM_BOOL_F;
}

/* Handle GC'ing of the session smob. */
size_t
free_session (SCM session_smob)
{
  struct session_data *data
    = (struct session_data *) SCM_SMOB_DATA (session_smob);

  ssh_disconnect (data->ssh_session);
  ssh_free (data->ssh_session);
  return 0;
}

/* Create a new session. */
SCM
guile_ssh_make_session (void)
{
  SCM smob;

  struct session_data *session_data
    = (struct session_data *) scm_gc_malloc (sizeof (struct session_data),
                                             "session");

  session_data->ssh_session = ssh_new ();
  if (session_data->ssh_session == NULL)
    return SCM_BOOL_F;

  SCM_NEWSMOB (smob, session_tag, session_data);

  return smob;
}


/* session smob initialization. */
void
init_session_type (void)
{
  session_tag = scm_make_smob_type ("ssh:session", 
                                    sizeof (struct session_data));
  scm_set_smob_mark (session_tag, mark_session);
  scm_set_smob_free (session_tag, free_session);

  scm_c_define_gsubr ("ssh:make-session",    0, 0, 0, guile_ssh_make_session);
}

/* session.c ends here */
