#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <Shlwapi.h> // For PathRemoveFileSpecW

#include "flutter_window.h"
#include "utils.h"

// Link with Shlwapi.lib
#pragma comment(lib, "Shlwapi.lib")

// Static variable to hold the process handle of agentassistant-srv.exe
static HANDLE srv_process_handle = nullptr;

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command)
{
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent())
  {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // --- Start agentassistant-srv.exe ---
  wchar_t module_path[MAX_PATH];
  GetModuleFileNameW(nullptr, module_path, MAX_PATH);
  PathRemoveFileSpecW(module_path); // Now module_path contains the directory of the executable

  // Construct the full path to agentassistant-srv.exe
  wchar_t srv_path[MAX_PATH];
  swprintf_s(srv_path, MAX_PATH, L"%s\\agentassistant-srv.exe", module_path);

  STARTUPINFOW si;
  PROCESS_INFORMATION pi;
  ZeroMemory(&si, sizeof(si));
  si.cb = sizeof(si);
  si.dwFlags = STARTF_USESHOWWINDOW;
  si.wShowWindow = SW_HIDE; // Hide the console window
  ZeroMemory(&pi, sizeof(pi));

  // Create the child process.
  if (CreateProcessW(
          NULL,             // No module name (use command line)
          srv_path,         // Command line
          NULL,             // Process handle not inheritable
          NULL,             // Thread handle not inheritable
          FALSE,            // Set handle inheritance to FALSE
          CREATE_NO_WINDOW, // Do not create a console window
          NULL,             // Use parent's environment block
          NULL,             // Use parent's starting directory
          &si,              // Pointer to STARTUPINFO structure
          &pi               // Pointer to PROCESS_INFORMATION structure
          ))
  {
    // Store the process handle
    srv_process_handle = pi.hProcess;
    // Close the thread handle immediately as we don't need it
    CloseHandle(pi.hThread);
  }
  // --- End agentassistant-srv.exe startup ---

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"agent-assistant", origin, size))
  {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0))
  {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // --- Terminate agentassistant-srv.exe ---
  if (srv_process_handle)
  {
    TerminateProcess(srv_process_handle, 0); // Terminate with exit code 0
    CloseHandle(srv_process_handle);
  }
  // --- End agentassistant-srv.exe termination ---

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
