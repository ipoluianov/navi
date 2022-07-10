package main

import (
	"encoding/base64"
	"fmt"
	"naviserver/app/base"
)

func main() {
	a := base.NewApp()
	var line string
	for {
		_, err := fmt.Scanln(&line)
		if err != nil {
			break
		}

		var lineOriginalBS []byte
		lineOriginalBS, err = base64.StdEncoding.DecodeString(line)
		if err != nil {
			continue
		}
		a.Exec(string(lineOriginalBS))
	}
}
