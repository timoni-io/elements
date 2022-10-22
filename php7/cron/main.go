package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/mileusna/crontab"
	"syslabit.com/git/syslabit/log"
)

func main() {
	cronFilePath := os.Args[1]
	file, err := os.Open(cronFilePath)
	if err != nil {
		log.Fatal(err, log.Vars{
			"logger": "cron",
		})
		return
	}

	ctab := crontab.New()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		if line[0] == '#' {
			continue
		}
		if strings.HasPrefix(line, "SHELL=") {
			continue
		}
		schedule, shellCMD := parseLine(line)
		ctab.MustAddJob(schedule, runJob, shellCMD)
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err, log.Vars{
			"logger": "cron",
		})
		return
	}

	log.Debug("cron stated...", log.Vars{
		"logger": "cron",
	})
	for {
		time.Sleep(10 * time.Minute)
	}
}

func parseLine(line string) (string, string) {
	tmp := strings.SplitN(line, " ", 6)
	if len(tmp) != 6 {
		log.Error("wrong line format: "+line, log.Vars{
			"logger": "cron",
		})
		return "", ""
	}
	// for k, v := range tmp {
	// 	fmt.Println(">>>", k, v)
	// }

	a := strings.Join(tmp[:5], " ")
	b := strings.TrimSpace(tmp[5])

	b = strings.ReplaceAll(b, "2>&1", "")

	log.Debug("cron found job", log.Vars{
		"logger":     "cron",
		"start time": a,
		"cmd":        b,
	})

	return a, b
}

func runJob(cmd string) {
	log.Debug("cron job started", log.Vars{
		"logger": "cron",
		"cmd":    cmd,
	})
	exitCode := runSHELL(cmd)
	if exitCode == 0 {
		log.Info("cron job success", log.Vars{
			"logger": "cron",
			"cmd":    cmd,
		})

	} else {
		log.Error("cron job failed", log.Vars{
			"logger":    "cron",
			"cmd":       cmd,
			"exit code": exitCode,
		})
	}
}

func runSHELL(cmdString string) (exitCode int) {

	for _, e := range os.Environ() {
		fmt.Println(e)
	}

	cmd := exec.Command("/bin/sh", "-c", cmdString)

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Error(err.Error(), log.Vars{
			"logger":    "cron",
			"cmd":       cmdString,
			"exit code": exitCode,
		})
		return 1
	}

	stderr, err := cmd.StderrPipe()
	if err != nil {
		log.Error(err.Error(), log.Vars{
			"logger":    "cron",
			"cmd":       cmdString,
			"exit code": exitCode,
		})
		return 1
	}

	err = cmd.Start()
	if err != nil {
		log.Error(err.Error(), log.Vars{
			"logger":    "cron",
			"cmd":       cmdString,
			"exit code": exitCode,
		})
		return 1
	}

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	multi := io.MultiReader(stdout, stderr)
	out := bufio.NewScanner(multi)

	for out.Scan() {
		log.Info(out.Text(), log.Vars{
			"logger": "cron",
			"cmd":    cmd,
		})
	}

	cmd.Wait()
	return cmd.ProcessState.ExitCode()
}
