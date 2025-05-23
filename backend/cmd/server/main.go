package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/h3bzzz/ioc_dash/backend/api"
	"github.com/h3bzzz/ioc_dash/backend/config"
	"github.com/h3bzzz/ioc_dash/backend/db"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	database, err := db.ConnectAndMigrate(cfg.DB_DSN)
	if err != nil {
		log.Fatalf("failed to connect & migrate DB: %v", err)
	}
	defer func() {
		if err := database.Close(); err != nil {
			log.Printf("error closing DB: %v", err)
		}
	}()

	go func() {
		log.Printf("Starting IOC Collection (interval: %s)", cfg.PollInterval)
		ingestion.StartCollection(database, cfg.PollInterval)
	}()

	app := fiber.New()

	app.Get("/health", func(c fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status": "ok",
			"time":   time.Now().Format(time.RFC3339),
		})
	})


	port := os.Getenv("API_PORT")
	if port == "" {
		port = "7777"
	}
	address := fmt.Sprintf(":%s", port)
	log.Printf("Fiber is up on %s", port)
	if err := app.Listen(address); err != nil {
		log.Fatalf("Serve error: %v", err)
	}
}
