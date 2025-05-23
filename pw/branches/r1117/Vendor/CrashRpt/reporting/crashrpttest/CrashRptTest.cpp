/************************************************************************************* 
  This file is a part of CrashRpt library.

  Copyright (c) 2003, Michael Carruth
  All rights reserved.
 
  Redistribution and use in source and binary forms, with or without modification, 
  are permitted provided that the following conditions are met:
 
   * Redistributions of source code must retain the above copyright notice, this 
     list of conditions and the following disclaimer.
 
   * Redistributions in binary form must reproduce the above copyright notice, 
     this list of conditions and the following disclaimer in the documentation 
     and/or other materials provided with the distribution.
 
   * Neither the name of the author nor the names of its contributors 
     may be used to endorse or promote products derived from this software without 
     specific prior written permission.
 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
***************************************************************************************/

// CrashRptTest.cpp : main source file for CrashRptTest.exe
//

#include "stdafx.h"
#include "resource.h"
#include "MainDlg.h"
#include "CrashThread.h"
#include <shellapi.h>


CAppModule _Module;

LPVOID g_pCrashRptState = NULL;
HANDLE g_hWorkingThread = NULL;
CrashThreadInfo g_CrashThreadInfo;

// Helper function that returns path to application directory
CString GetAppDir()
{
	CString string;
	LPTSTR buf = string.GetBuffer(_MAX_PATH);
	GetModuleFileName(NULL, buf, _MAX_PATH);
	*(_tcsrchr(buf,'\\'))=0; // remove executable name
	string.ReleaseBuffer();
	return string;
}

BOOL WINAPI CrashCallback( PEXCEPTION_POINTERS pExceptionPointers, LPVOID lpvState )
{
  pExceptionPointers;

  CString sLogFile = GetAppDir() + _T("\\dummy.log");
  CString sIniFile = GetAppDir() + _T("\\dummy.ini");

#ifdef TEST_DEPRECATED_FUNCS
  AddFile(lpvState, sLogFile, _T("Dummy Log File"));
  AddFile(lpvState, sLogFile, _T("Dummy INI File"));
#else
  lpvState;
  
  int nResult = crAddFile2(sLogFile, NULL, _T("Dummy Log File"), CR_AF_MAKE_FILE_COPY);
  ATLASSERT(nResult==0);

  nResult = crAddFile(sIniFile, _T("Dummy INI File"));
  ATLASSERT(nResult==0);

  nResult = crAddScreenshot(CR_AS_MAIN_WINDOW);
  ATLASSERT(nResult==0);

  nResult = crAddProperty(_T("VideoCard"),_T("nVidia GeForce 9800"));
  ATLASSERT(nResult==0);

  nResult = crAddRegKey(_T("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer"), _T("regkey.xml"), 0);
  ATLASSERT(nResult==0);

  nResult = crAddRegKey(_T("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"), _T("regkey.xml"), 0);
  ATLASSERT(nResult==0);
  
#endif

  return TRUE;
}

int Run(LPTSTR /*lpstrCmdLine*/ = NULL, int nCmdShow = SW_SHOWDEFAULT)
{
	CMessageLoop theLoop;
	_Module.AddMessageLoop(&theLoop);

  // Get command line params
  LPCWSTR szCommandLine = GetCommandLineW();  
  int argc = 0;
  LPWSTR* argv = CommandLineToArgvW(szCommandLine, &argc);
  
	CMainDlg dlgMain;

  if(argc==2 && wcscmp(argv[1], L"/restart")==0)
    dlgMain.m_bRestarted = TRUE;
  else
    dlgMain.m_bRestarted = FALSE;
  
	if(dlgMain.Create(NULL) == NULL)
	{
		ATLTRACE(_T("Main dialog creation failed!\n"));
		return 0;
	}

	dlgMain.ShowWindow(nCmdShow);

	int nRet = theLoop.Run();

	_Module.RemoveMessageLoop();
	return nRet;
}

namespace
{
  class HiddenException {};
}

static void throw_hidden_exception()
{
  throw HiddenException();
}

