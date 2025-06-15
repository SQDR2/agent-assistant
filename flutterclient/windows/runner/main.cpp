#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <Shlwapi.h> // For PathRemoveFileSpecW

#include "flutter_window.h"
#include "utils.h"

// Link with Shlwapi.lib
#pragma comment(lib, "Shlwapi.lib")

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

  // Launch agentassistant-srv.exe in a hidden window
  ShellExecuteW(nullptr, L"open", srv_path, nullptr, nullptr, SW_HIDE);
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

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
