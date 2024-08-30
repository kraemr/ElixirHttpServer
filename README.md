# What is this?

Currently this is just a little project for me to learn the HTTP Spec, mess around with network-programming and elixir.
I would not recommend using this Server for anything that handles any kind of sensitive Data currently as it is just a pet project.

# How do i use this?

currently you would need to include all HTTP\*.ex files in your own project as i do not have a Hex package and have not verified that git dependency in mix.exs works.

I will try to make it usable by including it as a git dependency (soon).

An example for using the API is in http_server/lib/test_app.ex
```
#in root of repo
cd http_server
iex -S mix
TestApp.start("","")
```


# How does this work
HTTPServer receives the raw tcp data, checks if it is valid and extracts Version,Path,Method,Headers,Body
Then it checks if the path exists in the routes map specified by the user on startup.
IF it exists then the callback function for that route is executed:

```elixir
    routes = %{
      "/api/test" => json_api_function,
      # register callback for route /api/test -> This function is used to generate responses for /api/test
    }
```

Your callback function receives a single request param with all the data from the inital request.
Then you operate on it and use HTTPResponse.create as your return value.
IF the route does NOT exist it is treated as a filename and is handled by HTTPFileserver
