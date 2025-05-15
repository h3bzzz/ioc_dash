import config

import (
	"os"
	"time"

	"go.uber.org/zap"
  "go.uber.org/zap/zapcore"
)

const (
	Reset       = "\033[0m"
	Red         = "\033[31m"
	Green       = "\033[32m"
	Yellow      = "\033[33m"
	Blue        = "\033[34m"
	Magenta     = "\033[35m"
	Cyan        = "\033[36m"
	White       = "\033[37m"
	BoldRed     = "\033[1;31m"
	BoldGreen   = "\033[1;32m"
	BoldYellow  = "\033[1;33m"
	BoldBlue    = "\033[1;34m"
	BoldMagenta = "\033[1;35m"
	BoldCyan    = "\033[1;36m"
	BoldWhite   = "\033[1;37m"
)

var (
	Log *zap.SugaredLogger
	devLogger *zap.SugaredLogger

)
