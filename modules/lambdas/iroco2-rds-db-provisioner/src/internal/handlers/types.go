package handlers

import (
	"fmt"
	"strings"

	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

type ProvisionRequest struct {
	Databases  []string          `json:"databases"`
	Schemas    []types.Schema    `json:"schemas"`
	Roles      []types.Role      `json:"roles"`
	Users      []types.User      `json:"users"`
	Grants     []types.Grant     `json:"grants"`
	AutoGrants []types.AutoGrant `json:"auto_grants"`
}

func (req *ProvisionRequest) Validate(engine string) error {
	var missing []string

	if len(req.Databases) == 0 {
		missing = append(missing, "databases")
	}

	// Validate each struct using their dedicated method
	for _, s := range req.Schemas {
		if err := s.Validate(); err != nil {
			return fmt.Errorf("invalid schema: %w", err)
		}
	}

	for _, r := range req.Roles {
		if err := r.Validate(); err != nil {
			return fmt.Errorf("invalid role: %w", err)
		}
	}

	for _, u := range req.Users {
		if err := u.Validate(); err != nil {
			return fmt.Errorf("invalid user: %w", err)
		}
	}

	for _, g := range req.Grants {
		if err := g.Validate(engine); err != nil {
			return fmt.Errorf("invalid grant: %w", err)
		}
	}

	for _, ag := range req.AutoGrants {
		if err := ag.Validate(engine); err != nil {
			return fmt.Errorf("invalid auto_grant: %w", err)
		}
	}

	if len(missing) > 0 {
		return fmt.Errorf("missing required top-level fields: %s", strings.Join(missing, ", "))
	}

	return nil
}
