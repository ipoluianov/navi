package file_system

import (
	"encoding/json"
	"fmt"
	"naviserver/app/common"
	"testing"
)

func TestProcRootDirectories(t *testing.T) {
	fmt.Println("ProcRootDirectories")
	var ctx common.ExecContext
	respBytes, err := ProcRootDirectories(&ctx)
	if err != nil {
		t.Fatal(err)
	}

	var v ProcRootDirectoriesResponse
	json.Unmarshal(respBytes, &v)
	if err != nil {
		t.Fatal(err)
	}

	for _, i := range v.Directories {
		fmt.Println(i)
	}
}

func TestDirectoryContent(t *testing.T) {
	fmt.Println("DirectoryContent")
	var ctx common.ExecContext

	var req ProcDirectoryContentRequest
	req.Path = "d:\\System Volume Information"
	reqBS, err := json.Marshal(req)
	ctx.Request = string(reqBS)

	respBytes, err := ProcDirectoryContent(&ctx)
	if err != nil {
		t.Fatal(err)
	}

	var v ProcDirectoryContentResult
	json.Unmarshal(respBytes, &v)
	if err != nil {
		t.Fatal(err)
	}

	for _, i := range v.Entries {
		fmt.Println(i)
	}
}
