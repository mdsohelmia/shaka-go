package main

import (
	"os/exec"
)

type ShakaPackagerConfig struct {
	BinPath string `json:"bin_path"`
}
type ShakaPackager struct {
	config *ShakaPackagerConfig
}

func NewShakaPackager(config *ShakaPackagerConfig) *ShakaPackager {
	return &ShakaPackager{
		config: config,
	}
}

func (s *ShakaPackager) Version() string {
	cmd := exec.Command(s.config.BinPath, "--version")
	out, err := cmd.Output()
	cmd.Run()
	if err != nil {
		return "error"
	}
	return string(out)
}

func main() {
	config := &ShakaPackagerConfig{
		BinPath: "/usr/local/bin/shaka-packager",
	}
	sp := NewShakaPackager(config)
	println(sp.Version())
}
