package file_system

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"io/ioutil"
	"naviserver/app/common"
)

type ProcDirectoryContentRequest struct {
	Path string `json:"path"`
}

type ProcDirectoryContentResultEntry struct {
	IsDirectory bool   `json:"is_directory"`
	Path        string `json:"path"`
	Basename    string `json:"basename"`
	Size        int64  `json:"size"`
	SizeString  string `json:"size_string"`
	ModifiedDT  string `json:"modified_dt"`
}

type ProcDirectoryContentResult struct {
	Entries []ProcDirectoryContentResultEntry `json:"entries"`
}

func ProcDirectoryContent(ctx *common.ExecContext) (respBytes []byte, err error) {
	var req ProcDirectoryContentRequest
	err = json.Unmarshal([]byte(ctx.Request), &req)
	if err != nil {
		return
	}

	var fsFileInfo []fs.FileInfo
	fsFileInfo, err = ioutil.ReadDir(req.Path)
	if err != nil {
		return
	}

	var resp ProcDirectoryContentResult
	resp.Entries = make([]ProcDirectoryContentResultEntry, 0)
	for _, f := range fsFileInfo {
		var entry ProcDirectoryContentResultEntry
		entry.IsDirectory = f.IsDir()
		entry.Path = f.Name()
		entry.Basename = f.Name()
		entry.ModifiedDT = f.ModTime().Format("2006-01-02 15:04:05")
		entry.Size = f.Size()
		entry.SizeString = sizeSizeAsString(entry.Size)
		resp.Entries = append(resp.Entries, entry)
	}
	respBytes, err = json.MarshalIndent(resp, "", " ")
	return
}

func reverseBytes(input []byte) []byte {
	if len(input) == 0 {
		return input
	}
	return append(reverseBytes(input[1:]), input[0])
}

func sizeSizeAsString(size int64) string {
	resWithoutSep := fmt.Sprint(size)
	bs := make([]byte, 0)
	counter := 0
	for i := len(resWithoutSep) - 1; i >= 0; i-- {
		bs = append(bs, []byte(resWithoutSep)[i])
		counter++
		if (counter % 3) == 0 {
			bs = append(bs, ' ')
		}
	}
	return string(reverseBytes(bs))
}
