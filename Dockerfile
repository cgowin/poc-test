# --- Stage 1: Build the application ---
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Safely write the Go code using a heredoc literal
RUN <<EOF cat > main.go
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintln(w, "Hello, World! Web service is running smoothly.")
    })
    fmt.Println("Server starting on port 8080...")
    if err := http.ListenAndServe(":8080", nil); err != nil {
        panic(err)
    }
}
EOF

# Compile the binary into a statically linked executable
RUN CGO_ENABLED=0 GOOS=linux go build -o webservice main.go

# --- Stage 2: Final minimal image ---
FROM alpine:latest

WORKDIR /root/

# Copy the pre-built binary from the builder stage
COPY --from=builder /app/webservice .

# Expose the port the app runs on
EXPOSE 8080

# Run the web service
CMD ["./webservice"]