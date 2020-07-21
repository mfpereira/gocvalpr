package main

import (
	"fmt"
	"io/ioutil"

	"os"
	"os/exec"

	"github.com/openalpr/openalpr/src/bindings/go/openalpr"
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

	alpr := openalpr.NewAlpr("us", "", "./runtime_data")
	defer alpr.Unload()

	if !alpr.IsLoaded() {
		fmt.Println("OpenAlpr failed to load!")
		return
	}
	alpr.SetTopN(20)

	fmt.Println(alpr.IsLoaded())
	fmt.Println(openalpr.GetVersion())

	resultFromFilePath, err := alpr.RecognizeByFilePath("/go/src/app/lp.jpg")
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("%+v\n", resultFromFilePath)
	fmt.Printf("\n\n\n")

	imageBytes, err := ioutil.ReadFile("lp.jpg")
	if err != nil {
		fmt.Println(err)
	}
	resultFromBlob, err := alpr.RecognizeByBlob(imageBytes)
	fmt.Printf("%+v\n", resultFromBlob)
}
