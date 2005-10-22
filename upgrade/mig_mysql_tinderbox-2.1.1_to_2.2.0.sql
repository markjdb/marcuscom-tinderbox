SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS port_fail_reasons;
CREATE TABLE port_fail_reasons (
  Port_Fail_Reason_Tag varchar(20) NOT NULL,
  Port_Fail_Reason_Descr text,
  Port_Fail_Reason_Type enum('COMMON','RARE','TRANSIENT') NOT NULL DEFAULT 'COMMON',
  PRIMARY KEY (Port_Fail_Reason_Tag)
) TYPE=INNODB;

ALTER TABLE build_ports
  ADD Last_Fail_Reason varchar(20) NOT NULL DEFAULT '__nofail__',
  ADD INDEX (Last_Fail_Reason),
  ADD FOREIGN KEY (Last_Fail_Reason)
    REFERENCES port_fail_reasons(Port_Fail_Reason_Tag)
    ON UPDATE CASCADE ON DELETE RESTRICT;

DROP TABLE IF EXISTS port_fail_patterns;
CREATE TABLE port_fail_patterns (
  Port_Fail_Pattern_Id int NOT NULL,
  Port_Fail_Pattern_Expr text NOT NULL,
  Port_Fail_Pattern_Reason varchar(20) NOT NULL,
  Port_Fail_Pattern_Parent int NOT NULL DEFAULT 0,
  PRIMARY KEY (Port_Fail_Pattern_Id),
  INDEX Port_Fail_Pattern_Parent_Idx (Port_Fail_Pattern_Parent),
  INDEX (Port_Fail_Pattern_Reason),
  FOREIGN KEY (Port_Fail_Pattern_Reason)
    REFERENCES port_fail_reasons(Port_Fail_Reason_Tag)
    ON UPDATE CASCADE ON DELETE RESTRICT
) TYPE=INNODB;

