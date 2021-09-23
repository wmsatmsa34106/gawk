dnl Check for readline and dependencies
dnl Copyright (C) 2004, 2005, 2013, 2014 Free Software Foundation, Inc.
dnl
dnl This file is free software, distributed under the terms of the GNU
dnl General Public License.  As a special exception to the GNU General
dnl Public License, this file may be distributed as part of a program
dnl that contains a configuration script generated by Autoconf, under
dnl the same distribution terms as the rest of that program.
dnl
dnl Defines HAVE_LIBREADLINE to 1 if a working readline setup is
dnl found, and sets @LIBREADLINE@ to the necessary libraries.
dnl
dnl Based upon GNUPG_CHECK_READLINE.  Many more years into the
dnl twenty-first century, it is not enough to link a test program
dnl with the readline library. On several systems, if readline is
dnl not linked with the curses / termcap / whatever libraries, the
dnl problem is only discovered at run time.  Isn't that special?

AC_DEFUN([GAWK_CHECK_READLINE],
[
  AC_ARG_WITH([readline],
     AS_HELP_STRING([--with-readline=DIR],
	[look for the readline library in DIR]),
     [_do_readline=$withval],[_do_readline=yes])

  if test "$_do_readline" != "no" ; then
     if test -d "$withval" ; then
        CPPFLAGS="${CPPFLAGS} -I$withval/include"
        LDFLAGS="${LDFLAGS} -L$withval/lib"
     fi

     for _termcap in "" "-ltermcap" "-lcurses" "-lncurses" ; do
        _readline_save_libs=$LIBS
        _combo="-lreadline${_termcap:+ $_termcap}"
        LIBS="$LIBS $_combo"

        AC_MSG_CHECKING([whether readline via "$_combo" is present and sane])

	AC_RUN_IFELSE(
dnl source program:
[AC_LANG_SOURCE([[#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <readline/readline.h>
#include <readline/history.h>

int main(int argc, char **argv)
{
	int fd;
	char *line;

	close(0);
	close(1);
	fd = open("/dev/null", 2);	/* should get fd 0 */
	dup(fd);
	line = readline("giveittome> ");

	/* some printfs don't handle NULL for %s */
	printf("got <%s>\n", line ? line : "(NULL)");
	return 0;
}]])],
dnl action if true:
            [_found_readline=yes],
dnl action if false:
            [_found_readline=no],
dnl action if cross compiling:
		[AC_LINK_IFELSE(
			[AC_LANG_PROGRAM([[#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>]],		dnl includes
			dnl function body
			[[
	int fd;
	char *line;

	close(0);
	close(1);
	fd = open("/dev/null", 2);	/* should get fd 0 */
	dup(fd);
	line = readline("giveittome> ");

	/* some printfs don't handle NULL for %s */
	printf("got <%s>\n", line ? line : "(NULL)");
]])],
dnl action if found:
			[_found_readline=yes],
dnl action if not found:
			[_found_readline=no]
		)]
	)

        AC_MSG_RESULT([$_found_readline])

        LIBS=$_readline_save_libs

        if test $_found_readline = yes ; then
	   case $host_os in
	   *bsd* )	AC_CHECK_LIB(termcap, tgetent, _combo="$_combo -ltermcap")
	  	 ;;
	   esac
           AC_DEFINE(HAVE_LIBREADLINE,1,
	      [Define to 1 if you have a fully functional readline library.])
           AC_SUBST(LIBREADLINE,$_combo)

	   AC_CHECK_LIB(readline, history_list,
		[AC_DEFINE(HAVE_HISTORY_LIST, 1, [Do we have history_list?])],
		[],
		[$_combo])

           break
        fi
     done

     unset _termcap
     unset _readline_save_libs
     unset _combo
     unset _found_readline
  fi
])dnl
