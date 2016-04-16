package main

import (
 "fmt"
 "os"
 "github.com/gorilla/mux"
 "net/http"
 )

func HelloWorld(w http.ResponseWriter, r *http.Request){

                 w.Write([]byte("Hello World!!!"))
 }

func main(){

            r := mux.NewRouter()
            r.HandleFunc("/", HelloWorld)
            http.ListenAndServe(":8080",r)
 }
