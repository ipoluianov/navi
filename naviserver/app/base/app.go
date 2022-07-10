package base

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"naviserver/app/common"
	"naviserver/app/file_system"
	"strings"
	"sync"
)

type App struct {
	mtx sync.Mutex
}

func NewApp() *App {
	var c App
	return &c
}

func (c *App) Exec(line string) {
	indexOfSeparator := strings.Index(line, ":")
	if indexOfSeparator < 0 {
		return
	}
	transactionId := line[:indexOfSeparator]
	request := line[indexOfSeparator+1:]

	var ctx common.ExecContext
	ctx.TransactionId = transactionId
	ctx.Request = request

	go c.process(&ctx)
}

func (c *App) process(ctx *common.ExecContext) {
	var respBytes []byte
	var err error

	type FunctionContainer struct {
		Function string `json:"f"`
	}

	var fc FunctionContainer
	err = json.Unmarshal([]byte(ctx.Request), &fc)
	if err == nil {
		ctx.Function = fc.Function
		respBytes, err = c.call(ctx)
	}
	c.print(ctx, respBytes, err)
}

func (c *App) call(ctx *common.ExecContext) (respBytes []byte, err error) {
	switch ctx.Function {
	case "root-directries":
		return file_system.ProcRootDirectories(ctx)
	case "directory-content":
		return file_system.ProcDirectoryContent(ctx)
	case "directory-create":
		return file_system.ProcDirectoryCreate(ctx)
	default:
		return nil, errors.New("wrong function")
	}
}

func (c *App) print(ctx *common.ExecContext, respBytes []byte, err error) {
	resLine := ""
	c.mtx.Lock()
	if err == nil {
		resLine = ctx.TransactionId + ":=" + string(respBytes)
	} else {
		resLine = ctx.TransactionId + ":!" + err.Error()
	}
	b64 := base64.StdEncoding.EncodeToString([]byte(resLine))
	fmt.Println(b64)
	c.mtx.Unlock()
}
