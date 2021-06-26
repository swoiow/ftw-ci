package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/urfave/cli/v2"
)

type Release struct {
	TagName    string `json:"tag_name"`
	PreRelease bool   `json:"prerelease"`
}

func fetchRelease(repository string) []byte {

	url := "https://api.github.com/repos/" + repository + "/releases?per_page=10"
	method := "GET"

	client := &http.Client{
	}
	req, err := http.NewRequest(method, url, nil)

	if err != nil {
		panic(err)
	}
	req.Header.Add("Accept", "application/vnd.github.v3+json")

	res, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		panic(err)
	}

	return body
}

func main() {
	app := &cli.App{
		Usage: "Get github project release" +
			"\n\ngr --stable=false XXX/xxx" +
			"\n",
		Flags: []cli.Flag{
			&cli.BoolFlag{
				Name:  "stable",
				Value: true,
				Usage: "Use stable release or not.",
			},
		},
	}

	app.Action = func(c *cli.Context) error {
		body := fetchRelease(c.Args().Get(0))
		var releases []Release
		err := json.Unmarshal(body, &releases)
		if err != nil {
			panic(err)
		}
		for i := 0; i < len(releases); i++ {
			if !c.Bool("stable") {
				fmt.Println(releases[i].TagName)
				return nil
			} else {
				if !releases[i].PreRelease {
					fmt.Println(releases[i].TagName)
					return nil
				}
			}
		}
		return nil
	}

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}
