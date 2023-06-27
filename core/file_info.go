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
	IsSymlink  bool
	CreatedDT  time.Time
	ModifiedDT time.Time

	Error string
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
		return ""
	}
	if c.IsDir {
		return ""
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
	sizeStr := strconv.FormatInt(c.Size, 10)
	result := make([]byte, 0)
	for i := 0; i < len(sizeStr); i++ {
		result = append(result, sizeStr[i])
		if ((len(sizeStr) - i - 1) % 3) == 0 {
			result = append(result, ' ')
		}
	}
	return string(result)
}

func (c *FileInfo) DisplayDateTime() string {
	return c.ModifiedDT.Format("2006-01-02 15:04")
}

func (c *FileInfo) DisplayAttr() string {

	return "----"
}
