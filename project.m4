# Use the trick for checking whether the configure script needs to be
#   re-run via Makefile.in, as described in the autoconf manual.
AC_CONFIG_FILES([include/stamp-h], [echo timestamp > include/stamp-h])

# Make sure we're using bash and not for example dash.
AC_CHECK_PROG([BASH], [bash], [bash], [no])
if test "${BASH}" = no ; then
   AC_MSG_ERROR([bash shell was not found.])
fi

# Look for Python >= 2.7 or 3.2.
AC_CHECK_PROGS([PYTHON],
	[python3.5 python3.4 python3.3 python3.2 python2.9 python2.8 python2.7], [no])
if test "${PYTHON}" = no ; then
   AC_MSG_WARN([Python >= 2.7 or >= 3.2 was not found.  (Python 3.1 or 3.0 will not work, since Python -B -m unittest was broken.)  Unit tests will not be available.])
fi

# If LIBTOOL is not already defined, then make sure we have GNU libtool.
if test -z "${LIBTOOL}"; then
AC_CHECK_PROGS([LIBTOOL], [glibtool libtool], [no])
	if test "${LIBTOOL}" = no ; then
		AC_MSG_ERROR([glibtool was not found.])
	fi
fi

# OS X:
AC_CHECK_FUNCS([_NSGetExecutablePath])

# Linux:
AC_CHECK_FILE([/proc/self/exe],
	      [AC_DEFINE([HAVE_PROC_SELF_EXE], 1,
	                 [Define to 1 if /proc/self/exe exists.])])

