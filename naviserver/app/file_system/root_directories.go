package file_system

import (
	"encoding/json"
	"naviserver/app/common"
)

type ProcRootDirectoriesResponse struct {
	Directories []string `json:"directories"`
}

func ProcRootDirectories(ctx *common.ExecContext) (respBytes []byte, err error) {
	var resp ProcRootDirectoriesResponse
	resp.Directories = make([]string, 0)
	resp.Directories = append(resp.Directories, "C:")
	resp.Directories = append(resp.Directories, "D:")
	resp.Directories = append(resp.Directories, "E:")
	respBytes, err = json.MarshalIndent(resp, "", " ")
	return
}
