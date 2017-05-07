package main

import (
	"encoding/json"
	"net/http"
	"os"

	"github.com/Sirupsen/logrus"
	"github.com/eawsy/aws-lambda-go-net/service/lambda/runtime/net"
	"github.com/eawsy/aws-lambda-go-net/service/lambda/runtime/net/apigatewayproxy"
	"github.com/pkg/errors"
	"github.com/pressly/chi"
)

var Handle apigatewayproxy.Handler

func init() {
	logrus.SetFormatter(&logrus.JSONFormatter{})
	if os.Getenv("DEBUG") != "" {
		logrus.SetLevel(logrus.DebugLevel)
	}

	ln := net.Listen()
	Handle = apigatewayproxy.New(ln, nil).Handle

	r := chi.NewRouter()
	r.Get("/", root())

	go func() {
		defer ln.Close()
		logrus.Fatalf("%v", http.Serve(ln, r))
	}()
}

func main() {}

func root() http.HandlerFunc {
	return http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		defer req.Body.Close()

		b, err := json.Marshal(struct {
			Status string `json:"status"`
		}{
			Status: "up",
		})
		if err != nil {
			logrus.Errorf("%+v", errors.Wrap(err, "unable to marshal json"))
			res.WriteHeader(500)
			return
		}

		res.Write(b)
	})
}
