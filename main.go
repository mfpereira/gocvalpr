package main

import (
	"fmt"

	"os"
	"os/exec"

	"gocv.io/x/gocv"
)

func main() {
	fmt.Printf("gocv version: %s\n", gocv.Version())
	fmt.Printf("opencv lib version: %s\n", gocv.OpenCVVersion())

	alprExecutable, _ := exec.LookPath("alpr")

	alprCommandVersion := &exec.Cmd{
		Path:   alprExecutable,
		Args:   []string{alprExecutable, "--version"},
		Stdout: os.Stdout,
		Stderr: os.Stderr,
	}

	if err := alprCommandVersion.Run(); err != nil {
		fmt.Println("Error running alpr: ", err)
	}
}
