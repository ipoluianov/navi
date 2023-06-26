package core

import (
	"strconv"
	"time"
)

type FileInfo struct {
	Path       string
	ShortName  string
	Extension  string
	FullName   string
	Owner      string
	Size       int64
	IsDir      bool
	IsUpDir    bool
	CreatedDT  time.Time
	ModifiedDT time.Time
}

func (c *FileInfo) DisplayName() string {
	if c.IsUpDir {
		return "[..]"
	}
	if c.IsDir {
		return "[" + c.ShortName + "]"
	}
	return c.ShortName
}

func (c *FileInfo) DisplayType() string {
	if c.IsUpDir {
		return "<DIR>"
	}
	if c.IsDir {
		return "<DIR>"
	}
	return c.Extension
}

func (c *FileInfo) DisplaySize() string {
	if c.IsUpDir {
		return ""
	}
	if c.IsDir {
		return "[DIR]"
	}
	return strconv.FormatInt(c.Size, 10)
}
