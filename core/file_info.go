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
	CreatedDT  time.Time
	ModifiedDT time.Time
}

func (c *FileInfo) DisplayName() string {
	if c.IsDir {
		return "[" + c.ShortName + "]"
	}
	return c.ShortName
}

func (c *FileInfo) DisplayType() string {
	if c.IsDir {
		return ""
	}
	return c.Extension
}

func (c *FileInfo) DisplaySize() string {
	if c.IsDir {
		return "[DIR]"
	}
	return strconv.FormatInt(c.Size, 10)
}
