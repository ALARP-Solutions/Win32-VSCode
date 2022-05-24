<div align="center">
  <a href="https://github.com/ALARP-Solutions/WIN32-VSCODE">
    <img src="Icon.png" alt="Logo" width="80" height="80">
  </a>
  <h1>Win32 Builder - Visual Studio Code</h1>
</div>

## Configuring VSCode

### App Information
| Field | Data |
| --- | --- |
| Name | Visual Studio Code |
| Description | Visual Studio Code is a lightweight but powerful source code editor which runs on your desktop and is available for Windows, macOS and Linux. It comes with built-in support for JavaScript, TypeScript and Node.js and has a rich ecosystem of extensions for other languages (such as C++, C#, Java, Python, PHP, Go) and runtimes (such as .NET and Unity). |
| Publisher | Microsoft |
| Information URL | https://code.visualstudio.com/docs |
| Privacy URL | https://privacy.microsoft.com/privacystatement |
| Category | Utilities & Tools |
| Logo | See Icon.png |
## Commands

Install: Install.cmd
Uninstall: Uninstall.cmd

## Detection Rule

Type:       File
Path:       C:\Program Files\Microsoft VS Code
File:       Code.exe


Key Path:   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{EA457B21-F73E-494C-ACAB-524FDE069978}_is1
Value:      DisplayVersion

