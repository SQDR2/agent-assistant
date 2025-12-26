//go:build windows

package main

import (
	"os"
	"syscall"
)

const (
	// _O_BINARY is the flag to set binary mode on Windows
	// This prevents automatic \n -> \r\n conversion
	_O_BINARY = 0x8000
)

var (
	msvcrt         = syscall.NewLazyDLL("msvcrt.dll")
	procSetmode    = msvcrt.NewProc("_setmode")
	procFileno     = msvcrt.NewProc("_fileno")
	procGetOsfHandle = syscall.NewLazyDLL("kernel32.dll").NewProc("GetStdHandle")
)

func init() {
	// Set stdin and stdout to binary mode on Windows
	// This prevents automatic \n -> \r\n conversion which breaks JSON-RPC protocol
	setStdioBinaryMode()
}

func setStdioBinaryMode() {
	// Set stdin (fd 0) to binary mode
	setmode(int(os.Stdin.Fd()), _O_BINARY)
	// Set stdout (fd 1) to binary mode
	setmode(int(os.Stdout.Fd()), _O_BINARY)
	// Set stderr (fd 2) to binary mode as well
	setmode(int(os.Stderr.Fd()), _O_BINARY)
}

func setmode(fd int, mode int) {
	// Call _setmode from msvcrt.dll to set binary mode
	// _setmode returns the previous mode or -1 on error
	procSetmode.Call(uintptr(fd), uintptr(mode))
}
