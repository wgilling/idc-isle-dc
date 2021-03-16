package main

import (
	"strings"
)

// Encapsulates the entity type and bundle of a Drupal resource.
//
// DrupalType is parsed from the JSONAPI response, where type is represented, e.g. as:
//   "type": "taxonomy_term--person"
type DrupalType string

// The entity (e.g. taxonomy_term, node, etc) encapsulated by this type
func (t DrupalType) entity() string {
	return strings.Split(string(t), "--")[0]
}

// The bundle (e.g. 'person', 'islandora_object', etc) encapsulated by this type
func (t DrupalType) bundle() string {
	return strings.Split(string(t), "--")[1]
}

// Represents the expected results of a migrated person
type ExpectedPerson struct {
	Type        string
	Bundle      string
	Name        string   `json:"name"`
	PrimaryName string   `json:"primary_name"`
	RestOfName  []string `json:"rest_of_name"`
	FullerForm  []string `json:"fuller_form"`
	Prefix      []string
	Suffix      []string
	Number      []string
	AltName     []string `json:"alt_name"`
	Date        []string
	Knows       []string
	Authority   []struct {
		Uri  string
		Name string
		Type string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated repository object
type ExpectedRepoObj struct {
	Type             string
	Bundle           string
	Abstract         []LanguageString
	AccessRights     []string         `json:"access_rights"`
	AltTitle         []LanguageString `json:"alt_title"`
	CollectionNumber []string         `json:"collection_number"`
	CopyrightAndUse  string           `json:"copyright_and_use"`
	CopyrightHolder  []string         `json:"copyright_holder"`
	Contributor      []struct {
		RelType string `json:"rel_type"`
		Name    string
	}
	Creator []struct {
		RelType string `json:"rel_type"`
		Name    string
	}
	DateAvailable     string   `json:"date_available"`
	DateCopyrighted   []string `json:"date_copyrighted"`
	DateCreated       []string `json:"date_created"`
	DatePublished     []string `json:"date_published"`
	DigitalIdentifier []string `json:"digital_identifier"`
	DigitalPublisher  []string `json:"digital_publisher"`
	DisplayHint       string   `json:"display_hint"`
	DspaceIdentifier  string   `json:"dspace_identifier"`
	DspaceItemId      string   `json:"dspace_itemid"`
	Model             string
	ResourceType      []string `json:"resource_type"`
	Title             string
	MemberOf          []string `json:"member_of"`
	Extent            []string
	LinkedAgent       []struct {
		Rel  string
		Name string
	}
	Description []struct {
		Value    string
		LangCode string `json:"language"`
	}
}

// Represents the expected results of a migrated Access Rights taxonomy term
type ExpectedAccessRights struct {
	Type      string
	Bundle    string
	Name      string
	Authority []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated Copyright and Use taxonomy term
type ExpectedCopyrightAndUse struct {
	Type      string
	Bundle    string
	Name      string
	Authority []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated Family taxonomy term
type ExpectedFamily struct {
	Type       string
	Bundle     string
	Name       string
	Date       []string
	FamilyName string `json:"family_name"`
	Title      string
	Authority  []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
	KnowsAbout []string `json:"knowsAbout"`
}

// Represents the expected results of a migrated Genre taxonomy term
type ExpectedGenre struct {
	Type      string
	Bundle    string
	Name      string
	Authority []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated Geolocation taxonomy term
type ExpectedGeolocation struct {
	Type       string
	Bundle     string
	Name       string
	GeoAltName []string `json:"geo_alt_name"`
	Broader    []struct {
		Uri   string
		Title string
	}
	Authority []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated Resource Types taxonomy term
type ExpectedResourceType struct {
	Type      string
	Bundle    string
	Name      string
	Authority []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated Subject taxonomy term
type ExpectedSubject struct {
	Type      string
	Bundle    string
	Name      string
	Authority []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated Language taxonomy term
type ExpectedLanguage struct {
	Type         string
	Bundle       string
	Name         string
	LanguageCode string `json:"language_code"`
	Authority    []struct {
		Uri    string
		Title  string
		Source string
	}
	Description struct {
		Value     string
		Format    string
		Processed string
	}
}

// Represents the expected results of a migrated Collection entity
type ExpectedCollection struct {
	Type          string
	Bundle        string
	Title         string
	TitleLangCode string `json:"title_language"`
	AltTitle      []struct {
		Value    string
		LangCode string `json:"language"`
	} `json:"alternative_title"`
	Description []struct {
		Value    string
		LangCode string `json:"language"`
	}
	ContactEmail     string   `json:"contact_email"`
	ContactName      string   `json:"contact_name"`
	CollectionNumber []string `json:"collection_number"`
	MemberOf         []string `json:"member_of"`
	FindingAid       struct {
		Uri   string
		Title string
	}
}

// Represents the expected results of a migrated Corporate Body taxonomy term
type ExpectedCorporateBody struct {
	Type        string
	Bundle      string
	Name        string
	Description struct {
		Value     string
		Format    string
		Processed string
	}
	PrimaryName     string   `json:"primary_name"`
	SubordinateName []string `json:"subordinate_name"`
	DateOfMeeting   []string `json:"date_of_meeting_or_treaty"`
	Location        []string `json:"location_of_meeting"`
	NumberOrSection []string `json:"num_of_section_or_meet"`
	AltName         []string `json:"corporate_body_alternate_name"`
	Authority       []struct {
		Uri    string
		Title  string
		Source string
	}
	Date         []string
	Relationship []struct {
		Name string
		Rel  string `json:"rel_type"`
	} `json:"relationships"`
}

type LanguageString struct {
	Value    string
	LangCode string `json:"language"`
}
