package main

import (
	"fmt"
	"net/http"
	"os"
)

var (
	targetURL = os.Getenv("TARGET_URL")
	// targetURL nie może być puste, powinien zawierać protokoł, np http://test.pl

	targetPath = os.Getenv("TARGET_PATH")
	// w przypadku gdy targetPath jest puste, nastąpi mapowanie ścieżek zapytania na cel jeden do jednego,

	// gdy targetPath = '' & targetURL = 'https://target-domain.pl'
	// zapytanie = 'https://test.pl/jakis/url'
	// wynik = 'https://target-domain.pl/jakis/url'

	// gdy targetPath = '/abc' & targetURL = 'https://target-domain.pl'
	// zapytanie = 'https://test.pl/jakis/url'
	// wynik = 'https://target-domain.pl/abc'

)

func main() {
	router := http.NewServeMux()
	router.HandleFunc("/", redirectHandler)
	http.ListenAndServe(":80", router)
}

func redirectHandler(w http.ResponseWriter, r *http.Request) {
	if targetPath == "" || targetPath == "-" {
		fmt.Println("URL:", r.URL.RawPath, "|uri:", r.RequestURI, "|path:", r.URL.Path)
		http.Redirect(w, r, targetURL+r.URL.RawPath, http.StatusTemporaryRedirect)

	} else {
		http.Redirect(w, r, targetURL+targetPath, http.StatusTemporaryRedirect)
	}
}
