package function

import (
    "fmt"
    "net/http"
)

func HelloWorld(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello World")
}
