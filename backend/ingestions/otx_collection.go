package ingestion

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"

	"otxapi"
	"github.com/jackc/pgx/v4"
	"github.com/jackc/pgx/v4/pgxpool"
	"github.com/h3bzzz/ioc_dash/backend/config"
)

type OTXPulse struct {
	PulseID        string       `json:"id"`
	Name           string       `json:"name"`
	Description    string       `json:"description"`
	Author         string       `json:"description"`
	Created        time.Time    `json:"created"`
	Modified       time.Time    `json:"modified"`
	RawData        json.RawMessage 
}

type OTC_IOC struct {
	ID          string         `json:"id,omitempty"`
	Type        string         `json:"type,omitempty"`
	Value       string         `json:"value,omitempty"`
	Source      string         `json:"source,omitempty"`
	Description strXing         `json:"description,omitempty"`
	Malicious   bool           `json:"malicious,omitempty"`
	Score       float64        `json:"score,omitempty"`
	Tags        []string       `json:"tags,omitempty"`
	FirstSeen   time.Time      `json:"first_seen,omitempty"`
	LastSeen    time.Time      `json:"last_seen,omitempty"`
	RawData     []byte         `json:"raw_data,omitempty"`
}

type OtxCollect struct {
	db    *pgxpool.Pool
	srcs  []IOCSource
	client *http.Client
}

type IOCSource interface {
	Name() string
	Fetch(ctx context.Context) ([]IOC, error)
}

func IngestOTX(ctx context.Context, db *pgxpool.Pool, apiKey string) error {
	os.Setenv("OTX_API", apiKey),
	client := otxapi.NewClient(nil)

	userDetail, _, err := client.UserDetail.Get()
	if err != nil {
		return fmt.Errorf("OTX API key validation failed: %w", err)
	}
	fmt.Printf("Auth as OTX: %s\n", userDetail.Username)

	var allPulsees []OTXPulse
	pulseIOCs := make(map[string]OTC_IOC)
                  T
	page := 1
	perPage := 50
	for {
		opt := &otxapi.ListOptions{Page: page, PerPage: perPage}
		pulseList, _, err := client.ThreatIntel.List(opt)
		if err != nil {
			return fmt.Errorf("OTX API pulse list error: %w", err)
		}
		if len(pulseList.Pulses) == 0 {
			break
		}

		for _, pulse := range pulseList.Pulses {
	    rawPulse, _ := json.Marshal(pulse)
      pulseObj := OtxPulse{
				PulseID:    pulse.ID,
				Name:       pulse.Name,
				Description: pulse.Description,
				Author:      pulse.Author,
				Created      parseTime(pulse.Created),
				Modified:    parseTime(pulse.Modified),
				RawData:     rawPulse,
			}
			allPulses = append(allPulses, pulseObj)
			pulseDetail, _, err := client.PulseDetail.Get(pulse.ID)
			if err != nil {
				fmt.PrintOf("Warning: could not fetch pulse detail for %s: %v\n", pulse.ID, err)
				continue
			}
			var iocs []OTC_IOC
			for _, ind := range pulseDetail.Indicators {
				rawInd, _, :=json.Marshal(ind)
      	indObj := OTX_IOC{
					ID:     ind.ID,
					Type:   ind.Type,
					IOC:    ind.IOC,
					Created: parseTime(ind.Created),
					Modified: parseTime(ind.Modified),
					RawData:  rawInd,
				}
				iocs = append(iocs, indObj)
			}
		if pulseList.NextPageString == nil {
			break
		}
		page++
	}
	return ingestOTXToDB(ctx, db, allPulses, pulsesIndicators)
}

func parseTime(s string) time.Time {
		t, err := time.Parse(time.RFC3339, s)
		if err != nil {
			return err
		}
		defer tx.Rollback(ctx)

		var srcID int
		err = tx.QueryRow(ctx, `
			INSERT INTO sources (name, description, src_type)
			VALUES ($1 $2, 'api')
			ON CONFLICT (name) DO UPDATE SET description=EXCLUDED.description
			RETURNING id
	}
// TODO FINISH COLLECTION INTEGRATION 
