package main

import (
	"encoding/json"
	"net/http"

	"github.com/eawsy/aws-lambda-go-net/service/lambda/runtime/net"
	"github.com/eawsy/aws-lambda-go-net/service/lambda/runtime/net/apigatewayproxy"
)

var Handle apigatewayproxy.Handler

func init() {
	ln := net.Listen()
	Handle = apigatewayproxy.New(ln, nil).Handle

	http.Handle("/", root())

	go func() {
		defer ln.Close()
		http.Serve(ln, nil)
	}()
}

func root() http.Handler {
	return http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		defer req.Body.Close()

		res.Header().Set("Content-Type", "application/json")
		b, _ := json.Marshal(struct {
			Status string `json:"status"`
		}{
			Status: "up",
		})

		res.Write(b)
	})
}