int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR lpstrCmdLine, int nCmdShow)
{
	HRESULT hRes = ::CoInitialize(NULL);
// If you are running on NT 4.0 or higher you can use the following call instead to 
// make the EXE free threaded. This means that calls come in on a random RPC thread.
//	HRESULT hRes = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	ATLASSERT(SUCCEEDED(hRes));
  
  // Install crash reporting
#ifdef TEST_DEPRECATED_FUNCS

  g_pCrashRptState = Install(
    CrashCallback, 
    _T("test@hotmail.com"), 
    _T("Crash"));

#else

  CR_INSTALL_INFO info;
  memset(&info, 0, sizeof(CR_INSTALL_INFO));
  info.cb = sizeof(CR_INSTALL_INFO);  
  info.pszAppName = _T("CrashRpt Tests"); // Define application name.
  //info.pszAppVersion = _T("1.2.7");     // Define application version.
  info.pszEmailSubject = _T("Error from CrashRptTests"); // Define subject for email.
  info.pszEmailTo = _T("test@hotmail.com");   // Define E-mail recipient address.  
  info.pszUrl = _T("http://localhost:80/crashrpt.php"); // URL for sending reports over HTTP.
  info.pfnCrashCallback = CrashCallback; // Define crash callback function.   
  // Define delivery transport priorities. 
  info.uPriorities[CR_HTTP] = 3;         // Use HTTP the first.
  info.uPriorities[CR_SMTP] = 2;         // Use SMTP the second.
  info.uPriorities[CR_SMAPI] = 1;        // Use Simple MAPI the last.  
  info.dwFlags = 0;                    
  info.dwFlags |= CR_INST_ALL_EXCEPTION_HANDLERS; // Install all available exception handlers.
  info.dwFlags |= CR_INST_HTTP_BINARY_ENCODING;   // Use binary encoding for HTTP uploads (recommended).  
  info.dwFlags |= CR_INST_APP_RESTART;            // Restart the application on crash.  
  //info.dwFlags |= CR_INST_NO_MINIDUMP;            // Do not include minidump.
  //info.dwFlags |= CR_INST_NO_GUI;                 // Don't display GUI.
  //info.dwFlags |= CR_INST_DONT_SEND_REPORT;       // Don't send report immediately, just queue for delivery.
  //info.dwFlags |= CR_INST_STORE_ZIP_ARCHIVES;    // Store ZIP archives along with uncompressed files (to be used with CR_INST_DONT_SEND_REPORT)
  info.dwFlags |= CR_INST_SEND_QUEUED_REPORTS;    // Send reports that were failed to send recently.
  info.pszDebugHelpDLL = NULL;                    // Search for dbghelp.dll using default search sequence.
  info.uMiniDumpType = MiniDumpNormal;            // Define minidump size.
  // Define privacy policy URL.
  info.pszPrivacyPolicyURL = _T("http://code.google.com/p/crashrpt/wiki/PrivacyPolicyTemplate");
  info.pszErrorReportSaveDir = NULL;       // Save error reports to the default location.
  info.pszRestartCmdLine = _T("/restart"); // Command line for automatic app restart.
  //info.pszLangFilePath = _T("D:\\");       // Specify custom dir or filename for language file.
  //info.pszSmtpProxy = _T("127.0.0.1:2525");  // Use SMTP proxy server.
  
  // Install crash handlers.
  CrAutoInstallHelper cr_install_helper(&info);
  if(cr_install_helper.m_nInstallStatus!=0)
  {
    TCHAR buff[256];
    crGetLastErrorMsg(buff, 256);
    MessageBox(NULL, buff, _T("crInstall error"), MB_OK);
    return FALSE;
  }
  ATLASSERT(cr_install_helper.m_nInstallStatus==0); 

#endif //TEST_DEPRECATED_FUNCS

  //throw_hidden_exception();

  /* Create another thread */
  g_CrashThreadInfo.m_pCrashRptState = g_pCrashRptState;
  g_CrashThreadInfo.m_bStop = false;
  g_CrashThreadInfo.m_hWakeUpEvent = CreateEvent(NULL, FALSE, FALSE, _T("WakeUpEvent"));
  ATLASSERT(g_CrashThreadInfo.m_hWakeUpEvent!=NULL);

  DWORD dwThreadId = 0;
  g_hWorkingThread = CreateThread(NULL, 0, CrashThread, (LPVOID)&g_CrashThreadInfo, 0, &dwThreadId);
  ATLASSERT(g_hWorkingThread!=NULL);

	// this resolves ATL window thunking problem when Microsoft Layer for Unicode (MSLU) is used
	::DefWindowProc(NULL, 0, 0, 0L);

	AtlInitCommonControls(ICC_BAR_CLASSES);	// add flags to support other controls

	hRes = _Module.Init(NULL, hInstance);
	ATLASSERT(SUCCEEDED(hRes));

	int nRet = Run(lpstrCmdLine, nCmdShow);

	_Module.Term();

  // Close another thread
  g_CrashThreadInfo.m_bStop = true;
  SetEvent(g_CrashThreadInfo.m_hWakeUpEvent);
  // Wait until thread terminates
  WaitForSingleObject(g_hWorkingThread, INFINITE);

  
#ifdef TEST_DEPRECATED_FUNCS
  // Uninstall crash reporting
  Uninstall(g_pCrashRptState);

#endif //TEST_DEPRECATED_FUNCS

	::CoUninitialize();

	return nRet;
}
