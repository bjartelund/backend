import gleam/bytes_builder
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/result
import mist
import service

pub fn main() {
  let assert Ok(service) = service.new()
  let assert Ok(_) =
    mist.new(
      // Handler function: takes a request and produces a response
      fn(request) {
        case request.method {
          http.Post -> {
            let content =
              request
              |> request.get_header("content-type")
              |> result.unwrap("text/plain")

            service.add_item(service, content)
          }
          _ -> service.add_item(service, "hello world")
        }
        let assert Ok(service_response) = service.get_item(service)
        let body =
          { "Hello, " <> service_response <> "!" }
          |> bytes_builder.from_string
          |> mist.Bytes
        response.new(200) |> response.set_body(body)
      },
    )
    |> mist.port(3000)
    |> mist.start_http

  // The server starts in a separate process, pause the main process
  process.sleep_forever()
}
