package file_system

import (
	"encoding/json"
	"naviserver/app/common"
	"os"
)

type ProcDirectoryCreateRequest struct {
	Path string `json:"path"`
}

type ProcDirectoryCreateResult struct {
}

func ProcDirectoryCreate(ctx *common.ExecContext) (respBytes []byte, err error) {
	var req ProcDirectoryCreateRequest
	err = json.Unmarshal([]byte(ctx.Request), &req)
	if err != nil {
		return
	}

	err = os.MkdirAll(req.Path, 0666)
	if err != nil {
		return
	}

	var resp ProcDirectoryContentResult
	respBytes, err = json.MarshalIndent(resp, "", " ")
	return
}
