This is the readme for axtam tests.
-----------------------------------

You will currently find one test for Internet Explorer, one for the Windows 
Scripting Host, plus unit tests.

* To test with the Windows Scripting Host (WSH), execute:
  % cscript.exe wsh_simple.es4
  Note you can use either .es4 or .js2 as your file extension.

* To test with Internet Explorer, load 'simple.html' in the browser.  In IE7,
  it will be necessary to enable the engine via the information bar.  Other
  HTML files in this directory should also work without error and will 
  generally print a 'success' message in the browser.

  Note that IE7 disables script error messages by default, so all errors 
  will tend to pass silently.  If you select Tools->Internet Options->Advanced
  and enable "Display a notification about every script error" you will be 
  able to see any such errors.

* To execute unit tests, you need to install Python (http://python.org) and
  the pywin32 extensions (http://sf.net/projects/pywin32).  See the 
  'unittests' directory for the tests that exist.

Note that the only way to see output generated by print is to either execute 
this under the (Windows) debugger and look at the Output Window, or to
execute a script host with a valid stdout handle.  cscript.exe is a console
version of the Windows Scripting Host, so does have a valid stdout - hence 
it is recommended for testing.