INSERT INTO port_fail_reasons VALUES ('__parent__', 'This is a parent reason.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('__nofail__', 'The port was built successfully.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('gcc_bug', 'You have tickled a bug in gcc itself. See the GNU bug report documentation for further information.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('checksum', 'The checksum of one or more of the files is incorrect.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('perl', 'perl is no longer included by default in the base system, but your port\'s configuration process depends on it. While this change helps avoid having a stale version of perl in the base system, it also means that many ports now need to include USE_PERL5.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('threads', 'This port is attempting to use the wrong pthread library.  You should replace static instances of -pthread, -lpthread, and -lc_r with ${PTHREAD_LIBS}.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('distinfo_update', 'The contents of distinfo does not match the list of distfiles or patchfiles.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('apxs', 'Your port depends on Apache (in particular, the apxs binary) but the Makefile doesn\'t have Apache in BUILD_DEPENDS and/or LIB_DEPENDS.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('arch', 'The port does not build on a particular architecture, due to assembler or linker errors. In some easy cases this is due to not picking up the various ARCH configuration variables in the Makefile; you\'ll see this via, e.g., a Sparc make failing while looking for an i386 subdirectory. For the 64-bit architectures, a common problem is the assumption many programmers make that pointers may be cast to and from 32-bit ints. In other cases the problems run much deeper, in which case ONLY_FOR_ARCHS may be needed.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('stl', 'Your port requires the STL library but cannot find it.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('configure_error', 'The port\'s configure script produced some kind of error.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('bison', 'Your port requires bison, which does not exist in 4.x-stable or newer anymore. Either patch it to use byacc instead, or define USE_BISON.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('fetch', 'One or more of the files could not be fetched.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('patch', 'One or more of the patches failed.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('CATEGORIES', 'The CATEGORIES line in Makefile includes an invalid category.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('X_manpage', 'This port does not install a manpage but imake rules are generating commands to convert manpages to HTML format. This is most likely fixed by changing ComplexProgramTarget() in Imakefile to ComplexProgramTargetNoMan(). Note that defining NO_INSTALL_MANPAGES in the Makefile is no longer sufficient in XFree86-4.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('MOTIF', 'This port requires Motif but does not define REQUIRES_MOTIF. See the <a href="http://www.freebsd.org/doc/en_US.ISO8859-1/books/porters-handbook/porting-motif.html">handbook</a> for details.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('MOTIFLIB', 'This port requires Motif but does not refer to the libraries using ${MOTIFLIB}. See <a href="http://www.freebsd.org/doc/en_US.ISO8859-1/books/porters-handbook/porting-motif.html">handbook</a> for details.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('WRKDIR', 'The port is attempting to change something outside ${WRKDIR}. See <a href="http://www.freebsd.org/doc/en_US.ISO8859-1/books/porters-handbook/porting-motif.html">handbook</a> for details.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('texinfo', 'The new makeinfo cannot process a texinfo source file. You can probably add a "--no-validate" option to force it through if you are sure it\'s correct regardless of what makeinfo says.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('perl5', 'There is a problem in processing a perl5 module.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('LIB_DEPENDS', 'The LIB_DEPENDS line specifies a library name incorrectly. This often happens when a port is upgraded and the shared library version number changes.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('ELF', 'The port does not properly work in the new ELF world. It is probably looking for an a.out object (e.g., crt0.o).', 'RARE');
INSERT INTO port_fail_reasons VALUES ('soundcard.h', 'machine/soundcard.h has been moved.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('values.h', '/usr/include/values.h has been removed.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('missing_header', 'There is a missing header file. This is usually caused by either (1) a missing dependency, or (2) specifying an incorrect location with -I in the compiler command line.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('USE_XLIB', 'You should specify USE_XLIB for this port since it appears to use X.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('fetch_timeout', 'Your fetch process was killed because it took too long. (More accurately, it did not produce any output for a long time.) Please put sites with better connectivity near the beginning of MASTER_SITES.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('runaway_process', 'Your make package process was killed because it took too long. (More accurately, it did not produce any output for a long time.) It is probably because there is a process spinning in an infinite loop. Please check the log to determine the exact cause of the problem.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('disk_full', 'The disk filled up on the build system. It is not your fault.', 'TRANSIENT');
INSERT INTO port_fail_reasons VALUES ('compiler_error', 'There is a C compiler error which is caused by something other than e.g. "new compiler error".', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('new_compiler_error', 'The new gcc (2.95.x or above) does not like the source code. This is usually due to stricter C++ type checking or changes in register allocation policy.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('bad_C++_code', 'There is a compiler error which is caused by something specific to C++.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('linker_error', 'There is a linker error which is caused by something other than those flagged by e.g. MOTIF or MOTIFLIB.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('chown', 'POSIX has deprecated the usage "chown user.group filename" in favor of "chown user:group filename". This happened quite some time ago, actually, but it is only now being enforced. (The change was made to allow \'.\' in usernames).', 'RARE');
INSERT INTO port_fail_reasons VALUES ('cgi-bin', 'Your port assumes that a directory (usually /usr/local/www/cgi-bin) already exists, but by default it doesn\'t.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('install_error', 'There was an error during installation.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('manpage', 'There is a manpage listed in a MAN? macro that does not exist or is not installed in the right place.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('DISPLAY', 'This port requires an X display to build. There is nothing you can do about it unless you can somehow make it not require an X connection.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('depend_object', 'The port is trying to reinstall a dependency that already exists. This is usually caused by the first field of a *_DEPENDS line (the obj of obj:dir[:target]) indicating a file that is not installed by the dependency, causing it to be rebuilt even though it has already been added from a package.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('depend_package', 'There was an error during adding dependencies from packages. It is the fault of the package being added, not this port.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('malloc.h', 'Including <malloc.h> is now deprecated in favor of <stdlib.h>.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('coredump', 'Some process in the build chain dropped core. While your port may indeed be faulty, the process that dropped core should also be fixed.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('segfault', 'Some process in the build chain dereferenced a NULL pointer, and encountered a segmentation fault.  While your port may indeed be faulty, the process that dropped core should also be fixed.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('union_wait', 'The compiler could not calculate the storage size of an object, often due to misuse of a union.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('stdio', 'You need to bring your port up to date with the current <stdio.h>.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('struct_changes', 'Your port is trying to refer to structure elements that are not really there. This is often due to changes in the underlying include files.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('alignment', 'You\'ve managed to confuse the assembler with a misaligned structure.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('assert', 'Compilation failed due to an assert. This is often a variation on arch or missing header.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('autoconf', 'Your port depends on autoconf, but the Makefile either doesn\'t have USE_AUTOCONF, or does not use USE_AUTOCONF_VER correctly.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('autoheader', 'Your port depends on autoheader, but the Makefile cannot find it; set USE_AUTOHEADER.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('automake', 'Your port depends on automake, but the Makefile either doesn\'t have USE_AUTOMAKE, or does not use USE_AUTOMAKE_VER correctly.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('awk', 'awk is complaining about some kind of bogus string expression.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('ffs_conflict', 'Both /usr/include/machine/cpufunc.h and /usr/include/strings.h are attempting to define int ffs(). The "correct" fix is not known at this time.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('forbidden', 'Someone has marked this port as "forbidden", almost always due to security concerns. See the logfile for more information.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('getopt', 'Your port may need to set the new port variable USE_GETOPT_LONG.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('getopt.h', '<getopt.h> is conflicting with unistd.h.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('imake', 'Imake has encountered a problem.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('makefile', 'There is an error in the Makefile, possibly in the default targets.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('mtree', 'The port leaves ${PREFIX} in a state that is not consistent with the mtree definition after pkg_delete. This usually means some files are missing from PLIST. It could also mean that your installation scripts create files or directories not properly deleted by the deinstallation scripts. Another possibility is that your port is deleting some directories it is not supposed to, or incorrectly modifying some directory\'s permission.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('pod2man', 'perl is no longer included by default in the base system, but your port\'s documentation process depends on it. While this change helps avoid having a stale version of perl in the base system, it also means that many ports now need to include USE_PERL5.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('portcomment', 'The COMMENT macro contains shell metacharacters that are not properly quoted.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('process_failed', 'The make process terminated unexpectedly, due to something like a signal 6 or bus error.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('python', 'The Makefile needs to define USE_PYTHON.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('sed', 'sed is complaining about some kind of bogus regular expression, probably as a side-effect of its being invoked by ${REINPLACE_COMMAND}. This is often a result of having replaced usages of perl in the Makefile with usages of ${REINPLACE_COMMAND} but having left perl-specific regexps in place.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('varargs', '<varags.h> is obsolete; use <stdarg.h> instead.', 'RARE');
INSERT INTO port_fail_reasons VALUES ('NFS', 'There was either a temporary NFS error on the build system (which is not your fault), or the WRKSRC is invalid (which is your fault).', 'TRANSIENT');
INSERT INTO port_fail_reasons VALUES ('PLIST', 'There is a missing item in the PLIST. Note that this is often caused by an earlier error that went undetected. In this case, you should fix the error and also the build process so it will fail upon an error instead of continuing, since that makes debugging that much harder.', 'COMMON');
INSERT INTO port_fail_reasons VALUES ('???', 'The automated script cannot even guess what is wrong with your port. Either the script is really stupid (more likely), or your port has ventured into unknown lands (congratulations!).', 'COMMON');

INSERT INTO port_fail_patterns VALUES (0, '.*', '__parent__', 0);
INSERT INTO port_fail_patterns VALUES (100, 'See <URL:http://gcc.gnu.org/bugs.html> for instructions.', 'gcc_bug', 0);
INSERT INTO port_fail_patterns VALUES (200, 'See <URL:http://www.gnu.org/software/gcc/bugs.html> for instructions.', 'gcc_bug', 0);
INSERT INTO port_fail_patterns VALUES (300, 'Checksum mismatch', 'checksum', 0);
INSERT INTO port_fail_patterns VALUES (400, '/usr/local/bin/(perl|perl5.6.1):.*(not found|No such file or directory)', 'perl', 0);
INSERT INTO port_fail_patterns VALUES (500, 'perl(.*): Perl is not installed, try .pkg_add -r perl.', 'perl', 0);
INSERT INTO port_fail_patterns VALUES (600, 'cannot find -lc_r', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (700, 'checking for.*lc_r\\.\\.\\. no', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (800, '(No checksum recorded for|(Maybe|Either) .* is out of date, or)', 'distinfo_update', 0);
INSERT INTO port_fail_patterns VALUES (900, 'checking whether apxs works.*apxs: not found', 'apxs', 0);
INSERT INTO port_fail_patterns VALUES (1000, 'Configuration .* not supported', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (1100, '(configure: error:|Script.*configure.*failed unexpectedly|script.*failed: here are the contents of)', '__parent__', 0);
INSERT INTO port_fail_patterns VALUES (1200, 'configure: error: cpu .* not supported', 'arch', 1100);
INSERT INTO port_fail_patterns VALUES (1300, 'configure: error: (This program requires STL to compile|One or more.*STL headers are missing)', 'stl', 1100);
INSERT INTO port_fail_patterns VALUES (1400, 'configure: error: [Pp]erl (5.* required|version too old)', 'perl', 1100);
INSERT INTO port_fail_patterns VALUES (1500, '.*', 'configure_error', 1100);
INSERT INTO port_fail_patterns VALUES (1600, '(bison:.*(No such file|not found)|multiple definition of `yy)', 'bison', 0);
INSERT INTO port_fail_patterns VALUES (1700, 'Couldn.t fetch it - please try', 'fetch', 0);
INSERT INTO port_fail_patterns VALUES (1800, 'out of .* hunks .*--saving rejects to', 'patch', 0);
INSERT INTO port_fail_patterns VALUES (1900, 'Error: category .* not in list of valid categories', 'CATEGORIES', 0);
INSERT INTO port_fail_patterns VALUES (2000, 'make: don.t know how to make .*\\.man. Stop', 'X_manpage', 0);
INSERT INTO port_fail_patterns VALUES (2100, 'Xm/Xm\\.h: No such file', 'MOTIF', 0);
INSERT INTO port_fail_patterns VALUES (2200, 'undefined reference to `Xp', 'MOTIFLIB', 0);
INSERT INTO port_fail_patterns VALUES (2300, 'read-only file system', 'WRKDIR', 0);
INSERT INTO port_fail_patterns VALUES (2400, 'makeinfo: .* use --force', 'texinfo', 0);
INSERT INTO port_fail_patterns VALUES (2500, 'means that you did not run the h2ph script', 'perl5', 0);
INSERT INTO port_fail_patterns VALUES (2600, 'Error: shared library ".*" does not exist', 'LIB_DEPENDS', 0);
INSERT INTO port_fail_patterns VALUES (2700, '(crt0|c\\+\\+rt0)\\.o: No such file', 'ELF', 0);
INSERT INTO port_fail_patterns VALUES (2800, 'machine/soundcard.h: No such file or directory', 'soundcard.h', 0);
INSERT INTO port_fail_patterns VALUES (2900, 'values.h: No such file or directory', 'values.h', 0);
INSERT INTO port_fail_patterns VALUES (3000, '.*\\.h: No such file', '__parent__', 0);
INSERT INTO port_fail_patterns VALUES (3100, '(X11/.*|Xosdefs)\\.h: No such file', '__parent__', 3000);
INSERT INTO port_fail_patterns VALUES (3200, 'XFree86-.*\\.tgz', 'missing_header', 3100);
INSERT INTO port_fail_patterns VALUES (3300, '.*', 'USE_XLIB', 3100);
INSERT INTO port_fail_patterns VALUES (3400, '.*', 'missing_header', 3000);
INSERT INTO port_fail_patterns VALUES (3500, 'pnohang: killing make checksum', 'fetch_timeout', 0);
INSERT INTO port_fail_patterns VALUES (3600, 'USER   PID  PPID  PGID JOBC STAT  TT       TIME COMMAND', 'runaway_process', 0);
INSERT INTO port_fail_patterns VALUES (3700, 'pnohang: killing make package', 'runaway_process', 0);
INSERT INTO port_fail_patterns VALUES (3800, 'pkg_add: (can.t find enough temporary space|projected size of .* exceeds available free space)', 'disk_full', 0);
INSERT INTO port_fail_patterns VALUES (3900, '(parse error|too (many|few) arguments to|argument.*doesn.*prototype|incompatible type for argument|conflicting types for|undeclared \\(first use (in |)this function\\)|incorrect number of parameters|has incomplete type and cannot be initialized)', 'compiler_error', 0);
INSERT INTO port_fail_patterns VALUES (4000, '(ANSI C.. forbids|is a contravariance violation|changed for new ANSI .for. scoping|[0-9]: passing .* changes signedness|discards qualifiers|lacks a cast|redeclared as different kind of symbol|invalid type .* for default argument to|wrong type argument to unary exclamation mark|duplicate explicit instantiation of|incompatible types in assignment|assuming . on overloaded member function|call of overloaded .* is ambiguous|declaration of C function .* conflicts with|initialization of non-const reference type|using typedef-name .* after|[0-9]: implicit declaration of function|[0-9]: size of array .* is too large|fixed or forbidden register .* for class)', 'new_compiler_error', 0);
INSERT INTO port_fail_patterns VALUES (4100, '(syntax error before|ISO C\\+\\+ forbids|friend declaration|no matching function for call to|.main. must return .int.|invalid conversion from|cannot be used as a macro name as it is an operator in C\\+\\+|is not a member of type|after previous specification in|no class template named|because worst conversion for the former|better than worst conversion|no match for.*operator|no match for call to|undeclared in namespace|is used as a type, but is not)', 'bad_C++_code', 0);
INSERT INTO port_fail_patterns VALUES (4200, '(/usr/libexec/elf/ld: cannot find|undefined reference to|cannot open -l.*: No such file)', 'linker_error', 0);
INSERT INTO port_fail_patterns VALUES (4300, 'chown:.*[Ii]nvalid argument', 'chown', 0);
INSERT INTO port_fail_patterns VALUES (4400, 'install: .*: No such file', '__parent__', 0);
INSERT INTO port_fail_patterns VALUES (4500, 'install: /usr/local/www/cgi-bin.*No such file or directory', 'cgi-bin', 4400);
INSERT INTO port_fail_patterns VALUES (4600, '.*', 'install_error', 4400);
INSERT INTO port_fail_patterns VALUES (4700, '/usr/.*/man/.*: No such file or directory', 'manpage', 0);
INSERT INTO port_fail_patterns VALUES (4800, '(Can.t|unable to) open display', 'DISPLAY', 0);
INSERT INTO port_fail_patterns VALUES (4900, ' is already installed - perhaps an older version', 'depend_object', 0);
INSERT INTO port_fail_patterns VALUES (5000, 'You may wish to ..make deinstall.. and install this port again', 'depend_object', 0);
INSERT INTO port_fail_patterns VALUES (5100, 'error in dependency .*, exiting', 'depend_package', 0);
INSERT INTO port_fail_patterns VALUES (5200, '#error "<malloc.h> has been replaced by <stdlib.h>"', 'malloc.h', 0);
INSERT INTO port_fail_patterns VALUES (5300, 'core dumped', 'coredump', 0);
INSERT INTO port_fail_patterns VALUES (5400, 'Segmentation fault', 'segfault', 0);
INSERT INTO port_fail_patterns VALUES (5500, 'storage size of.*isn.t known', 'union_wait', 0);
INSERT INTO port_fail_patterns VALUES (5600, 'initializer element is not constant', 'stdio', 0);
INSERT INTO port_fail_patterns VALUES (5700, 'structure has no member named', 'struct_changes', 0);
INSERT INTO port_fail_patterns VALUES (5800, 'Error: alignment not a power of 2', 'alignment', 0);
INSERT INTO port_fail_patterns VALUES (5900, 'bin.apxs:(.)(not found|No such file or directory)', 'apxs', 0);
INSERT INTO port_fail_patterns VALUES (6000, 'failed to exec .*bin/apxs', 'apxs', 0);
INSERT INTO port_fail_patterns VALUES (6100, '.s: Assembler messages:', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6200, 'Cannot (determine .* target|find the byte order) for this architecture', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6300, 'cast from pointer to integer of different size', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6400, '^cc1: bad value.*for -mcpu.*switch', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6500, '^cc1: invalid option ', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6600, 'could not read symbols: File in wrong format', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6700, '[Ee]rror: [Uu]nknown opcode', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6800, 'error.*Unsupported architecture', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (6900, 'ENDIAN must be defined 0 or 1', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7000, 'failed to merge target-specific data', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7100, '(file not recognized|failed to set dynamic section sizes): File format not recognized', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7200, 'impossible register constraint', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7300, 'inconsistent operand constraints in an .asm', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7400, 'invalid lvalue in asm statement', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7500, 'is only for.*, and you are running', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7600, 'not a valid 64 bit base/index expression', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7700, 'relocation R_X86_64_32.*can not be used when making a shared object', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7800, 'relocation truncated to fit: ', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (7900, 'The target cpu, .*, is not currently supported.', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (8000, 'This architecture seems to be neither big endian nor little endian', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (8100, 'unknown register name', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (8200, 'Unable to correct byte order', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (8300, 'Unsupported platform, sorry', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (8400, 'won.t run on this architecture', 'arch', 0);
INSERT INTO port_fail_patterns VALUES (8500, '#error .Cannot compile:', 'assert', 0);
INSERT INTO port_fail_patterns VALUES (8600, 'autoconf(.*): not found', 'autoconf', 0);
INSERT INTO port_fail_patterns VALUES (8700, 'autoconf(.*): No such file or directory', 'autoconf', 0);
INSERT INTO port_fail_patterns VALUES (8800, 'autoheader: not found', 'autoheader', 0);
INSERT INTO port_fail_patterns VALUES (8900, 'automake(.*): not found', 'automake', 0);
INSERT INTO port_fail_patterns VALUES (9000, 'awk: empty regular expression', 'awk', 0);
INSERT INTO port_fail_patterns VALUES (9100, '(mv:|mv: rename|cannot open) y.tab.c(.*): No such file or directory', 'bison', 0);
INSERT INTO port_fail_patterns VALUES (9200, 'sorry, cannot determine the header file bison generates', 'bison', 0);
INSERT INTO port_fail_patterns VALUES (9300, 'usage: yacc', 'bison', 0);
INSERT INTO port_fail_patterns VALUES (9400, '/usr/local/www/cgi-bin does not exist', 'cgi-bin', 0);
INSERT INTO port_fail_patterns VALUES (9500, 'Cannot open /dev/tty for read', 'DISPLAY', 0);
INSERT INTO port_fail_patterns VALUES (9600, 'RuntimeError: cannot open display', 'DISPLAY', 0);
INSERT INTO port_fail_patterns VALUES (9700, 'You must run this program under the X-Window System', 'DISPLAY', 0);
INSERT INTO port_fail_patterns VALUES (9800, 'ld: unrecognised emulation mode: elf_i386', 'ELF', 0);
INSERT INTO port_fail_patterns VALUES (9900, 'Member name contains .\\.\\./', 'fetch', 0);
INSERT INTO port_fail_patterns VALUES (10000, 'fetch: transfer timed out', 'fetch_timeout', 0);
INSERT INTO port_fail_patterns VALUES (10100, 'fetch: transfer timed out', 'fetch_timeout', 0);
INSERT INTO port_fail_patterns VALUES (10200, 'strings.h:.* previous declaration of .int ffs', 'ffs_conflict', 0);
INSERT INTO port_fail_patterns VALUES (10300, 'is forbidden: FreeBSD-SA-', 'forbidden', 0);
INSERT INTO port_fail_patterns VALUES (10400, '/usr/bin/ld: cannot find -lgnugetopt', 'getopt', 0);
INSERT INTO port_fail_patterns VALUES (10500, 'previous declaration.*int getopt', 'getopt.h', 0);
INSERT INTO port_fail_patterns VALUES (10600, 'imake: Exit code 1', 'imake', 0);
INSERT INTO port_fail_patterns VALUES (10700, 'Run-time system build failed for some reason', 'install_error', 0);
INSERT INTO port_fail_patterns VALUES (10800, '/usr/bin/ld: cannot find -lc_r', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (10900, 'cc: .*libintl.*: No such file or directory', 'linker_error', 0);
INSERT INTO port_fail_patterns VALUES (11000, 'cc: ndbm\\.so: No such file or directory', 'linker_error', 0);
INSERT INTO port_fail_patterns VALUES (11100, 'error: The X11 shared library could not be loaded', 'linker_error', 0);
INSERT INTO port_fail_patterns VALUES (11200, 'relocation against dynamic symbol', 'linker_error', 0);
INSERT INTO port_fail_patterns VALUES (11300, 'make.*(don.t know how to make|fatal errors encountered|No rule to make target|built-in)', 'makefile', 0);
INSERT INTO port_fail_patterns VALUES (11400, 'Error: mtree file ./etc/mtree/BSD.local.dist. is missing', 'mtree', 0);
INSERT INTO port_fail_patterns VALUES (11500, 'cp:.*site_perl: No such file or directory', 'perl', 0);
INSERT INTO port_fail_patterns VALUES (11600, 'Perl .* required--this is only version', 'perl', 0);
INSERT INTO port_fail_patterns VALUES (11700, 'pod2man: not found', 'pod2man', 0);
INSERT INTO port_fail_patterns VALUES (11800, 'Syntax error: .\\(. unexpected \\(expecting .fi.\\)', 'portcomment', 0);
INSERT INTO port_fail_patterns VALUES (11900, 'Abort trap', 'process_failed', 0);
INSERT INTO port_fail_patterns VALUES (12000, 'Bus error', 'process_failed', 0);
INSERT INTO port_fail_patterns VALUES (12100, 'Signal 11', 'process_failed', 0);
INSERT INTO port_fail_patterns VALUES (12200, 'python: not found', 'python', 0);
INSERT INTO port_fail_patterns VALUES (12300, 'sed: illegal option', 'sed', 0);
INSERT INTO port_fail_patterns VALUES (12400, 'sed: [0-9]*:.*(RE error:|not defined in the RE|bad flag in substitute command|unescaped newline inside substitute pattern|invalid command code)', 'sed', 0);
INSERT INTO port_fail_patterns VALUES (12500, 'Your STL string implementation is unusable', 'stl', 0);
INSERT INTO port_fail_patterns VALUES (12600, ': The -pthread option is deprecated', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (12700, 'Error: pthreads are required to build this package', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (12800, 'Please install/update your POSIX threads (pthreads) library', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (12900, 'requires.*thread support', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (13000, '/usr/bin/ld: cannot find -lpthread', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (13100, '/usr/bin/ld: cannot find -lXThrStub', 'threads', 0);
INSERT INTO port_fail_patterns VALUES (13200, '<varargs.h> is obsolete with this version of GCC', 'varargs', 0);
INSERT INTO port_fail_patterns VALUES (13300, 'Cannot stat: ', 'configure_error', 0);
INSERT INTO port_fail_patterns VALUES (13400, 'cd: can.t cd to', 'NFS', 0);
INSERT INTO port_fail_patterns VALUES (13500, 'pkg_create: make_dist: tar command failed with code', 'PLIST', 0);
INSERT INTO port_fail_patterns VALUES (2147483647, '.*', '???', 0);

UPDATE config SET Config_Option_Value='2.2.0' WHERE Config_Option_Name='__DSVERSION__';

SET FOREIGN_KEY_CHECKS=1;
