package log

import (
	"encoding/json"
	"fmt"
	"os"
	"runtime"
)

// DebugMode - print multi-line JSON
var DebugMode bool

// DebugHide - ukrycie logow na poziomie DEBUG
var DebugHide bool

type level string

const (
	// LevelDebug ...
	LevelDebug level = "DEBUG"

	// LevelInfo ...
	LevelInfo level = "INFO"

	// LevelWarning ...
	LevelWarning level = "WARN"

	// LevelError ...
	LevelError level = "ERROR"

	// LevelFatal ...
	LevelFatal level = "FATAL"
)

// TraceS ...
type TraceS struct {
	FilePath     string
	LineNr       int
	FunctionName string
}

// EntryS ...
type EntryS struct {
	// ContextID string        `yaml:"context-id"`
	Level     level         `yaml:"level"`
	Message   string        `yaml:"message"`
	Vars      []interface{} `yaml:"vars"`
	Traceback []TraceS      `yaml:"traceback"`
}

// Vars ...
type Vars map[string]interface{}

// Debug ...
func Debug(in ...interface{}) *EntryS { return entryCreate(LevelDebug, in) }

// Info ...
func Info(in ...interface{}) *EntryS { return entryCreate(LevelInfo, in) }

// Warning ...
func Warning(in ...interface{}) *EntryS { return entryCreate(LevelWarning, in) }

// Error ...
func Error(in ...interface{}) *EntryS { return entryCreate(LevelError, in) }

// Fatal ...
func Fatal(in ...interface{}) *EntryS {
	if entryCreate(LevelFatal, in) != nil {
		os.Exit(1)
	}
	return nil
}

var framesToIgnore = []string{
	"runtime.goexit",
	"runtime.main",
	"net/http.(*conn).serve",
	"net/http.(*ServeMux).ServeHTTP",
	"net/http.HandlerFunc.ServeHTTP",
	"net/http.serverHandler.ServeHTTP",
}

func entryCreate(level level, in []interface{}) *EntryS {

	if level == LevelDebug && DebugHide {
		return nil
	}

	inLen := len(in)
	if inLen == 0 {
		return nil
	}
	if in[0] == nil || in[0] == "" {
		return nil
	}

	// ----------------------------------------------------
	// creating new log entry

	// goID := goroutineID()
	entry := &EntryS{
		// ID:        goID + "-" + common.RandString(8) + "-" + string(level[0]),
		// ContextID: goID,
		Level:     level,
		Message:   fmt.Sprint(in[0]),
		Vars:      in[1:],
		Traceback: Trace(),
	}

	// ----------------------------------------------------
	// print JSON to stdout

	out := map[string]string{
		// "context-id": entry.ContextID,
		"level":   string(entry.Level),
		"message": entry.Message,
	}

	for _, v := range entry.Traceback {
		out["traceback"] += fmt.Sprintf("%s:%d / %s\n", v.FilePath, v.LineNr, v.FunctionName)
		if DebugMode {
			out["traceback"] += ""
		}
	}

	for i, v := range entry.Vars {
		switch v.(type) {
		case string:
			out[fmt.Sprintf("var-%d", i)] = v.(string)

		case Vars:
			for k2, v2 := range v.(Vars) {
				if k2 == "context-id" {
					k2 = "vars/context-id"
				}
				if k2 == "level" {
					k2 = "vars/level"
				}
				if k2 == "message" {
					k2 = "vars/message"
				}
				if k2 == "traceback" {
					k2 = "vars/traceback"
				}
				out[k2] = fmt.Sprint(v2)
			}

		default:
			out[fmt.Sprintf("var-%d", i)] = fmt.Sprint(v)
		}
	}

	var buf []byte
	var err error
	if DebugMode {
		buf, err = json.MarshalIndent(entry, "", "  ")

	} else {
		buf, err = json.Marshal(out)
	}

	if err != nil {
		println("ERROR: while json.Marshal(entry):", err)
		return entry
	}

	println(string(buf))

	// ----------------------------------------------------

	return entry
}

// --------------------------------------------------

// Trace ...
func Trace() []TraceS {
	trace := []TraceS{}
	pc := make([]uintptr, 10)
	n := runtime.Callers(4, pc)
	frames := runtime.CallersFrames(pc[:n])
	for {
		frame, isMore := frames.Next()
		if !isStringInSlice(frame.Function, framesToIgnore) {
			trace = append(trace, TraceS{
				FilePath:     frame.File,
				LineNr:       frame.Line,
				FunctionName: frame.Function,
			})
		}

		if !isMore {
			break
		}
	}
	return trace
}

// --------------------------------------------------

// var (
// 	goroutineIDLock sync.RWMutex
// 	goroutineIDmap  = map[int]string{}
// )

// func goroutineIDraw() int {
// 	var buf [64]byte
// 	n := runtime.Stack(buf[:], false)
// 	idField := strings.Fields(strings.TrimPrefix(string(buf[:n]), "goroutine "))[0]
// 	id, err := strconv.Atoi(idField)
// 	if err != nil {
// 		panic(fmt.Sprintf("cannot get goroutine id: %v", err))
// 	}
// 	return id
// }

// // StartNewContext ...
// func StartNewContext() string {
// 	gid := goroutineIDraw()
// 	goroutineIDLock.Lock()
// 	defer goroutineIDLock.Unlock()
// 	goroutineIDmap[gid] = common.RandString(12)
// 	return goroutineIDmap[gid]
// }

// func goroutineID() string {
// 	gid := goroutineIDraw()
// 	goroutineIDLock.RLock()
// 	res, exist := goroutineIDmap[gid]
// 	goroutineIDLock.RUnlock()
// 	if !exist {
// 		res = StartNewContext()
// 	}
// 	return res
// }

// --------------------------------------------------

func isStringInSlice(s string, slice []string) bool {
	for _, ss := range slice {
		if ss == s {
			return true
		}
	}
	return false
}

// --------------------------------------------------

// PrintObj ...
func PrintObj(in interface{}) error {
	b, err := json.MarshalIndent(in, "", "\t")
	if err != nil {
		return err
	}

	fmt.Println("=>", string(b))
	return nil
}

// --------------------------------------------------

// PrintJSON ...
func PrintJSON(in interface{}) error {
	buf, err := json.MarshalIndent(in, "", "  ")
	if err != nil {
		return err
	}

	println(string(buf))
	return nil
}
