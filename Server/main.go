//main.go

package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/insertapi/lib" // This part is a bit weird, heroku as far as I know doesn't allow local imports like ./

	"github.com/gorilla/context"
	"github.com/gorilla/mux"
)

// Main functions of the code
func main() {
	fmt.Println("API started up!") // Indicates the program started up

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default port
	}
	fmt.Println("Port: " + port)

	router := mux.NewRouter()

	router.HandleFunc("/test", testMethod).Methods("GET")
	router.HandleFunc("/assets/{authid}/{id}", httpParse).Methods("GET")
	log.Fatal(http.ListenAndServe(":"+port, context.ClearHandler(router))) // To make sure the program does not memory leak
	//log.Fatal(http.ListenAndServe(":"+port, router))
}

// A test to make sure the router is fully set up
func testMethod(res http.ResponseWriter, request *http.Request) {
	res.Write([]byte("Hello!"))
}

// Main function for parsing http requests, especially the asset branch in the url
func httpParse(res http.ResponseWriter, request *http.Request) {
	res.Header().Set("Content-Type", "application/json") // Lets the response know that the content is a json response
	params := mux.Vars(request)
	authid := params["authid"]
	id := params["id"]

	key := os.Getenv("KEY") // Make sure to set the key up, and DO NOT LEAK THE KEY
	if key == "" {          // If you are testing this on your local machine, the default key is test123.
		key = "test123"
	}
	if authid != key { // Handle incorrect API keys
		res.Write([]byte("ERROR 401: Incorrect API key"))
		return
	}

	result := lib.Parse(id) // Parse and download the roblox id model
	if result == nil {
		res.Write([]byte("ERROR 404: Error parsing id!")) // Handle parsing errors
	} else {
		res.Write(result)       // Respond with the parsed json return of the function
		os.Remove(id + ".rbxm") // Remove the rbxm file to save space
	}
}
