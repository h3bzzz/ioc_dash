package db

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
	"github.com/pressly/goose/v3"
)

func ConnectAndMigrate(dsn string) (*sql.DB, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("sql.Open: %w", err)
	}
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("db.Ping: %w", err)
	}

	goose.SetDialect("postgres")

	migrationsDir := "backend/db/migrations"

	if err := goose.Up(db, migrationsDir); err != nil {
		return nil, fmt.Errorf("goose.Up: %w", err)
	}

	log.Println("✅ Database migrations applied successfully")
	return db, nil
}
