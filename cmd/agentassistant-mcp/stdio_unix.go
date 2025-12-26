//go:build !windows

package main

// init is a no-op on non-Windows platforms
// On Unix-like systems, stdio is already in binary mode
func init() {
	// No special initialization needed for Unix systems
}
