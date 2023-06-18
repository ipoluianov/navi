package core

import (
	"io/fs"
	"io/ioutil"
	"path/filepath"
)

func GetDirectoryContent(path string) (items []FileInfo, err error) {
	var entries []fs.FileInfo
	entries, err = ioutil.ReadDir(path)
	for _, entry := range entries {
		var fi FileInfo
		fi.FullName = path + "/" + entry.Name()
		fi.Path = entry.Name()
		fi.ShortName = entry.Name()
		if entry.IsDir() || (len(entry.Name()) > 0 && entry.Name()[0] == '.') {
			// Empty Extension for:
			// - dirs
			// - 'hidden' files (.filename)
			fi.Extension = ""
		} else {
			fi.Extension = filepath.Ext(entry.Name())
			if len(fi.Extension) > 0 && fi.Extension[0] == '.' {
				// Remote first dot
				fi.Extension = fi.Extension[1:]
			}
		}
		fi.IsDir = entry.IsDir()
		items = append(items, fi)
	}
	return
}
